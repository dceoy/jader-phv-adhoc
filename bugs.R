# coding: utf-8


pload <- function(p) {
  if (! p %in% installed.packages()[,1]) install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}

r <- getOption('repos')
r['CRAN'] <- 'http://cran.us.r-project.org'
options(repos = r)
rm(r)

ps <- c('RSQLite', 'plyr', 'dplyr', 'data.table', 'snow', 'Rmpi', 'foreach', 'doSNOW', 'R2OpenBUGS')
names(ps) <- ps
sapply(ps, pload)

select <- dplyr::select

driver <- dbDriver('SQLite')
db <- 'mj.sqlite3'
con <- dbConnect(driver, db)


sql_base <- 'SELECT
               b.case_id AS case_id,
               suspected,
               dpp4_inhibitor,
               glp1_agonist,
               sglt2_inhibitor +
               alpha_glucosidase_inhibitor +
               biguanide +
               meglitinide +
               sulfonylurea +
               thiazolidinedione AS oral_hypoglycemic_drug,
               insulin,
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
                 SELECT case_id FROM base_dt
               );'

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
                 SELECT DISTINCT drug FROM d_class
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
dt_hist <- tbl_dt(data.table(dbGetQuery(con, sql_hist)))
dt_reac <- tbl_dt(data.table(dbGetQuery(con, sql_reac)))
dt_ccmt <- tbl_dt(data.table(dbGetQuery(con, sql_ccmt)))
dt_ct22 <- tbl_dt(data.table(dbGetQuery(con, sql_ct22)))

fex <- function(t) {
  f <- fisher.test(matrix(t, nrow = 2), alternative = 'two.sided', conf.level = 0.95)
  p_or <- append(c(f$p.value, f$estimate), f$conf.int)
  names(p_or) <- c('p_val', 'f_or', 'f_ll95', 'f_ul95')
  return(p_or)
}

dt_sgnl <- dt_ct22 %>%
             mutate(ror_ll95 = exp(log(a * d / c / b) - 1.96 * sqrt(1 / a + 1 / b + 1 / c + 1 / d))) %>%
             filter(ror_ll95 > 1) %>%
             select(drug, hlt_code)

#cl <- makeCluster(4, type = "MPI")
#
#dt_sgnl <- cl %>%
#             parApply(select(dt_ct22, a:d), 1, fex) %>%
#             t() %>%
#             cbind(dt_ct22) %>%
#             filter(p_val < 0.05, f_or > 1) %>%
#             select(drug, hlt_code)
#
#stopCluster(cl)

registerDoSNOW(makeCluster(4, type = 'SOCK'))
pkgs = c('data.table', 'plyr', 'dplyr', 'MASS', 'boot', 'coda', 'R2OpenBUGS')

cat('', file = 'out.txt')


hlt_codes <- c('10021001',
               '10033646',
               '10033632',
               '10033633')

# -- 10021001 低血糖状態ＮＥＣ  Hypoglycaemic conditions NEC
# -- 10033646 急性および慢性膵炎  Acute and chronic pancreatitis
# -- 10033632 膵新生物  Pancreatic neoplasms
# -- 10033633 悪性膵新生物（膵島細胞腫瘍およびカルチノイドを除く）  Pancreatic neoplasms malignant (excl islet cell and carcinoid)


model.file <- file.path(getwd(), "model.bugs") 
write.model(model, model.file)


foreach (code = hlt_codes, .packages = pkgs) %do% {
  hlt <- dt_hlts %>% filter(hlt_code == code)
  hist <- dt_hist %>% filter(hlt_code == code)
  reac <- dt_reac %>% filter(hlt_code == code)
  sgnl <- dt_sgnl %>% filter(hlt_code == code)
  ccmt <- dt_ccmt %>%
            filter(drug %in% sgnl$drug) %>%
            group_by(case_id) %>%
            summarize(concomit = n())

  dt <- dt_base %>%
          left_join(ccmt, by = 'case_id') %>%
          mutate(concomit = ifelse(is.na(concomit), 0, concomit)) %>%
          mutate(preexist = ifelse(case_id %in% hist$case_id, 1, 0)) %>%
          mutate(event = ifelse(case_id %in% reac$case_id, 1, 0)) %>%
          mutate(suspected = )


  data <- list("N", "y")
  params <- c("q")
  inits <- function() { list(q = 0.5) }
  out <- bugs(data, inits, params, model.file, n.iter = 10000)












  e <- try(posterior <- MCMClogit(event ~ dpp4_inhibitor +
                                          glp1_agonist +
                                          sglt2_inhibitor +
                                          sulfonylurea +
                                          meglitinide +
                                          alpha_glucosidase_inhibitor +
                                          biguanide +
                                          thiazolidinedione +
                                          insulin +
                                          concomit +
                                          preexist +
                                          age +
                                          sex,
                                  data = dt, burnin = 500, mcmc = 5000),
           silent = FALSE)

  if (class(e) != 'try-error') {
    s <- summary(posterior, quantiles = c(0.025, 0.5, 0.975))
    p <- data.frame(s$quantiles)
    p <- p %>% exp()

#   s$hlt <- hlt
    print(summary(posterior, quantiles = c(0.025, 0.5, 0.975)))

    cat('\n\n', file = 'out.txt', append = TRUE)
    cat(paste(hlt, ' ', sep = ''), file = 'out.txt', append = TRUE)
    cat('\n\n', file = 'out.txt', append = TRUE)
    write.table(p, file = 'out.txt', sep = '\t', append = TRUE)

#   lr <- glm(event ~ dpp4_inhibitor +
#                     glp1_agonist +
#                     sglt2_inhibitor +
#                     sulfonylurea +
#                     meglitinide +
#                     alpha_glucosidase_inhibitor +
#                     biguanide +
#                     thiazolidinedione +
#                     insulin +
#                     concomit +
#                     preexist +
#                     age +
#                     sex,
#             data = dt, family = binomial)
#   print(lr)
  }
}
