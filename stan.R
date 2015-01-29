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

pkgs <- c('RSQLite', 'dplyr', 'data.table', 'snow', 'foreach', 'doSNOW', 'parallel', 'rstan')
sapply(pkgs, pload)

select <- dplyr::select
cl <- makeCluster(detectCores(), type = 'SOCK')
registerDoSNOW(cl)
.Last <- function() stopCluster(cl)
db <- 'mj.sqlite3'
source('tables.R')

out_path <- paste('output/stan_', gsub('[ :]', '-', Sys.time()), '.txt', sep = '')
cat('stan\n', file = out_path)

hlt_codes <- c('10033632')  # 10033632  膵新生物  Pancreatic neoplasms

st_model <- stan_model(file = 'ae.stan')

foreach (code = hlt_codes) %do% {
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
          select(event, dpp4_inhibitor, glp1_agonist, concomit, age, sex, suspected)

  ae_dat <- list(N = dt %>% nrow(),
                 M = 5,
                 L = dt %>% distinct(suspected) %>% nrow(),
                 y = dt %>% .$event,
                 x = dt %>% select(dpp4_inhibitor, glp1_agonist, concomit, age, sex),
                 g = dt %>%
                       distinct(suspected) %>%
                       mutate(s_id = 1:nrow(.)) %>%
                       select(suspected, s_id) %>%
                       inner_join(dt, by = 'suspected') %>%
                       .$s_id)

# stanfit <- sampling(object = st_model, data = ae_dat, iter = 1000, chains = 4)
  sflist <- foreach(i = 1:4, .packages = 'rstan') %dopar% {
              sampling(object = st_model, data = ae_dat, iter = 100000, chains = 1, chain_id = i, refresh = -1)
            }
  stanfit <- sflist2stanfit(sflist)

  traceplot(stanfit)
  sink(file = out_path, append = TRUE)
    cat('\n\n\n')
    print(t(hlt))
    cat('\n')
    print(stanfit)
  sink()
}
