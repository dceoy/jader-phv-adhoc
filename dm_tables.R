# coding: utf-8
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
# Preset PATH as 'db'


dt_pkgs <- c('RSQLite', 'dplyr', 'data.table', 'snow')
sapply(dt_pkgs, function(p) require(p, character.only = TRUE))

if (! 'cl' %in% objects()) cl <- makeCluster(4, type = 'SOCK')
if (! 'db' %in% objects()) db <- 'mj.sqlite3'

con <- dbConnect(dbDriver('SQLite'), db)

sql_base <- 'SELECT
               b.case_id AS case_id,
               suspected,
               dpp4_inhibitor,
               glp1_agonist,
               age,
               sex
             FROM
               base_dt b
             INNER JOIN
               (
                 SELECT
                   case_id,
                   name AS suspected
                 FROM
                   drug
                 WHERE
                   sn == 1
               ) s ON b.case_id == s.case_id;'

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
             WHERE
               case_id IN (
                 SELECT case_id FROM base_dt
               )
             GROUP BY
               a.hlt_code;'

#sql_hist <- 'SELECT DISTINCT
#               case_id,
#               hlt_code
#             FROM
#               hist h
#             INNER JOIN
#               pt_j p ON p.pt_kanji == h.disease
#             INNER JOIN
#               hlt_pt hp ON hp.pt_code == p.pt_code
#             WHERE
#               case_id IN (
#                 SELECT case_id FROM base_dt
#               );'

sql_reac <- 'SELECT DISTINCT
               case_id,
               hlt_code
             FROM
               reac r
             INNER JOIN
               pt_j p ON p.pt_kanji == r.event
             INNER JOIN
               hlt_pt hp ON hp.pt_code == p.pt_code
             WHERE
               case_id IN (
                 SELECT case_id FROM base_dt
               );'

sql_ccmt <- 'SELECT DISTINCT
               case_id,
               name AS drug
             FROM
               drug
             WHERE
               name NOT IN (
                 SELECT DISTINCT drug FROM d_class WHERE class IN ("dpp4_inhibitor", "glp1_agonist")
               ) AND case_id IN (
                 SELECT case_id FROM base_dt
               );'

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
                   ) t2 ON t1.drug == t2.drug
                 ) t12 INNER JOIN (
                   SELECT hlt_code, COUNT(DISTINCT case_id) AS a_c FROM ade10 GROUP BY hlt_code
                 ) t3 ON t12.hlt_code == t3.hlt_code
               ) t123 INNER JOIN (
                 SELECT COUNT(DISTINCT case_id) AS t FROM ade10
               )
             WHERE
               a != 0 AND b != 0 AND c != 0 AND d != 0;'

dt_base <- tbl_dt(data.table(dbGetQuery(con, sql_base)))
dt_hlts <- tbl_dt(data.table(dbGetQuery(con, sql_hlts)))
#dt_hist <- tbl_dt(data.table(dbGetQuery(con, sql_hist)))
dt_reac <- tbl_dt(data.table(dbGetQuery(con, sql_reac)))
dt_ccmt <- tbl_dt(data.table(dbGetQuery(con, sql_ccmt)))
dt_ct22 <- tbl_dt(data.table(dbGetQuery(con, sql_ct22)))

#dt_sgnl <- dt_ct22 %>%
#             mutate(ror_ll95 = exp(log(a * d / c / b) - 1.96 * sqrt(1 / a + 1 / b + 1 / c + 1 / d))) %>%
#             filter(ror_ll95 > 1) %>%
#             select(drug, hlt_code)

fex <- function(t) {
  f <- fisher.test(matrix(t, nrow = 2), alternative = 'two.sided', conf.level = 0.95)
  p_or <- append(c(f$p.value, f$estimate), f$conf.int)
  names(p_or) <- c('p_val', 'f_or', 'f_ll95', 'f_ul95')
  return(p_or)
}

dt_sgnl <- dt_ct22 %>%
             select(a:d) %>%
             parApply(cl, ., 1, fex) %>%
             t() %>%
             cbind(dt_ct22) %>%
             filter(p_val < 0.05, f_or > 1) %>%
             select(drug, hlt_code)

tables()
