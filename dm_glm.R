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

if (file.exists(data_path <- 'output/dm_tbl.Rdata')) {
  load(data_path)
} else {
  db <- 'mj.sqlite3'
  source('dm_tbl.R')
}
#      NAME      NROW NCOL MB COLS                                                          KEY
# [1,] dt_base  6,897    7  1 case_id,suspected,quarter,age,sex,dpp4_inhibitor,glp1_agonist
# [2,] dt_ccmt 55,700    2  2 case_id,drug
# [3,] dt_hist 29,492    2  1 case_id,hlt_code
# [4,] dt_hlts    628    4  1 hlt_code,hlt_name,hlt_kanji,case_count                        hlt_code
# [5,] dt_reac 14,157    2  1 case_id,hlt_code
# [6,] dt_sgnl 70,930    2  2 drug,hlt_code
# Total: 8MB

stdout_path <- 'output/dm_glm_log.txt'
csv_path <- 'output/dm_glm_orci.csv'
cat('glm\n', file = stdout_path)
cat('', file = csv_path)

hlt_codes <- c(10007217, 10008616, 10012655, 10012981, 10017933, 10017988, 10018009, 10020638, 10021001, 10024948, 10027416, 10027692, 10029511, 10029976, 10033646, 10033632, 10033633, 10035098, 10039075, 10039078, 10040768, 10046512, 10052736, 10052738, 10052770)

foreach (code = hlt_codes, .packages = pkgs) %dopar% {
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
          select(event, dpp4_inhibitor, glp1_agonist, concomit, preexist, age, sex)

  fit <- glm(event ~ dpp4_inhibitor +
                     glp1_agonist +
                     concomit +
                     preexist +
                     age +
                     sex,
             data = dt, family = binomial)

  s <- summary(fit)
  ci <- confint(fit, level = 0.99)
  ors <- exp(cbind(s$coefficients[,1], ci[,1:2]))
  colnames(ors) <- c('OR', 'LL', 'UL')
  out <- list(event = t(hlt),
              summary = s,
              odds_ratio = ors,
              hlt = hlt,
              incretin_or = paste('HLT', hlt$hlt_code, ';', ors[2,1], '[', ors[2,2], '-', ors[2,3], ']'))

  sink(file = stdout_path, append = TRUE)
    cat('\n\n\n')
    print(out)
  sink()

  if (ors[2,2] > 1) {
    write.table(matrix(c(ors[2,], hlt), nrow = 1), file = csv_path, append = TRUE, sep = ',', row.names = FALSE, col.names = FALSE)
  }
}
