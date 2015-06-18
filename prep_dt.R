#!/usr/bin/env Rscript
#
#                event
#              +       -
#          +-------+-------+
#        + |   a   |   b   | a + b
#  drug    +-------+-------+
#        - |   c   |   d   | c + d
#          +-------+-------+
#            a + c   b + d
#

source('func.R')
con <- connect_sqlite('mj.sqlite3')

sql_base <- 'SELECT
               d.case_id AS case_id,
               CASE
                 WHEN quarter LIKE "%・第一" THEN REPLACE(quarter, "・第一", "q1")
                 WHEN quarter LIKE "%・第二" THEN REPLACE(quarter, "・第二", "q2")
                 WHEN quarter LIKE "%・第三" THEN REPLACE(quarter, "・第三", "q3")
                 WHEN quarter LIKE "%・第四" THEN REPLACE(quarter, "・第四", "q4")
               END AS quarter,
               CASE
                 WHEN age == "10歳未満" THEN 0
                 WHEN age LIKE "%歳代" THEN REPLACE(age, "歳代", "")
               END AS age,
               CASE
                 WHEN sex == "女性" THEN 0
                 WHEN sex == "男性" THEN 1
               END AS sex
             FROM
               demo d
             WHERE
              d.case_id IN (
                SELECT DISTINCT case_id FROM ade10
              );'

sql_hgdr <- 'SELECT class, drug FROM d_class;'

sql_reac <- 'SELECT DISTINCT case_id, hlt_code FROM ade10;'

sql_drug <- 'SELECT DISTINCT case_id, drug FROM ade10;'

sql_hlts <- 'SELECT DISTINCT
               h.hlt_code AS hlt_code,
               hlt_name,
               hlt_kanji
             FROM
               hlt h
             INNER JOIN
               hlt_j hj ON hj.hlt_code == h.hlt_code;'

sql_ct22 <- 'SELECT
               t123.drug AS drug,
               t123.hlt_code AS hlt_code,
               a,
               a_b - a AS b,
               a_c - a AS c,
               t - a_b - a_c + a AS d
             FROM
               (
                 (
                   (
                     SELECT drug, hlt_code, COUNT(DISTINCT case_id) AS a FROM ade10 GROUP BY drug, hlt_code
                   ) t1 INNER JOIN (
                     SELECT drug, COUNT(DISTINCT case_id) AS a_b FROM ade10 GROUP BY drug
                   ) t2 ON t2.drug == t1.drug
                 ) t12 INNER JOIN (
                   SELECT hlt_code, COUNT(DISTINCT case_id) AS a_c FROM ade10 GROUP BY hlt_code
                 ) t3 ON t3.hlt_code == t12.hlt_code
               ) t123 INNER JOIN (
                 SELECT COUNT(DISTINCT case_id) AS t FROM ade10
               )
             WHERE
               a != 0 AND b != 0 AND c != 0 AND d != 0;'

dt_base <- sql_dt(con, sql_base)
dt_hgdr <- sql_dt(con, sql_hgdr)
dt_reac <- sql_dt(con, sql_reac)
dt_drug <- sql_dt(con, sql_drug)
dt_hlts <- sql_dt(con, sql_hlts)
dt_ct22 <- sql_dt(con, sql_ct22)

v_dpp4 <- dt_hgdr %>% filter(class == 'dpp4_inhibitor') %>% .$drug
v_glp1 <- dt_hgdr %>% filter(class == 'glp1_agonist') %>% .$drug
v_incr <- c(v_dpp4, v_glp1)
v_hltc <- dt_drug %>%
          filter(drug %in% v_incr) %>%
          inner_join(dt_reac, by = 'case_id') %>%
          distinct(hlt_code) %>%
          .$hlt_code

dt_ccmt <- dt_drug %>% filter(! drug %in% v_incr)
dt_hlts <- dt_hlts %>% filter(hlt_code %in% v_hltc)
dt_reac <- dt_reac %>% filter(hlt_code %in% v_hltc)
dt_ct22 <- dt_ct22 %>% filter(hlt_code %in% v_hltc)

dcid <- function (dr) {
  return(dt_drug %>%
           filter(drug %in% dr) %>%
           distinct(case_id) %>%
           .$case_id)
}

dt_base <- dt_base %>%
             distinct(quarter) %>%
             mutate(qid = 1:nrow(.)) %>%
             select(quarter, qid) %>%
             inner_join(dt_base, by = 'quarter') %>%
             mutate(age = as.integer(age),
                    sex = as.integer(sex),
                    hg = as.integer(ifelse(case_id %in% dcid(unique(dt_hgdr$drug)), 1, 0)),
                    dpp4i = as.integer(ifelse(case_id %in% dcid(v_dpp4), 1, 0)),
                    glp1a = as.integer(ifelse(case_id %in% dcid(v_glp1), 1, 0)))

tables()
save.image('output/rdata/dt.Rdata')
