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

pkgs <- c('RSQLite', 'plyr', 'dplyr', 'data.table', 'snow', 'foreach', 'doSNOW', 'rstan')
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
          mutate(event = ifelse(case_id %in% reac$case_id, 1, 0)) %>%
          select(event, dpp4_inhibitor, glp1_agonist, concomit, age, sex)

  ae_dat <- list(
                 N = dt %>% nrow(),
                 M = dt %>% ncol() - 1,
                 y = dt %>% .$event,
                 x = dt %>% select(- event)
#                N.suspected = dt %>% distinct(suspected) %>% nrow(),
#                sigma = c(15, 10, 16, 11,  9, 11, 10, 18)
                 )

  stanfit <- stan(file = 'ae.stan', data = ae_dat, iter = 1000, chains = 4)
# fit <- stan(model_code = stan_code, data = ae_dat, iter = 1000, chains = 4)

  traceplot(stanfit)
# y <- dt %>% select(event) %>% as.vector()
# x1 <- dt %>% select(dpp4_inhibitor) %>% as.vector()
# x2 <- dt %>% select(glp1_agonist) %>% as.vector()
# x3 <- dt %>% select(concomit) %>% as.vector()
# x4 <- dt %>% select(age) %>% as.vector()
# x5 <- dt %>% select(sex) %>% as.vector()
# N <- dt %>% nrow() %>% as.numeric()
# N.suspected <- dt %>% distinct(suspected) %>% nrow() %>% as.numeric()
# s_tab <- dt %>% distinct(suspected) %>% mutate(s_id = 1:N.suspected) %>% select(suspected, s_id)
# si <- dt %>% inner_join(s_tab, by = 'suspected') %>% select(s_id) %>% as.vector()

# data <- list('y', 'x1', 'x2', 'x3', 'x4', 'x5', 'N', 'N.suspected', 'si')
# params <- c('p', 'b0', 'b1', 'b2', 'b3', 'b4', 'b5', 'rr', 'rs', 'sigma')

# inits <- function() {
#   list(b0 = 0,
#        b1 = 0,
#        b2 = 0,
#        b3 = 0,
#        b4 = 0,
#        b5 = 0,
#        sigma = 1)
# }

# sim <- bugs(data, inits = NULL, params, model_file, n.iter = 1000)

# print(sim)
# plot(sim)
}
