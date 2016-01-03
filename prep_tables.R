#!/usr/bin/env Rscript
#
#                event
#              +       -
#          +-------+-------+
#        + |   a   |   b   |
#  drug    +-------+-------+
#        - |   c   |   d   |
#          +-------+-------+
#

sapply(c('dplyr', 'data.table', 'RSQLite', 'snow', 'rstan'), require, character.only = TRUE)
select <- dplyr::select
connect_db <- function(file, type = 'SQLite') return(dbConnect(dbDriver(type), file))
sql_dt <- function(con, sql) return(tbl_dt(as.data.table(dbGetQuery(con, sql))))

sql_ade = 'SELECT DISTINCT
             drug,
             soc_code,
             case_id,
             year,
             age,
             sex
           FROM
             ade;'
sql_soc = 'SELECT DISTINCT
             s.soc_code AS soc_code,
             soc_name,
             soc_kanji
           FROM
             soc s
           INNER JOIN
             soc_j sj ON sj.soc_code == s.soc_code;'
sql_ct22 = 'SELECT
              t123.drug AS drug,
              t123.soc_code AS soc_code,
              a,
              a_b - a AS b,
              a_c - a AS c,
              t - a_b - a_c + a AS d
            FROM
              (
                (
                  (
                    SELECT drug, soc_code, COUNT(DISTINCT case_id) AS a FROM ade GROUP BY drug, soc_code
                  ) t1
                  INNER JOIN (
                    SELECT drug, COUNT(DISTINCT case_id) AS a_b FROM ade GROUP BY drug
                  ) t2 ON t2.drug == t1.drug
                ) t12
                INNER JOIN (
                  SELECT soc_code, COUNT(DISTINCT case_id) AS a_c FROM ade GROUP BY soc_code
                ) t3 ON t3.soc_code == t12.soc_code
              ) t123
            INNER JOIN (
              SELECT COUNT(DISTINCT case_id) AS t FROM ade
            );'

append_bayes_factor <- function(dt, cl) {
  par_cal_bf <- function(dt, cl) {
    divide_dt <- function(dt, k) {
      return(lapply(1:k, function(i) return(filter(dt, i == rep(1:k, nrow(dt))))))
    }
    cal_bf <- function(d) {
      Rcpp::sourceCpp('bayes_factor.cpp')
      return(as.data.frame(t(apply(d, 1, bayes_factor))))
    }
    return(as.data.table(bind_rows(parLapply(cl, divide_dt(dt, length(cl)), cal_bf))))
  }

  return(inner_join(dt,
                    par_cal_bf(distinct(select(dt, a:d)), cl),
                    by = c('a', 'b', 'c', 'd')))
}

cl <- makeCluster(parallel::detectCores(), type = 'SOCK')

con <- connect_db('input/db/meddra_jader.sqlite3')
system.time(dt_ade <- sql_dt(con, sql_ade)) %>% print()
system.time(write.table(dt_soc <- sql_dt(con, sql_soc), file = 'input/csv/dt_soc.csv', row.names = FALSE)) %>% print()
system.time(dt_bf <- append_bayes_factor(sql_dt(con, sql_ct22), cl)) %>% print()
dbDisconnect(con)

v_yid <- 1:length(unique(dt_ade$year))
names(v_yid) <- sort(unique(dt_ade$year))

write_dt_by_soc <- function(socc, dt, bf_threshold = 100) {
  if(! file.exists(path <- paste0('input/csv/dt_', socc, '.csv'))) {
    sapply(c('dplyr', 'tidyr', 'data.table'), require, character.only = TRUE)
    dt_susp <- dt %>%
      filter(soc_code == socc, bf > bf_threshold) %>%
      group_by(case_id) %>%
      summarize(drug_count = n_distinct(drug))
    dt %>%
      group_by(case_id, age, sex, yid) %>%
      summarize(event = ifelse(socc %in% soc_code, 1, 0)) %>%
      tbl_dt() %>%
      left_join(dt_susp, by = 'case_id') %>%
      replace_na(list(drug_count = 0)) %>%
      select(event, drug_count, age, sex, yid) %>%
      write.table(file = path, sep = ',', row.names = FALSE)
  }
}

system.time(parLapply(cl,
                      dt_soc$soc_code,
                      write_dt_by_soc,
                      dt = dt_ade %>%
                        mutate(age = as.integer(age), yid = v_yid[as.character(year)]) %>%
                        inner_join(dt_bf, by = c('drug', 'soc_code')) %>%
                        select(case_id, drug, soc_code, age, sex, yid, bf))) %>% print()

system.time(models <- parLapply(cl,
                                c(fixed = 'fixed.stan', mixed = 'mixed.stan'),
                                stan_model))
save(models, file = 'input/rdata/stan_models.Rdata')

stopCluster(cl)
