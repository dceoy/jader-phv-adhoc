#!/usr/bin/env Rscript

sapply(c('dplyr', 'tidyr', 'data.table', 'loo', 'rstan', 'ggmcmc'), require, character.only = TRUE)
select <- dplyr::select
v_socc <- as.integer(commandArgs(trailingOnly = TRUE))
if(length(v_socc) == 0) v_socc <- tbl_dt(fread('input/csv/dt_soc.csv'))$soc_code
print(v_socc)

higgs <- function(fit, inc_warmup = TRUE) {
  d <- dplyr::bind_rows(lapply(1:fit@sim$chains,
                               function(l) return(fit@sim$samples[[l]] %>%
                                                  .[! grepl('^log_lik', names(.))] %>%
                                                  as.data.frame() %>%
                                                  dplyr::mutate(., Iteration = 1:dim(.)[1]) %>%
                                                  tidyr::gather(Parameter, value, -Iteration) %>%
                                                  dplyr::mutate(Chain = l) %>%
                                                  dplyr::select(Iteration, Chain, Parameter, value))))
  if (! inc_warmup) {
    d <- d %>%
      dplyr::filter(Iteration > fit@sim$warmup) %>%
      dplyr::mutate(Iteration = Iteration - fit@sim$warmup)
  }
  attr(d, 'nBurnin') <- ifelse(inc_warmup, 0, fit@sim$warmup)
  attr(d, 'nChains') <- length(unique(d$Chain))
  attr(d, 'nParameters') <- length(unique(d$Parameter))
  attr(d, 'nIterations') <- max(d$Iteration)
  attr(d, 'nThin') <- fit@sim$thin
  attr(d, 'description') <- fit@model_name
  return(d)
}

hglm_waic <- function(socc, models, fit_dir = NULL, plot = FALSE) {
  stan_waic <- function(model, data, socc) {
    tag <- paste0(model@model_name, '_', socc)
    sink(paste0('output/log/stanfit_', tag, '.txt'))
    print(stanfit <- sampling(model, data = data, chains = 2, iter = 2000, warmup = 1000))
    print(loo_waic <- loo::waic(loo::extract_log_lik(stanfit)))
    sink()
    pars <- setdiff(stanfit@model_pars, 'log_lik')
    ggmcmc(higgs(stanfit), file = paste0('output/pdf/ggmcmc_', tag, '.pdf'))
    if(! is.null(fit_dir)) saveRDS(stanfit, file = paste0(fit_dir, 'stanfit_', tag, '.rds'))
    saveRDS(la <- rstan::extract(stanfit, pars = pars), file = paste0('output/rds/la_', tag, '.rds'))
    write.table(bind_cols(lapply(pars,
                                 function(p, d, cn) return(setnames(data.table(d[[p]]), cn[grep(paste0('^', p), cn)])),
                                 d = la, cn = names(stanfit))),
                file = paste0('output/csv/posterier_', tag, '.csv'), sep = ',', row.names = FALSE)
    if(plot) {
      pdf(paste0('output/pdf/traceplot_', tag, '.pdf')); traceplot(stanfit, pars = pars); dev.off()
      pdf(paste0('output/pdf/plot_', tag, '.pdf')); plot(stanfit, pars = pars); dev.off()
    }
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

models <- readRDS(file = 'input/rds/stan_models.rds')[c('mixed', 'fixed', 'ar')]
rstan_options(auto_write = TRUE); options(mc.cores = 2)
v_socc %>%
  lapply(hglm_waic, models = models, fit_dir = NULL) %>%
  bind_rows() %>%
  print() %>%
  system.time() %>%
  print()
