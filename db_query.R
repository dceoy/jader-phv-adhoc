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

source('func.R')  # connect_sqlite(), sql_dt()

sql <- c(base = 'SELECT
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
                    SELECT DISTINCT case_id FROM ade
                  );',
         hgdr = 'SELECT
                   class,
                   drug
                 FROM
                   d_class;',
         reac = 'SELECT DISTINCT
                   case_id,
                   hlt_code
                 FROM
                   ade;',
         drug = 'SELECT DISTINCT
                   case_id,
                   drug
                 FROM
                   ade;',
         hlts = 'SELECT DISTINCT
                   h.hlt_code AS hlt_code,
                   hlt_name,
                   hlt_kanji
                 FROM
                   hlt h
                 INNER JOIN
                   hlt_j hj ON hj.hlt_code == h.hlt_code;',
         ct22 = 'SELECT
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
                         SELECT drug, hlt_code, COUNT(DISTINCT case_id) AS a FROM ade GROUP BY drug, hlt_code
                       ) t1 INNER JOIN (
                         SELECT drug, COUNT(DISTINCT case_id) AS a_b FROM ade GROUP BY drug
                       ) t2 ON t2.drug == t1.drug
                     ) t12 INNER JOIN (
                       SELECT hlt_code, COUNT(DISTINCT case_id) AS a_c FROM ade GROUP BY hlt_code
                     ) t3 ON t3.hlt_code == t12.hlt_code
                   ) t123 INNER JOIN (
                     SELECT COUNT(DISTINCT case_id) AS t FROM ade
                   )
                 WHERE
                   a != 0 AND b != 0 AND c != 0 AND d != 0;')

con <- connect_sqlite('mj.sqlite3')
tbl <- sapply(names(sql), function(t) return(sql_dt(con, sql[t])))

cid <- function(dr) {
  return(tbl$drug %>%
           filter(drug %in% dr) %>%
           distinct(case_id) %>%
           .$case_id)
}

vec <- list(dpp4 = tbl$hgdr %>%
                     filter(class == 'dpp4_inhibitor') %>%
                     .$drug,
            glp1 = tbl$hgdr %>%
                     filter(class == 'glp1_agonist') %>%
                     .$drug)
vec$incr <- c(vec$dpp4, vec$glp1)
vec$hltc <- tbl$reac %>%
              filter(case_id %in% cid(vec$incr)) %>%
              distinct(hlt_code) %>%
              .$hlt_code

tbl$ccmt <- tbl$drug %>% filter(! drug %in% vec$incr)
tbl$hlts <- tbl$hlts %>% filter(hlt_code %in% vec$hltc)
tbl$reac <- tbl$reac %>% filter(hlt_code %in% vec$hltc)
tbl$ct22 <- tbl$ct22 %>% filter(hlt_code %in% vec$hltc)

tbl$base <- tbl$base %>%
              distinct(quarter) %>%
              mutate(qid = 1:nrow(.)) %>%
              select(quarter, qid) %>%
              inner_join(tbl$base, by = 'quarter') %>%
              mutate(age = as.integer(age),
                     sex = as.integer(sex),
                     hg = as.integer(ifelse(case_id %in% cid(tbl$hgdr$drug), 1, 0)),
                     dpp4i = as.integer(ifelse(case_id %in% cid(vec$dpp4), 1, 0)),
                     glp1a = as.integer(ifelse(case_id %in% cid(vec$glp1), 1, 0)))

save.image('output/rdata/tables.Rdata')
