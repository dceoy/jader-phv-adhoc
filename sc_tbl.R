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
# Preset DATABASE PATH as 'db'


dt_pkgs <- c('RSQLite', 'dplyr', 'data.table', 'snow')
sapply(dt_pkgs, function(p) require(p, character.only = TRUE))

if (! 'cl' %in% objects()) cl <- makeCluster(4, type = 'SOCK')
if (! 'db' %in% objects()) db <- 'mj.sqlite3'

con <- dbConnect(dbDriver('SQLite'), db)

sql_base <- 'SELECT
               d.case_id AS case_id,
               suspected,
               quarter,
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
                     SELECT DISTINCT drug FROM d_class WHERE class IN ("dpp4_inhibitor", "glp1_agonist")
                   )
                 ) THEN 1
                 ELSE 0
               END AS incretin
             FROM
               demo d
             INNER JOIN
               (
                 SELECT
                   case_id,
                   name AS suspected
                 FROM
                   drug
                 WHERE
                   sn == 1
               ) s ON s.case_id == d.case_id
             WHERE
              age LIKE "%0歳%" AND
              sex IN ("男性", "女性") AND
              d.case_id IN (
                SELECT DISTINCT case_id FROM ade10
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

sql_hist <- 'SELECT DISTINCT
               case_id,
               hlt_code
             FROM
               hist h
             INNER JOIN
               pt_j p ON p.pt_kanji == h.disease
             INNER JOIN
               hlt_pt hp ON hp.pt_code == p.pt_code
             WHERE
               case_id IN (
                 SELECT DISTINCT case_id FROM ade10
               );'

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

dt_base <- tbl_dt(data.table(dbGetQuery(con, sql_base)))
dt_hlts <- tbl_dt(data.table(dbGetQuery(con, sql_hlts)))
dt_reac <- tbl_dt(data.table(dbGetQuery(con, sql_reac)))
dt_hist <- tbl_dt(data.table(dbGetQuery(con, sql_hist)))
dt_ccmt <- tbl_dt(data.table(dbGetQuery(con, sql_ccmt)))
dt_sgnl <- tbl_dt(data.table(dbGetQuery(con, sql_sgnl)))

dt_hlts <- dt_base %>%
             filter(incretin == 1) %>%
             inner_join(dt_reac, by = 'case_id') %>%
             distinct(hlt_code) %>%
             select(hlt_code) %>%
             inner_join(dt_hlts, by = 'hlt_code')

dt_reac <- dt_reac %>% filter(case_id %in% dt_base$case_id, hlt_code %in% dt_hlts$hlt_code)
dt_hist <- dt_hist %>% filter(case_id %in% dt_base$case_id, hlt_code %in% dt_hlts$hlt_code)
dt_ccmt <- dt_ccmt %>% filter(case_id %in% dt_base$case_id)

dt_base <- dt_base %>%
             mutate(age = as.integer(age)) %>%
             mutate(sex = as.integer(sex)) %>%
             mutate(incretin = as.integer(incretin))

fex <- function(t) {
  f <- fisher.test(matrix(t, nrow = 2), alternative = 'two.sided', conf.level = 0.99)
  p_or <- append(c(f$p.value, f$estimate), f$conf.int)
  names(p_or) <- c('p_val', 'or_mle', 'or_ll', 'or_ul')
  return(p_or)
}

dt_sgnl <- dt_sgnl %>%
             select(a:d) %>%
             parApply(cl, ., 1, fex) %>%
             t() %>%
             cbind(dt_sgnl) %>%
             filter(p_val < 0.01, or_mle > 1) %>%
             select(drug, hlt_code)

tables()
#      NAME       NROW NCOL MB COLS                                       KEY
# [1,] dt_base 165,779    6 15 case_id,suspected,quarter,age,sex,incretin
# [2,] dt_ccmt 850,878    2 23 case_id,drug
# [3,] dt_hist 427,258    2 12 case_id,hlt_code
# [4,] dt_hlts     703    4  1 hlt_code,hlt_name,hlt_kanji,case_count     hlt_code
# [5,] dt_reac 367,474    2 13 case_id,hlt_code
# [6,] dt_sgnl  40,010    2  1 drug,hlt_code
# Total: 65MB

save.image('output/sc_tbl.Rdata')
