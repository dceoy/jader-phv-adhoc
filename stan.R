#!/usr/bin/env R

pload <- function(p) {
  if (! p %in% installed.packages()[,1]) install.packages(p, dependencies = TRUE)
  require(p, character.only = TRUE)
}

r <- getOption('repos')
r['CRAN'] <- 'http://cran.us.r-project.org'
options(repos = r)
rm(r)

pkgs <- c('RSQLite', 'plyr', 'dplyr', 'tidyr', 'data.table', 'snow', 'foreach', 'doSNOW', 'parallel', 'yaml', 'ggplot2', 'rstan')
sapply(pkgs, pload)

select <- dplyr::select
cl <- makeCluster(detectCores(), type = 'SOCK')
registerDoSNOW(cl)
.Last <- function() stopCluster(cl)

if (file.exists(data_path <- 'output/dm_tbl.Rdata')) {
  load(data_path)
} else {
  db <- 'mj.sqlite3'
  source('dm_tbl.R')
}

out_path <- 'output/stan_log.txt'
cat('', file = out_path)
rdata <- list()
hlt_codes <- yaml.load_file('hlts.yml')$stan

st_model <- stan_model(file = 'car.stan')

foreach (code = hlt_codes) %do% {
  hlt <- dt_hlts %>% filter(hlt_code == code)
  reac <- dt_reac %>% filter(hlt_code == code)
  hist <- dt_hist %>% filter(hlt_code == code)
  sgnl <- dt_sgnl %>% filter(hlt_code == code)
  ccmt <- dt_ccmt %>%
            filter(drug %in% sgnl$drug) %>%
            group_by(case_id) %>%
            summarize(concomit = n())
  hlt <- hlt %>% mutate(case_count = nrow(reac))

  dt <- dt_base %>%
          left_join(ccmt, by = 'case_id') %>%
          mutate(concomit = as.integer(ifelse(is.na(concomit), 0, concomit))) %>%
          mutate(preexist = as.integer(ifelse(case_id %in% hist$case_id, 1, 0))) %>%
          mutate(event = as.integer(ifelse(case_id %in% reac$case_id, 1, 0))) %>%
          select(event, dpp4_inhibitor, glp1_agonist, concomit, preexist, age, sex, quarter)

  ae_dat <- list(N = dt %>% nrow(),
                 M = 6,
                 L = dt %>% distinct(quarter) %>% nrow(),
                 y = dt$event,
                 x = dt %>% select(dpp4_inhibitor, glp1_agonist, concomit, preexist, age, sex),
                 t = dt %>%
                       distinct(quarter) %>%
                       mutate(q_id = 1:nrow(.)) %>%
                       select(quarter, q_id) %>%
                       inner_join(dt, by = 'quarter') %>%
                       .$q_id)

  sflist <- foreach(i = 1:8, .packages = 'rstan') %dopar% {
              sampling(object = st_model, data = ae_dat, iter = 2000, chains = 1, chain_id = i, refresh = -1)
            }
  stanfit <- sflist2stanfit(sflist)

  plot_path <- paste('img/plot_', hlt$hlt_code, '.pdf', sep = '')
  traceplot_path <- paste('img/traceplot_', hlt$hlt_code, '.pdf', sep = '')
  violin_path <- paste('img/violin_', hlt$hlt_code, '.svg', sep = '')

  pdf(plot_path)
    plot(stanfit)
  dev.off()

  pdf(traceplot_path)
    traceplot(stanfit)
  dev.off()

  alpha <- 0.01

  la <- extract(stanfit, permuted = TRUE)
  N <- dt %>% nrow()
  N_mc <- length(la$alpha)

  bs <- tbl_dt(data.table(la$beta))
  ors <- bs %>%
           setnames(c('dpp4i', 'glp1a', 'ccm', 'pre', 'age', 'sex')) %>%
           exp()
  or_g <- ors %>%
            select(dpp4i, glp1a) %>%
            gather(param, value)
  or_gq <- or_g %>%
             group_by(param) %>%
             summarize(ymed = median(value),
                       ymin = quantile(value, prob = alpha / 2),
                       ymax = quantile(value, prob = 1 - alpha / 2))
  or_g <- or_g %>% inner_join(or_gq, by = 'param')

  p <- ggplot(or_g, aes(x = param, y = ymed, group = param, ymax = ymax, ymin = ymin, color = param)) +
         geom_hline(aes(yintercept=1), colour='#4400FF', linetype=2) +
         geom_violin(trim = FALSE, fill = '#5B423D', linetype = 'blank', alpha = I(1/3)) +
         geom_pointrange(data = or_gq, size = 0.75, shape = 15) +
         scale_y_log10(limits = c(0.1, 200)) +
         scale_x_discrete(limits = rev(c('dpp4i', 'glp1a'))) +
         scale_colour_manual(values=c('#FF00FF', '#4400FF')) +
         labs(x = '', y = '') +
         theme(axis.text.x = element_text(size = 14), axis.text.y = element_text(size = 14), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background=element_rect(fill='#DDDDFF')) +
         coord_flip()

  svg(violin_path, width = 12, height = 8)
    print(p)
  dev.off()

  orci <- ors %>%
            apply(2, function(b) quantile(b, c(0.5, alpha / 2, 1 - alpha / 2))) %>%
            t()

  out <- list(event = t(hlt), stanfit = stanfit, odds_ratio = orci, dpp4i = '', glp1a = '')
  if (orci[1,2] > 1) out$dpp4i <- 'significant'
  if (orci[2,2] > 1) out$glp1a <- 'significant'

  sink(out_path, append = TRUE)
    print(out)
  sink()

  rdata[paste('or', code, sep = '_')] <- ors
}

save.image('output/stan.Rdata')
