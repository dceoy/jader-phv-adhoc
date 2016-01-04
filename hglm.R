#!/usr/bin/env Rscript

sapply(c('dplyr', 'tidyr', 'data.table', 'loo', 'rstan', 'ggmcmc'), require, character.only = TRUE)
select <- dplyr::select
sapply(paste0('output/', c('csv', 'log', 'pdf', 'rds')), function(p) if(! dir.exists(p)) dir.create(p))
v_socc <- as.integer(commandArgs(trailingOnly = TRUE))
if(length(v_socc) == 0) v_socc <- tbl_dt(fread('input/csv/dt_soc.csv'))$soc_code
print(v_socc)

hglm_waic <- function(socc, models, rds_dir) {
  stan_waic <- function(model, data, socc) {
    tag <- paste0(model@model_name, '_', socc)
    sink(paste0('output/log/stanfit_', tag, '.txt'))
    print(stanfit <- sampling(model, data = data, chains = 3, iter = 3000, warmup = 2000))
    print(loo_waic <- waic(extract_log_lik(stanfit)))
    sink()
    saveRDS(stanfit, file = paste0(rds_dir, 'stanfit_', tag, '.rds'))
    pars <- setdiff(stanfit@model_pars, 'log_lik')
    write.table(bind_cols(lapply(pars,
                                 function(p, d, cn) return(setnames(data.table(d[[p]]),
                                                                    cn[grep(paste0('^', p), cn)])),
                                 d = rstan::extract(stanfit, pars = pars),
                                 cn = names(stanfit))),
                file = paste0('output/csv/posterier_', tag, '.csv'), sep = ',', row.names = FALSE)
    ggmcmc(filter(ggs(stanfit), ! grepl('^log_lik', Parameter)), file = paste0('output/pdf/ggmcmc_', tag, '.pdf'))
    pdf(paste0('output/pdf/traceplot_', tag, '.pdf'))
    traceplot(stanfit, pars = pars)
    plot(stanfit, pars = pars)
    dev.off()
    return(bind_cols(data.table(soc_code = socc, model = model@model_name),
                     as.data.frame(loo_waic[c('waic', 'se_waic', 'elpd_waic', 'se_elpd_waic', 'p_waic', 'se_p_waic')])))
  }
  write.table(d <- bind_rows(lapply(models,
                                    stan_waic,
                                    data = fread(paste0('input/csv/dt_', socc, '.csv')) %>%
                                      list(N = nrow(.),
                                           M = 3,
                                           y = .$event,
                                           x = select(., drug_count, age, sex),
                                           L = length(unique(.$yid)),
                                           t = .$yid),
                                    socc = socc)),
              file = paste0('output/csv/waic_', socc, '.csv'), sep = ',', row.names = FALSE)
  return(d)
}

rstan_options(auto_write = TRUE); options(mc.cores = 3)
v_socc %>%
  lapply(hglm_waic, models = readRDS(file = 'input/rds/stan_models.rds'), rds_dir = 'output/rds/') %>%
  bind_rows() %>%
  print() %>%
  system.time() %>%
  print()
