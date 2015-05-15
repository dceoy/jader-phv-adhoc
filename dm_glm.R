#!/usr/bin/env Rscript

source('func.R')

if (file.exists(data_path <- 'output/rdata/dm_tbl.Rdata')) {
  load(data_path)
} else {
  source('dm_tbl.R')
}

cat('', file = log_path <- 'output/log/dm_log.txt')
cat('', file = csv_path <- 'output/csv/dm_or.csv')
codes <- yaml.load_file('hlts.yml')$glm

foreach (code = codes, .packages = c('dplyr', 'data.table')) %dopar% {
  hlt <- dt_hlts %>% filter(hlt_code == code)
  reac <- dt_reac %>% filter(hlt_code == code)
  sgnl <- dt_sgnl %>% filter(hlt_code == code)
  ccmt <- dt_ccmt %>%
            filter(drug %in% sgnl$drug) %>%
            group_by(case_id) %>%
            summarize(concomit = n())
  hlt <- hlt %>% mutate(case_count = nrow(reac))

  dt <- dt_base %>%
          left_join(ccmt, by = 'case_id') %>%
          mutate(event = as.factor(ifelse(case_id %in% reac$case_id, 1, 0))) %>%
          mutate(incretin = as.factor(ifelse(dpp4_inhibitor + glp1_agonist > 0, 1, 0))) %>%
          mutate(concomit = as.integer(ifelse(is.na(concomit), 0, concomit))) %>%
          mutate(age = as.integer(age)) %>%
          mutate(sex = as.factor(sex)) %>%
          select(event, incretin, concomit, age, sex)

  lr <- glm(event ~ incretin + concomit + age + sex, data = dt, family = binomial)

  alpha <- 0.01

  out <- list(event = t(hlt),
              summary = summary(lr),
              or_wald_ci = exp(cbind(OR = lr$coefficients,
                                     confint.default(lr, level = 1 - alpha))))

  if (out$or_wald_ci[2,2] > 1) {
    out$association <- 'significant'
    write.table(matrix(c(out$or_wald_ci[2,], hlt), nrow = 1),
                file = csv_path, append = TRUE, sep = ',', row.names = FALSE, col.names = FALSE)
  }

  sink(log_path, append = TRUE)
  print(out)
  sink()
}
