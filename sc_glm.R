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
source('sc_tables.R')


out_path <- paste('output/sc_glm_', gsub('[ :]', '-', Sys.time()), '.txt', sep = '')
cat('glm\n', file = out_path)

foreach (code = dt_hlts$hlt_code, .packages = pkgs) %dopar% {
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
          mutate(event = as.integer(ifelse(case_id %in% reac$case_id, 1, 0)))

  e <- try(fit <- glm(event ~ incretin +
                              concomit +
                              age +
                              sex,
                      data = dt, family = binomial),
           silent = FALSE)

  sink(file = out_path, append = TRUE)
    if (class(e) != 'try-error') {
      s <- summary(fit)
      ci <- confint(fit, level = 0.95)
      ors <- exp(cbind(s$coefficients[,1], ci[,1:2]))
      colnames(ors) <- c('OR', 'LL95', 'UL95')
      cat('\n\n\n')
      print(t(hlt))
      cat('\n')
      print(s)
      cat('\nOdds Ratio\n')
      print(ors)
    } else {
      cat('\n\n\n')
      print(t(hlt))
      cat('\nERROR\n\n')
      warning()
    }
  sink()
}
