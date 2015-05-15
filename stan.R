#!/usr/bin/env Rscript

source('func.R')

if (file.exists(data_path <- 'output/rdata/dm_tbl.Rdata')) {
  load(data_path)
} else {
  source('dm_tbl.R')
}

cat('', file = csv_path <- 'output/csv/stan_or.csv')
codes <- yaml.load_file('hlts.yml')$stan
st_model <- stan_model(file = 'mixed.stan')

foreach (code = codes, .packages = c('dplyr', 'data.table', 'ggmcmc', 'rstan', 'foreach', 'doSNOW')) %dopar% {
  hlt <- dt_hlts %>% filter(hlt_code == code)
  reac <- dt_reac %>% filter(hlt_code == code)
  sgnl <- dt_sgnl %>% filter(hlt_code == code)
  ccmt <- dt_ccmt %>%
            filter(drug %in% sgnl$drug) %>%
            group_by(case_id) %>%
            summarize(concomit = n())
  hlt <- hlt %>% mutate(case_count = nrow(reac))

  dt <- dt_base %>%
          left_join(ccmt, by = 'case_id') %>%
          mutate(event = ifelse(case_id %in% reac$case_id, 1, 0)) %>%
          mutate(concomit = ifelse(is.na(concomit), 0, concomit)) %>%
          select(event, dpp4_inhibitor, glp1_agonist, concomit, age, sex, quarter)

  ae_dat <- list(N = dt %>% nrow(),
                 M = 5,
                 L = dt %>% distinct(quarter) %>% nrow(),
                 y = dt$event,
                 x = dt %>% select(dpp4_inhibitor, glp1_agonist, concomit, age, sex),
                 t = dt %>%
                       distinct(quarter) %>%
                       mutate(q_id = 1:nrow(.)) %>%
                       select(quarter, q_id) %>%
                       inner_join(dt, by = 'quarter') %>%
                       .$q_id)

  stanfit <- sflist2stanfit(foreach(i = 1:4, .packages = 'rstan') %dopar% {
               return(sampling(object = st_model, data = ae_dat,
                               iter = 2000, warmup = 1000, chains = 1, chain_id = i, refresh = -1))
             })

  pdf(paste('output/img/plot_', code, '.pdf', sep = '')); plot(stanfit); dev.off()
  pdf(paste('output/img/traceplot_', code, '.pdf', sep = '')); traceplot(stanfit); dev.off()
  ggmcmc(ggs(stanfit), file = paste('output/img/ggmcmc_', code, '.pdf', sep = ''))

  la <- extract(stanfit, permuted = TRUE)

  smpl <- data.table(intercept = la$alpha,
                     data.table(la$beta) %>% setnames(c('dpp4i', 'glp1a', 'ccm', 'age', 'sex')),
                     sigma = la$sigma,
                     data.table(la$q) %>% setnames(paste('q', 1:20, sep = '')),
                     lp__ = la$lp__)
  write.table(smpl, file = paste('output/csv/stan_', code, '.csv', sep = ''), sep = ',', row.names = FALSE)

  alpha <- 0.01
  out <- list(event = t(hlt),
              stanfit = stanfit,
              or_ci = smpl %>%
                        apply(2, function(b) quantile(b, c(0.5, alpha / 2, 1 - alpha / 2))) %>%
                        exp() %>%
                        t())
  sink(paste('output/log/stan_', code, '.txt', sep = '')); print(out); sink()

  write.table(cbind(out$or_ci[2:3,],  sapply(hlt, function(v) rep(v, 2))),
              file = csv_path, append = TRUE, sep = ',', col.names = FALSE)
}

