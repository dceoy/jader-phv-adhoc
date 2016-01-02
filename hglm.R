#!/usr/bin/env Rscript

sapply(c('dplyr', 'tidyr', 'data.table', 'rstan', 'ggmcmc'), require, character.only = TRUE)
select <- dplyr::select
load('output/rdata/stan_models.Rdata')
if(length(v_socc <- as.integer(commandArgs(trailingOnly = TRUE))) == 0) {
  v_socc <- tbl_dt(fread('output/csv/dt_soc.csv'))$soc_code
}
print(v_socc)

hglm_ic <- function(socc, models, rdata_dir = 'output/rdata/') {
  stan_waic <- function(model, data, tag) {
    waic <- function(ll) {
      return(- mean(log(colMeans(exp(ll)))) + mean(colMeans(ll ^ 2) - colMeans(ll) ^ 2))
    }
    stanfit <- sampling(model, data = data, chains = 2, iter = 2000, warmup = 1000)
    save(stanfit, file = paste0(rdata_dir, 'stanfit_', tag, '.Rdata'))
    pdf(paste0('output/img/traceplot_', tag, '.pdf')); traceplot(stanfit); dev.off()
    pdf(paste0('output/img/traceplot_', tag, '.pdf')); plot(stanfit); dev.off()
    ggmcmc(ggs(stanfit), file = paste0('output/img/ggmcmc_', tag, '.pdf'))
    sink(paste0('output/log/stanfit_', tag, '.txt')); print(stanfit); sink()
    return(waic(extract(stanfit)$log_lik))
  }
  ls_d <- fread(paste0('output/csv/dt_', socc, '.csv')) %>%
    list(N = nrow(.),
         M = 3,
         y = .$event,
         x = select(., drug_count, age, sex),
         L = length(unique(.$yid)),
         t = .$yid)
  write.table(dt_waic <- data.table(soc_code = socc,
                                    fixed = stan_waic(models$fixed,
                                                      ls_d[c('N', 'M', 'y', 'x')],
                                                      paste0('fixed_', socc)),
                                    mixed = stan_waic(models$mixed,
                                                      ls_d,
                                                      paste0('fixed_', socc))),
              file = paste0('waic_', socc, '.csv'), sep = ',', row.names = FALSE)
  return(dt_waic)
}

system.time(lapply(v_socc, hglm_ic, models = models))
