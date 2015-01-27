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


pload <- function(p) {
  if (! p %in% installed.packages()[,1]) install.packages(p, dependencies = TRUE)
  require(p, character.only = TRUE)
}

r <- getOption('repos')
r['CRAN'] <- 'http://cran.us.r-project.org'
options(repos = r)
rm(r)

pkgs <- c('RSQLite', 'plyr', 'dplyr', 'data.table', 'snow', 'foreach', 'doSNOW', 'MASS', 'coda', 'MCMCpack')
sapply(pkgs, pload)

select <- dplyr::select
cl <- makeCluster(4, type = 'SOCK')
registerDoSNOW(cl)
.Last <- function() stopCluster(cl)
db <- 'mj.sqlite3'

source('tables.R')
#      NAME       NROW NCOL MB
# [1,] dt_base   6,442    6  1
# [2,] dt_ccmt  52,238    2  2
# [3,] dt_ct22 317,022    6  9
# [4,] dt_hist  30,776    2  1
# [5,] dt_hlts     706    4  1
# [6,] dt_reac  13,345    2  1
# [7,] dt_sgnl  69,059    2  2

out_path <- paste('output/glm_', gsub('[ :]', '-', Sys.time()), '.txt', sep = '')
cat('mcmcpack\n', file = out_path)

foreach (code = dt_hlts$hlt_code, .packages = pkgs) %dopar% {
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
          mutate(event = ifelse(case_id %in% reac$case_id, 1, 0))

  e <- try(p <- MCMClogit(event ~ dpp4_inhibitor +
                                  glp1_agonist +
                                  concomit +
                                  preexist +
                                  age +
                                  sex,
                          data = dt, burnin = 500, mcmc = 5000),
           silent = FALSE)

  if (class(e) != 'try-error') {
    sink(file = out_path, append = TRUE)
      cat('\n\n\n')
      print(t(hlt))
      cat('\n')
      s <- summary(p, quantiles = c(0.025, 0.5, 0.975))
      print(s)
      cat('\nOdds Ratio\n')
      print(exp(s$quantiles))
    sink()
  } else {
    sink(file = out_path, append = TRUE)
      cat('\n\n\n')
      print(t(hlt))
      cat('\nERROR\n\n')
      warning()
    sink()
  }
}
