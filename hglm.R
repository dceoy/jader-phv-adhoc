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
    sink(paste0('output/log/stanfit_', tag, '.txt'))
    print(stanfit <- sampling(model, data = data, chains = 2, iter = 2000, warmup = 1000))
    sink()
    save(stanfit, file = paste0(rdata_dir, 'stanfit_', tag, '.Rdata'))
    ggmcmc(ggs(stanfit), file = paste0('output/img/ggmcmc_', tag, '.pdf'))
    pdf(paste0('output/img/traceplot_', tag, '.pdf')); traceplot(stanfit); dev.off()
    pdf(paste0('output/img/plot_', tag, '.pdf')); plot(stanfit); dev.off()
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
                                    mixed = stan_waic(models$mixed,
                                                      ls_d,
                                                      paste0('fixed_', socc)),
                                    fixed = stan_waic(models$fixed,
                                                      ls_d[c('N', 'M', 'y', 'x')],
                                                      paste0('fixed_', socc))),
              file = paste0('waic_', socc, '.csv'), sep = ',', row.names = FALSE)
  return(dt_waic)
}

rstan_options(auto_write = TRUE); options(mc.cores = 2)
system.time(lapply(v_socc, hglm_ic, models = models, rdata_dir = 'output/rdata/'))
