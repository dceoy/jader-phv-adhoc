#!/usr/bin/env R

pload <- function(p) {
  if (! p %in% installed.packages()[,1]) install.packages(p, dependencies = TRUE)
  require(p, character.only = TRUE)
}

r <- getOption('repos')
r['CRAN'] <- 'http://cran.us.r-project.org'
options(repos = r)
rm(r)

pkgs <- c('RSQLite', 'dplyr', 'data.table', 'snow', 'foreach', 'doSNOW', 'parallel', 'yaml')
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

stdout_path <- 'output/dm_log.txt'
csv_path <- 'output/dm_or.csv'
cat('', file = stdout_path)
cat('', file = csv_path)

hlt_codes <- yaml.load_file('hlts.yml')$glm

foreach (code = hlt_codes, .packages = pkgs) %dopar% {
  hlt <- dt_hlts %>% filter(hlt_code == code)
  reac <- dt_reac %>% filter(hlt_code == code)
  hist <- dt_hist %>% filter(hlt_code == code)
  sgnl <- dt_sgnl %>% filter(hlt_code == code)
  ccmt <- dt_ccmt %>%
            filter(drug %in% sgnl$drug) %>%
            group_by(case_id) %>%
            summarize(concomit = n())
  hlt <- hlt %>% mutate(case_count = nrow(reac))

  dt <- dt_base %>%
          left_join(ccmt, by = 'case_id') %>%
          mutate(concomit = as.integer(ifelse(is.na(concomit), 0, concomit))) %>%
          mutate(preexist = as.integer(ifelse(case_id %in% hist$case_id, 1, 0))) %>%
          mutate(event = as.integer(ifelse(case_id %in% reac$case_id, 1, 0))) %>%
          mutate(incretin = as.integer(ifelse(dpp4_inhibitor + glp1_agonist > 0, 1, 0))) %>%
          select(event, incretin, concomit, preexist, age, sex)

  lr <- glm(event ~ incretin +
                    concomit +
                    preexist +
                    age +
                    sex,
            data = dt, family = binomial)

  s <- summary(lr)

  alpha <- 0.01
  orci <- exp(cbind(OR = s$coefficient[,1],
                    confint.default(lr, level = 1 - alpha)))

  out <- list(event = t(hlt), summary = s, or_wald_ci = orci, association = '')

  if (orci[2,2] > 1) {
    out$association <- 'significant'
    write.table(matrix(c(orci[2,], hlt), nrow = 1), file = csv_path,
                append = TRUE, sep = ',', row.names = FALSE, col.names = FALSE)
  }

  sink(stdout_path, append = TRUE)
    print(out)
  sink()
}
