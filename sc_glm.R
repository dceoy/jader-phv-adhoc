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


stdout_path <- paste('output/sc_glm_', gsub('[ :]', '-', Sys.time()), '.txt', sep = '')
signal_path <- 'output/sc_glm_signal.txt'
or_csv_path <- 'output/sc_glm_orci.csv'
cat('glm\n', file = stdout_path)
cat('glm signal\n', file = signal_path)
dt_orci <- data.table()

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

  fit <- glm(event ~ incretin +
                     concomit +
                     age +
                     sex,
             data = dt, family = binomial)

  s <- summary(fit)
  ci <- confint(fit, level = 0.99)
  ors <- exp(cbind(s$coefficients[,1], ci[,1:2]))
  colnames(ors) <- c('OR', 'LL', 'UL')
  p <- list(event = t(hlt),
            summary = s,
            odds_ratio = ors)

  sink(file = stdout_path, append = TRUE)
    cat('\n\n\n')
    print(p)
  sink()
  if (ors[2,2] > 1) {
    p <- list(p,
              incretin_or = paste('HLT', hlt$hlt_code, ';', ors[2,1], '[', ors[2,2], '-', ors[2,3], ']'),
              count = hlt$case_count,
              hlt = paste(hlt$hlt_name, hlt$hlt_kanji))

    sink(file = signal_path, append = TRUE)
      cat('\n\n\n')
      print(p)
    sink()

    dt_orci <- dt_orci %>% rbind(c(ors[2,], c(hlt)))
  }
}

write.csv(dt_orci, file = or_csv_path, row.names = FALSE)
