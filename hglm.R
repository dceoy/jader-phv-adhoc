#!/usr/bin/env Rscript

source('load_tables.R') # dt_ade, dt_soc, dt_ct22
sapply(c('dplyr', 'tidyr', 'data.table', 'foreach', 'doSNOW', 'ggmcmc', 'rstan'),
       function(p) require(p, character.only = TRUE))
select <- dplyr::select
registerDoSNOW(cl <- makeCluster(parallel::detectCores(), type = 'SOCK'))

par_bf <- function(dt, cl) {
  bf_by <- function(d) {
    Rcpp::sourceCpp('bayes_factor.cpp')
    return(data.table::as.data.table(t(apply(d, 1, bayes_factor))))
  }
  return(bind_rows(parLapply(cl,
                             lapply(1:length(cl),
                                    function(i) return(filter(dt,
                                                              i == rep(1:length(cl),
                                                                       nrow(dt))))),
                             bf_by)))
}

bf_threshold <- 100
dt_sgnl <- dt_ct22 %>%
             select(a:d) %>%
             distinct() %>%
             par_bf(cl) %>%
             filter(bf > bf_threshold) %>%
             inner_join(dt_ct22, by = c('a', 'b', 'c', 'd')) %>%
             select(drug, soc_code, a, bf)
dt_yid <- dt_ade %>%
            select(year) %>%
            arrange(year) %>%
            distinct(year) %>%
            mutate(yid = 1:nrow(.))

mixed <- stan_model(file = 'mixed.stan')

hlr <- foreach(socc = unique(dt_soc$soc_code), .packages = c('dplyr', 'data.table', 'rstan', 'foreach')) %dopar% {
  dt_base <- dt_ade %>%
               inner_join(dt_yid, by = 'year') %>%
               left_join(filter(dt_sgnl, soc_code == socc), by = c('drug', 'soc_code')) %>%
               mutate(age = as.integer(age),
                      sex = as.factor(sex),
                      yid = as.integer(yid),
                      soc = ifelse(soc_code == socc, 1, 0),
                      signal = ifelse(is.na(bf), 0, 1)) %>%
               group_by(case_id, age, sex, yid) %>%
               summarize(event = as.factor(sum(unique(soc))),
                         drug = as.integer(sum(signal)))
  ls_dat <- list(N = nrow(dt_base),
                 M = 3,
                 L = length(unique(dt_base$yid)),
                 y = dt_base$event,
                 x = select(dt_base, drug, age, sex),
                 t = dt_base$yid)

  stanfit <- sampling(object = mixed, data = ls_dat, iter = 2000, warmup = 1000, chains = 4, refresh = -1)

  sink(paste0('output/log/stan_', socc, '.txt'))
  print(out)
  sink()

  pdf(paste0('output/img/traceplot_', socc, '.pdf'))
  traceplot(stanfit)
  plot(stanfit)
  dev.off()
  ggmcmc(ggs(stanfit), file = paste0('output/img/ggmcmc_', socc, '.pdf'))

  la <- extract(stanfit, permuted = TRUE)
  write.table(data.table(intercept = la$alpha,
                         setnames(data.table(la$beta), c('drug', 'age', 'sex')),
                         sigma = la$sigma,
                         setnames(data.table(la$q), paste0('y', 1:ncol(la$q))),
                         lp__ = la$lp__),
              file = paste0('output/csv/stan_', socc, '.csv'), sep = ',', row.names = FALSE)

  return(list(soc_code = filter(dt_soc, soc_code == socc),
              fit = stanfit))
}

lapply(hlr,
       function(l) {
         sink('out/log/hglm_log.txt')
         print(l)
         sink()
       })

stopCluster(cl)
save.image('output/rdata/hglm.Rdata')
