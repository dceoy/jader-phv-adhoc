# coding: utf-8


pload <- function(p) {
  if (! p %in% installed.packages()[,1]) install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}

r <- getOption('repos')
r['CRAN'] <- 'http://cran.us.r-project.org'
options(repos = r)
rm(r)

ps <- c('RSQLite', 'plyr', 'dplyr', 'data.table', 'snow', 'Rmpi', 'foreach', 'doSNOW', 'R2OpenBUGS', 'lattice')
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
#dt_sgnl <- cl %>%
#             parApply(select(dt_ct22, a:d), 1, fex) %>%
#             t() %>%
#             cbind(dt_ct22) %>%
#             filter(p_val < 0.05, f_or > 1) %>%
#             select(drug, hlt_code)
#stopCluster(cl)


registerDoSNOW(makeCluster(4, type = 'SOCK'))
pkgs = c('data.table', 'plyr', 'dplyr', 'MASS', 'boot', 'coda', 'R2OpenBUGS', 'lattice')

model <- function() {
  for (i in 1:N) {
    y[i] ~ dbern(p[i])
#   rr[i] ~ dnorm(0, tau[1])
    rr[i] ~ dnorm(0, tau)
#   logit(p[i]) <- b0 + b1 * x1[i] + b2 * x2[i] + b3 * x3[i] + b4 * x4[i] + b5 * x5[i] + rr[i] + rs[si[i]]
    logit(p[i]) <- b0 + b1 * x1[i] + rr[i]
  }
  sigma ~ dunif(0, 1.0E+4)
  tau <- pow(sigma, -2)
# b0 ~ dnorm(0, 1.0E-4) # intercept
# b1 ~ dnorm(0, 1.0E-4) # dpp4_inihibitor
# b2 ~ dnorm(0, 1.0E-4) # glp1_agonist
# b3 ~ dnorm(0, 1.0E-4) # concomit
# b4 ~ dnorm(0, 1.0E-4) # age
# b5 ~ dnorm(0, 1.0E-4) # sex
# for (j in 1:N.suspected) {
#   rs[j] ~ dnorm(0, tau[2])
# }
# for (m in 1:2) {
#   sigma[m] ~ dunif(0, 1.0E+4)
#   tau[m] <- pow(sigma[m], -2)
# }
}
model_file <- file.path(tempdir(), 'model.txt')
write.model(model, model_file)

hlt_codes <- c('10033632')  # 10033632  膵新生物  Pancreatic neoplasms

foreach (code = hlt_codes, .packages = pkgs) %do% {
  hlt <- dt_hlts %>% filter(hlt_code == code)
  reac <- dt_reac %>% filter(hlt_code == code)
  sgnl <- dt_sgnl %>% filter(hlt_code == code)
  ccmt <- dt_ccmt %>%
            filter(drug %in% sgnl$drug) %>%
            group_by(case_id) %>%
            summarize(concomit = n())

  dt <- dt_base %>%
          left_join(ccmt, by = 'case_id') %>%
          mutate(concomit = ifelse(is.na(concomit), 0, concomit)) %>%
          mutate(event = ifelse(case_id %in% reac$case_id, 1, 0))

  y <- dt %>% select(event) %>% as.vector()
  x1 <- dt %>% select(dpp4_inhibitor) %>% as.vector()
  x2 <- dt %>% select(glp1_agonist) %>% as.vector()
  x3 <- dt %>% select(concomit) %>% as.vector()
  x4 <- dt %>% select(age) %>% as.vector()
  x5 <- dt %>% select(sex) %>% as.vector()
  N <- dt %>% nrow() %>% as.numeric()
  N.suspected <- dt %>% distinct(suspected) %>% nrow() %>% as.numeric()
  s_tab <- dt %>% distinct(suspected) %>% mutate(s_id = 1:N.suspected) %>% select(suspected, s_id)
  si <- dt %>% inner_join(s_tab, by = 'suspected') %>% select(s_id) %>% as.vector()


  #data <- list('y', 'x1', 'x2', 'x3', 'x4', 'x5', 'N', 'N.suspected', 'si')
  data <- list('y', 'x1', 'N')

# params <- c('p', 'b0', 'b1', 'b2', 'b3', 'b4', 'b5', 'rr', 'rs', 'sigma')
  params <- c('p', 'b0', 'b1', 'rr', 'sigma')

# inits <- function() {
#   list(b0 = 0,
#        b1 = 0,
#        b2 = 0,
#        b3 = 0,
#        b4 = 0,
#        b5 = 0,
#        sigma = 1)
# }

  sim <- bugs(data, inits = NULL, params, model_file, n.iter = 1000)

  print(sim)
  plot(sim)
}
