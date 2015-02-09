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

pkgs <- c('RSQLite', 'dplyr', 'data.table', 'snow', 'foreach', 'doSNOW', 'parallel', 'rstan')
sapply(pkgs, pload)

select <- dplyr::select
cl <- makeCluster(detectCores(), type = 'SOCK')
registerDoSNOW(cl)
.Last <- function() stopCluster(cl)

db <- 'mj.sqlite3'
source('dm_tbl.R')
#      NAME      NROW NCOL MB COLS                                                  KEY
# [1,] dt_base  6,897    6  1 case_id,suspected,age,sex,dpp4_inhibitor,glp1_agonist
# [2,] dt_ccmt 55,700    2  2 case_id,drug
# [3,] dt_hist 29,492    2  1 case_id,hlt_code
# [4,] dt_hlts    628    4  1 hlt_code,hlt_name,hlt_kanji,case_count
# [5,] dt_reac  8,011    2  1 case_id,hlt_code
# [6,] dt_sgnl 70,930    2  2 drug,hlt_code
# Total: 8MB

out_path <- paste('output/stan_', gsub('[ :]', '-', Sys.time()), '.txt', sep = '')
cat('stan\n', file = out_path)

hlt_codes <- c('10033632')  # 10033632  膵新生物  Pancreatic neoplasms

st_model <- stan_model(file = 'ae.stan')

foreach (code = hlt_codes) %do% {
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
          select(event, dpp4_inhibitor, glp1_agonist, concomit, preexist, age, sex, suspected)

  ae_dat <- list(N = dt %>% nrow(),
                 M = 6,
                 L = dt %>% distinct(suspected) %>% nrow(),
                 y = dt$event,
                 x = dt %>% select(dpp4_inhibitor, glp1_agonist, concomit, preexist, age, sex),
                 g = dt %>%
                       distinct(suspected) %>%
                       mutate(s_id = 1:nrow(.)) %>%
                       select(suspected, s_id) %>%
                       inner_join(dt, by = 'suspected') %>%
                       .$s_id)

# stanfit <- sampling(object = st_model, data = ae_dat, iter = 1000, chains = 4)
  sflist <- foreach(i = 1:4, .packages = 'rstan') %dopar% {
              sampling(object = st_model, data = ae_dat, iter = 1000, chains = 1, chain_id = i, refresh = -1)
            }
  stanfit <- sflist2stanfit(sflist)

  traceplot(stanfit)

  out <- list(event = t(hlt),
              stanfit = stanfit)

  sink(file = out_path, append = TRUE)
    cat('\n\n\n')
    print(out)
  sink()
}
