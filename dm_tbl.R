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

if (! 'fex' %in% ls()) source('func.R')

db <- 'mj.sqlite3'
con <- connect_sqlite(db)

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
               END AS sex,
               CASE
                 WHEN d.case_id IN (
                   SELECT DISTINCT case_id FROM drug WHERE name IN (
                     SELECT DISTINCT drug FROM d_class WHERE class == "dpp4_inhibitor"
                   )
                 ) THEN 1
                 ELSE 0
               END AS dpp4_inhibitor,
               CASE
                 WHEN d.case_id IN (
                   SELECT DISTINCT case_id FROM drug WHERE name IN (
                     SELECT DISTINCT drug FROM d_class WHERE class == "glp1_agonist"
                   )
                 ) THEN 1
                 ELSE 0
               END AS glp1_agonist
             FROM
               demo d
             WHERE
               d.case_id IN (
                 SELECT DISTINCT
                   case_id
                 FROM
                   ade10
                 WHERE
                   drug_start_date != "" AND
                   drug IN (
                     SELECT DISTINCT drug FROM d_class
                   )
                 GROUP BY
                   case_id, drug
                 HAVING
                   MIN(drug_start_date) LIKE "201_" OR
                   MIN(drug_start_date) LIKE "201___" OR
                   MIN(drug_start_date) LIKE "201_____"
               );'

sql_hlts <- 'SELECT DISTINCT
               a.hlt_code AS hlt_code,
               hlt_name,
               hlt_kanji,
               COUNT(DISTINCT a.case_id) AS case_count
             FROM
               ade10 a
             INNER JOIN
               hlt h ON h.hlt_code == a.hlt_code
             INNER JOIN
               hlt_j hj ON hj.hlt_code == a.hlt_code
             GROUP BY
               a.hlt_code;'

sql_reac <- 'SELECT DISTINCT
               case_id,
               hlt_code
             FROM
               ade10;'

sql_ccmt <- 'SELECT DISTINCT
               case_id,
               drug
             FROM
               ade10
             WHERE
               drug NOT IN (
                 SELECT DISTINCT drug FROM d_class WHERE class IN ("dpp4_inhibitor", "glp1_agonist")
               );'

sql_sgnl <- 'SELECT
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
                   ) t2 ON t1.drug == t2.drug
                 ) t12 INNER JOIN (
                   SELECT hlt_code, COUNT(DISTINCT case_id) AS a_c FROM ade10 GROUP BY hlt_code
                 ) t3 ON t12.hlt_code == t3.hlt_code
               ) t123 INNER JOIN (
                 SELECT COUNT(DISTINCT case_id) AS t FROM ade10
               )
             WHERE
               a != 0 AND b != 0 AND c != 0 AND d != 0;'

dt_base <- sql_dt(con, sql_base)
dt_hlts <- sql_dt(con, sql_hlts)
dt_reac <- sql_dt(con, sql_reac)
dt_ccmt <- sql_dt(con, sql_ccmt)
dt_sgnl <- sql_dt(con, sql_sgnl)

dt_hlts <- dt_base %>%
             filter(dpp4_inhibitor == 1 | glp1_agonist == 1) %>%
             inner_join(dt_reac, by = 'case_id') %>%
             distinct(hlt_code) %>%
             select(hlt_code) %>%
             inner_join(dt_hlts, by = 'hlt_code')

dt_reac <- dt_reac %>% filter(case_id %in% dt_base$case_id, hlt_code %in% dt_hlts$hlt_code)
dt_ccmt <- dt_ccmt %>% filter(case_id %in% dt_base$case_id)
dt_sgnl <- dt_sgnl %>% filter(drug %in% unique(dt_ccmt$drug), hlt_code %in% dt_hlts$hlt_code)

dt_base <- dt_base %>%
             mutate(age = as.integer(age)) %>%
             mutate(sex = as.integer(sex)) %>%
             mutate(dpp4_inhibitor = as.integer(dpp4_inhibitor)) %>%
             mutate(glp1_agonist = as.integer(glp1_agonist))

alpha <- 0.01
dt_sgnl <- dt_sgnl %>%
             select(a:d) %>%
             parApply(cl, ., 1, fex) %>%
             t() %>%
             cbind(dt_sgnl) %>%
             filter(p_val < alpha, or_mle > 1) %>%
             select(drug, hlt_code)

tables()

save.image('output/rdata/dm_tbl.Rdata')
