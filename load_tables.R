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

sapply(c('dplyr', 'data.table', 'RSQLite'), function(p) require(p, character.only = TRUE))

if (file.exists(data_path <- 'output/rdata/tables.Rdata')) {
  load(data_path)
} else {
  connect_db <- function(file, type = 'SQLite') return(dbConnect(dbDriver(type), file))
  sql_dt <- function(con, sql) return(tbl_dt(data.table(dbGetQuery(con, sql))))
  con <- connect_db('meddra_jader.sqlite3')

  sql_ade = 'SELECT DISTINCT
               drug,
               soc_code,
               case_id,
               CASE
                 WHEN quarter LIKE "%q1" THEN REPLACE(quarter, "q1", "")
                 WHEN quarter LIKE "%q2" THEN REPLACE(quarter, "q2", "")
                 WHEN quarter LIKE "%q3" THEN REPLACE(quarter, "q3", "")
                 WHEN quarter LIKE "%q4" THEN REPLACE(quarter, "q4", "")
               END AS year,
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

  system.time(dt_ade <- sql_dt(con, sql_ade))
  system.time(dt_soc <- sql_dt(con, sql_soc))
  system.time(dt_ct22 <- sql_dt(con, sql_ct22))

  save.image(data_path)
}
