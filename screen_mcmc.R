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
  if (! p %in% installed.packages()[,1]) install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}

r <- getOption('repos')
r['CRAN'] <- 'http://cran.us.r-project.org'
options(repos = r)
rm(r)

ps <- c('RSQLite', 'plyr', 'dplyr', 'data.table', 'snow', 'foreach', 'doSNOW', 'MASS', 'coda', 'MCMCpack')
names(ps) <- ps
sapply(ps, pload)

select <- dplyr::select
cl <- makeCluster(4, type = 'SOCK')
registerDoSNOW(cl)
.Last <- function() stopCluster(cl)

source('dt_sql.R')
# > tables()
#      NAME       NROW NCOL MB
# [1,] dt_base   6,442    6  1
# [2,] dt_ccmt  52,238    2  2
# [3,] dt_ct22 317,022    6  9
# [4,] dt_hist  30,776    2  1
# [5,] dt_hlts     706    4  1
# [6,] dt_reac  13,345    2  1

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

dt_sgnl <- cl %>%
             parApply(select(dt_ct22, a:d), 1, fex) %>%
             t() %>%
             cbind(dt_ct22) %>%
             filter(p_val < 0.05, f_or > 1) %>%
             select(drug, hlt_code)

out_path <- paste('output/glm_', gsub('[ :]', '-', Sys.time()), '.txt', sep = '')
cat('mcmcpack\n', file = out_path)

foreach (code = dt_hlts$hlt_code, .packages = ps) %dopar% {
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
