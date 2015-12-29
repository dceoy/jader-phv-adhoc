#!/usr/bin/env Rscript

source('prep_tables.R') # dt_ade, dt_soc, dt_bf
sapply(pkgs <- c('dplyr', 'tidyr', 'data.table', 'foreach', 'doSNOW', 'ggmcmc', 'rstan'),
       function(p) require(p, character.only = TRUE))
select <- dplyr::select
registerDoSNOW(cl <- makeCluster(parallel::detectCores(), type = 'SOCK'))

plot_log <- function(stanfit, tag, log_dir = 'output/log', img_dir = 'output/img') {
  sink(paste0(log_dir, '/stanfit_', tag, '.txt')); print(stanfit); sink()
  pdf(paste0(img_dir, '/traceplot_', tag, '.pdf')); traceplot(stanfit); dev.off()
  pdf(paste0(img_dir, '/traceplot_', tag, '.pdf')); plot(stanfit); dev.off()
  ggmcmc(ggs(stanfit), file = paste0(img_dir, '/ggmcmc_', tag, '.pdf'))
}

v_yid <- 1:length(unique(dt_ade$year))
names(v_yid) <- sort(unique(dt_ade$year))
dt_base <- dt_ade %>%
             mutate(age = as.integer(age), yid = v_yid[as.character(year)]) %>%
             inner_join(dt_bf, by = c('drug', 'soc_code')) %>%
             select(case_id, drug, soc_code, age, sex, yid, bf)
bf_threshold <- 100
mixed <- stan_model(file = 'mixed.stan')

print(system.time(hlr <- foreach(socc = dt_soc$soc_code, .packages = pkgs) %dopar% {
  dt_susp <- dt_base %>%
               filter(soc_code == socc, bf > bf_threshold) %>%
               group_by(case_id) %>%
               summarize(drug_count = n_distinct(drug))
  dt_stan <- dt_base %>%
               group_by(case_id, age, sex, yid) %>%
               summarize(event = ifelse(socc %in% soc_code, 1, 0)) %>%
               tbl_dt() %>%
               left_join(dt_susp, by = 'case_id') %>%
               replace_na(list(drug_count = 0))

  ls_d <- list(N = nrow(dt_stan),
               M = 3,
               L = length(unique(dt_stan$yid)),
               y = dt_stan$event,
               x = select(dt_stan, drug_count, age, sex),
               t = dt_stan$yid)

  fit <- sampling(object = mixed, data = ls_d, iter = 2000, warmup = 1000, chains = 4, refresh = -1)
  plot_log(fit, socc)

  return(list(soc = t(filter(dt_soc, soc_code == socc)),
              fit = fit))
}))

lapply(hlr, function(l) sink('out/log/stan_log.txt'); print(l); sink())
stopCluster(cl)
save.image('output/rdata/hglm.Rdata')
