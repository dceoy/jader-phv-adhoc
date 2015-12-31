#!/usr/bin/env Rscript

source('prep_tables.R') # dt_ade, dt_soc, dt_bf
sapply(c('dplyr', 'tidyr', 'data.table', 'snow', 'rstan', 'ggmcmc'), require, character.only = TRUE)
select <- dplyr::select

v_yid <- 1:length(unique(dt_ade$year))
names(v_yid) <- sort(unique(dt_ade$year))

gen_ls_d_by <- function(socc, dt_base, bf_threshold = 100) {
  sapply(c('dplyr', 'tidyr', 'data.table'), require, character.only = TRUE)
  dt_susp <- dt_base %>%
    filter(soc_code == socc, bf > bf_threshold) %>%
    group_by(case_id) %>%
    summarize(drug_count = n_distinct(drug))
  dt_stan <- dt_base %>%
    group_by(case_id, age, sex, yid) %>%
    summarize(event = ifelse(socc %in% soc_code, 1, 0)) %>%
    tbl_dt() %>%
    left_join(dt_susp, by = 'case_id') %>%
    replace_na(list(drug_count = 0)) #%>% slice(., sample(1:nrow(.), 100))
  return(list(soc_code = socc,
              data = list(N = nrow(dt_stan),
                          M = 3,
                          y = dt_stan$event,
                          x = select(dt_stan, drug_count, age, sex),
                          L = length(unique(dt_stan$yid)),
                          t = dt_stan$yid)))
}

cl <- makeCluster(parallel::detectCores(), type = 'SOCK')
ls_ls_d <- parLapply(cl,
                     dt_soc$soc_code,
                     gen_ls_d_by,
                     dt_base = dt_ade %>%
                       mutate(age = as.integer(age), yid = v_yid[as.character(year)]) %>%
                       inner_join(dt_bf, by = c('drug', 'soc_code')) %>%
                       select(case_id, drug, soc_code, age, sex, yid, bf))
models <- parLapply(cl, c(fixed = 'fixed.stan', mixed = 'mixed.stan'), stan_model)
stopCluster(cl)

hglm_ic <- function(l, models) {
  stan_waic <- function(model, data, tag) {
    waic <- function(loglik) {
      return(- mean(log(colMeans(exp(loglik)))) + mean(colMeans(loglik ^ 2) - colMeans(loglik) ^ 2))
    }

    f <- sampling(model, data = data, chains = 4, iter = 2000, warmup = 1000)
    save(f, file = paste0('output/rdata/stanfit_', tag, '.Rdata'))
    pdf(paste0('output/img/traceplot_', tag, '.pdf')); traceplot(f); dev.off()
    pdf(paste0('output/img/traceplot_', tag, '.pdf')); plot(f); dev.off()
    ggmcmc(ggs(f), file = paste0('output/img/ggmcmc_', tag, '.pdf'))
    sink(paste0('output/log/stanfit_', tag, '.txt')); print(f); sink()
    return(waic(extract(f)$log_lik))
  }
  sapply(c('dplyr', 'data.table', 'rstan', 'ggmcmc'), require, character.only = TRUE)
  rstan_options(auto_write = TRUE); options(mc.cores = 4)
  return(data.table(soc_code = l$soc_code,
                    model = c('fixed', 'mixed'),
                    waic = c(stan_waic(models$fixed,
                                       l$data[c('N', 'M', 'y', 'x')],
                                       paste0('fixed_', l$soc_code)),
                             stan_waic(models$mixed,
                                       l$data[c('N', 'M', 'y', 'x', 'L', 't')],
                                       paste0('fixed_', l$soc_code)))))
}

#cl <- makeCluster(floor(parallel::detectCores() / 4), type = 'SOCK')
#print(system.time(dt_ic <- bind_rows(parLapply(cl, ls_ls_d, hglm_ic))))
print(system.time(dt_ic <- bind_rows(lapply(ls_ls_d, hglm_ic, models = models))))
#stopCluster(cl)

sink('out/log/stan_log.txt'); lapply(results, print); sink()
