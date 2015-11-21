#!/usr/bin/env Rscript

source('func.R')

con <- connect_sqlite('mj.sqlite3')

sql_q <-'SELECT
           class,
           hlt_code AS code,
           COUNT(DISTINCT case_id) AS cc
         FROM
           ade a
         INNER JOIN
           d_class d ON a.drug == d.drug
         GROUP BY
           class,
           hlt_code;'

dt_hgcc <- sql_dt(con, sql_q) %>%
             mutate(class = ifelse(class == 'dpp4_inhibitor', 'dpp4i', class)) %>%
             mutate(class = ifelse(class == 'glp1_agonist', 'glp1a', class)) %>%
             filter(class %in% c('dpp4i', 'glp1a'))

dt_orci <- fread('output/csv/mixed_or.csv')[, c(1:10), with = FALSE] %>%
             setnames(c('class', 'or', 'll', 'ul', 'code', 'hlt', 'kanji', 'tc', 'coef', 'coef_sd')) %>%
             mutate(code = as.integer(code), tc = as.integer(tc)) %>%
             left_join(dt_hgcc, by = c('class', 'code')) %>%
             mutate(cc = ifelse(is.na(cc), 0, cc))

incr_or <- function(dt, incr) {
  return(dt %>%
           filter(class == incr) %>%
           mutate(or = ifelse(cc != 0, round(or, digit = 2), 0),
                  ll99 = ifelse(cc != 0, round(exp(coef - qnorm(1 - 0.01 / 2) * coef_sd), digit = 2), 0),
                  ul99 = ifelse(cc != 0, round(exp(coef + qnorm(1 - 0.01 / 2) * coef_sd), digit = 2), 0),
                  ci99 = paste(ll99, ul99, sep = ' - ')) %>%
           select(hlt, or, ll99, ul99, ci99, cc) %>%
           setnames(c('hlt',
                      paste(incr, 'or', sep = '_'),
                      paste(incr, 'll99', sep = '_'),
                      paste(incr, 'ul99', sep = '_'),
                      paste(incr, 'ci99', sep = '_'),
                      paste(incr, 'cc', sep = '_'))))
}

tab1 <- dt_orci %>%
          filter(ll > 1) %>%
          group_by(hlt) %>%
          summarize(maxor = max(or), tc = unique(tc)) %>%
          inner_join(incr_or(dt_orci, 'dpp4i'), by = 'hlt') %>%
          inner_join(incr_or(dt_orci, 'glp1a'), by = 'hlt') %>%
          arrange(desc(maxor)) %>%
          select(hlt, dpp4i_cc, dpp4i_or, dpp4i_ll99, dpp4i_ul99, glp1a_cc, glp1a_or, glp1a_ll99, glp1a_ul99, tc)

write.table(tab1, file = 'output/csv/tab1.csv', sep = ',', row.name = FALSE)
