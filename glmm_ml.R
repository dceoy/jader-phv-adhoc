#!/usr/bin/env Rscript

ifelse(file.exists(data_file <- 'output/rdata/tables.Rdata'),
       load(data_file),
       source('db_query.R'))
source('func.R')
registerDoSNOW(cl <- makeCluster(parallel::detectCores(), type = 'SOCK'))
.Last <- function() try(stopCluster(cl))

fex <- function(row, alt = 'two.sided', cnf = 0.95) {
  f <- fisher.test(matrix(row, nrow = 2), alternative = alt, conf.level = cnf)
  return(c(row, p_val = f$p.value, or_pe = f$estimate[[1]]))
}

ci_glmm <- function(fit, alpha = 0.05) {
  ci <- cbind(fit$coefficients - qnorm(1 - alpha / 2) * fit$coef.sd,
              fit$coefficients + qnorm(1 - alpha / 2) * fit$coef.sd)
  colnames(ci) <- c(paste((alpha / 2) * 100, '%'), paste((1 - alpha / 2) * 100, '%'))
  return(ci)
}

alpha <- 0.01

tbl$sgnl <- tbl$ct22 %>%
              select(a:d) %>%
              distinct() %>%
              parApply(cl, ., 1, fex) %>%
              t() %>%
              as.data.table() %>%
              inner_join(tbl$ct22, by = c('a', 'b', 'c', 'd')) %>%
              filter(p_val < alpha, or_pe > 1) %>%
              select(drug, hlt_code, a, p_val, or_pe)
v_hltc <- tbl$sgnl %>%
            filter(drug %in% vec$incr) %>%
            distinct(hlt_code) %>%
            .$hlt_code

cat('', file = log_file <- 'output/log/glmm_log.txt')
cat('', file = mm_or_file <- 'output/csv/mixed_or.csv')
cat('', file = fm_or_file <- 'output/csv/fixed_or.csv')
cat('', file = aic_file <- 'output/csv/aic_hlt.csv')

lr_log <- foreach(code = unique(tbl$sgnl$hlt_code), .packages = c('dplyr', 'data.table', 'glmmML')) %dopar% {
  reac <- tbl$reac %>% filter(hlt_code == code)
  sgnl <- tbl$sgnl %>% filter(hlt_code == code)
  ccmt <- tbl$ccmt %>%
            filter(drug %in% sgnl$drug) %>%
            group_by(case_id) %>%
            summarize(concomit = n())
  hlt <- tbl$hlts %>%
           filter(hlt_code == code) %>%
           mutate(total_count = nrow(reac))
  d <- tbl$base %>%
         left_join(ccmt, by = 'case_id') %>%
         mutate(event = as.factor(ifelse(case_id %in% reac$case_id, 1, 0)),
                concomit = as.integer(ifelse(is.na(concomit), 0, concomit))) %>%
         select(event, dpp4i, glp1a, hg, concomit, age, sex, qid)

  lr <- list(event = t(hlt))
  e <- try({
    mm <- glmmML(event ~ dpp4i + glp1a + hg + concomit + age + sex, family = binomial, data = d, cluster = qid)
    fm <- glm(event ~ dpp4i + glp1a + hg + concomit + age + sex, family = binomial, data = d)
    lr <- c(lr, list(data = summary(d),
                     mixed_model = mm,
                     fixed_model = summary(fm),
                     mixed_ci = data.frame(coef = mm$coefficients, ci_glmm(mm, alpha = alpha)),
                     fixed_ci = data.frame(coef = fm$coefficients, confint.default(fm, level = 1 - alpha))))
    if(! is.na(mm$sigma.sd)) {
      write.table(cbind(matrix(c(mm$aic, fm$aic, mm$sigma, mm$sigma.sd), nrow = 1), hlt),
                  file = aic_file, append = TRUE, sep = ',', row.names = FALSE, col.names = FALSE)
      if(code %in% v_hltc) {
        write.table(cbind(exp(lr$mixed_ci[2:3,]), sapply(hlt, function(v) rep(v, 2))),
                    file = mm_or_file, append = TRUE, sep = ',', col.names = FALSE)
        write.table(cbind(exp(lr$fixed_ci[2:3,]), sapply(hlt, function(v) rep(v, 2))),
                    file = fm_or_file, append = TRUE, sep = ',', col.names = FALSE)
      }
    }
  }, silent = FALSE)

  if(class(e) == 'try-error') lr <- c(lr, error = e)
  return(capture.output(print(lr), file = log_file, append = TRUE))
}

save.image('output/rdata/glmm.Rdata')
