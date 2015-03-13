#!/usr/bin/env R
#
#                event
#              +       -
#          +-------+-------+
#        + |   a   |   b   | a + b
#  drug    +-------+-------+
#        - |   c   |   d   | c + d
#          +-------+-------+
#            a + c   b + d


pload <- function(p) {
  if (! p %in% installed.packages()[,1]) install.packages(p, dependencies = TRUE)
  require(p, character.only = TRUE)
}

r <- getOption('repos')
r['CRAN'] <- 'http://cran.us.r-project.org'
options(repos = r)
rm(r)

pkgs <- c('RSQLite', 'dplyr', 'data.table', 'snow', 'foreach', 'doSNOW', 'parallel')
sapply(pkgs, pload)

select <- dplyr::select
cl <- makeCluster(detectCores(), type = 'SOCK')
registerDoSNOW(cl)
.Last <- function() stopCluster(cl)

if (file.exists(data_path <- 'output/sc_tbl.Rdata')) {
  load(data_path)
} else {
  db <- 'mj.sqlite3'
  source('sc_tbl.R')
}
#      NAME       NROW NCOL MB COLS                                       KEY
# [1,] dt_base 165,779    6 15 case_id,suspected,quarter,age,sex,incretin
# [2,] dt_ccmt 850,878    2 23 case_id,drug
# [3,] dt_hist 427,258    2 12 case_id,hlt_code
# [4,] dt_hlts     703    4  1 hlt_code,hlt_name,hlt_kanji,case_count     hlt_code
# [5,] dt_reac 367,474    2 13 case_id,hlt_code
# [6,] dt_sgnl  38,346    2  1 drug,hlt_code
# Total: 65MB

stdout_path <- 'output/sc_glm_log.txt'
csv_path <- 'output/sc_glm_orci.csv'
cat('glm\n', file = stdout_path)
cat('', file = csv_path)

foreach (code = dt_hlts$hlt_code, .packages = pkgs) %dopar% {
  hlt <- dt_hlts %>% filter(hlt_code == code)
  reac <- dt_reac %>% filter(hlt_code == code)
  hist <- dt_hist %>% filter(hlt_code == code)
  sgnl <- dt_sgnl %>% filter(hlt_code == code)
  ccmt <- dt_ccmt %>%
            filter(drug %in% sgnl$drug) %>%
            group_by(case_id) %>%
            summarize(concomit = n())

  dt <- dt_base %>%
          left_join(ccmt, by = 'case_id') %>%
          mutate(concomit = as.integer(ifelse(is.na(concomit), 0, concomit))) %>%
          mutate(preexist = as.integer(ifelse(case_id %in% hist$case_id, 1, 0))) %>%
          mutate(event = as.integer(ifelse(case_id %in% reac$case_id, 1, 0))) %>%
          select(event, incretin, concomit, preexist, age, sex)

  lr <- glm(event ~ incretin +
                    concomit +
                    preexist +
                    age +
                    sex,
            data = dt, family = binomial)

  s <- summary(lr)

  alpha <- 0.01
  qn <- qnorm(1 - alpha / 2, 0, 1)
  ce <- s$coefficient
  or_wald <- exp(data.table(OR = ce[,1],
                            LL = ce[,1] - qn * ce[,2],
                            UL = ce[,1] + qn * ce[,2]))

  out <- list(event = t(hlt),
              summary = s,
              or_wald_ci = or_wald,
              hlt = hlt)

  if (or_wald[2,2] > 1) {
    write.table(matrix(c(or_wald[2,], hlt), nrow = 1),
                file = csv_path, append = TRUE,
                sep = ',', row.names = FALSE, col.names = FALSE)

    plci <- confint(lr, level = 1 - alpha)
    or_pl <- exp(data.table(OR = ce[,1],
                            LL = plci[,1],
                            UL = plci[,2]))

    out <- list(out, or_profile_likelihood_ci = or_pl)
  }

  sink(stdout_path, append = TRUE)
    cat('\n\n\n')
    print(out)
  sink()
}
