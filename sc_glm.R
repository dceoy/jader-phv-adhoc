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

db <- 'mj.sqlite3'
source('sc_tbl.R')
#      NAME       NROW NCOL MB COLS                                   KEY
# [1,] dt_base 165,779    5 14 case_id,suspected,age,sex,incretin
# [2,] dt_ccmt 850,878    2 23 case_id,drug
# [3,] dt_hist 427,258    2 12 case_id,hlt_code
# [4,] dt_hlts     703    4  1 hlt_code,hlt_name,hlt_kanji,case_count hlt_code
# [5,] dt_reac 367,474    2 13 case_id,hlt_code
# [6,] dt_sgnl  70,930    2  2 drug,hlt_code
# Total: 65MB

stdout_path <- paste('output/sc_glm_', gsub('[ :]', '-', Sys.time()), '.txt', sep = '')
signal_path <- 'output/sc_glm_signal.txt'
csv_path <- 'output/sc_glm_orci.csv'
cat('glm\n', file = stdout_path)
cat('glm signal\n', file = signal_path)
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

  fit <- glm(event ~ incretin +
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
    sink(file = signal_path, append = TRUE)
      cat('\n\n\n')
      print(out)
    sink()

    write.table(matrix(c(ors[2,], hlt), nrow = 1), file = csv_path, append = TRUE, sep = ',', row.names = FALSE, col.names = FALSE)
  }
}
