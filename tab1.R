#!/usr/bin/env Rscript

source('func.R')

incr_or <- function(dt, incr) {
  return(dt %>%
           filter(class == incr) %>%
           mutate(or = round(or, digit = 2),
                  ll99 = round(exp(coef - qnorm(1 - 0.01 / 2) * coef_sd), digit = 2),
                  ll95 = round(exp(coef - qnorm(1 - 0.05 / 2) * coef_sd), digit = 2)) %>%
           select(hlt, or, ll99, ll95) %>%
           setnames(c('hlt',
                      paste(incr, 'or', sep = '_'),
                      paste(incr, 'll99', sep = '_'),
                      paste(incr, 'll95', sep = '_'))))
}

dt_orci <- fread('output/csv/mixed_or.csv')[, c(1:3, 6, 8:10), with = FALSE] %>%
             setnames(c('class', 'or', 'll', 'hlt', 'cc', 'coef', 'coef_sd'))

tab1 <- dt_orci %>%
          filter(ll > 1) %>%
          group_by(hlt) %>%
          summarize(maxor = max(or), cc = as.integer(unique(cc))) %>%
          inner_join(incr_or(dt_orci, 'dpp4i'), by = 'hlt') %>%
          inner_join(incr_or(dt_orci, 'glp1a'), by = 'hlt') %>%
          arrange(desc(maxor)) %>%
          select(hlt, dpp4i_or, dpp4i_ll99, dpp4i_ll95, glp1a_or, glp1a_ll99, glp1a_ll95, cc)

write.table(tab1, file = 'output/csv/tab1.csv', sep = ',', row.name = FALSE)
