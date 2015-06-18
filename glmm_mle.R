#!/usr/bin/env Rscript

ifelse(file.exists(data_file <- 'output/rdata/dt.Rdata'), load(data_file), source('prep_dt.R'))
source('func.R')
registerDoSNOW(cl <- makeCluster(detectCores(), type = 'SOCK'))
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

write_or <- function(dt, hlt, file) {
  write.table(cbind(exp(dt), sapply(hlt, function(v) rep(v, 2))), file = file, append = TRUE, sep = ',', col.names = FALSE)
}

alpha <- 0.01

dt_ct22 <- dt_ct22 %>%
             select(a:d) %>%
             distinct() %>%
             parApply(cl, ., 1, fex) %>%
             t() %>%
             as.data.table() %>%
             inner_join(dt_ct22, by = c('a', 'b', 'c', 'd')) %>%
             filter(p_val < alpha, or_pe > 1) %>%
             select(drug, hlt_code, a, p_val, or_pe)
dt_incr <- dt_ct22 %>%
             filter(drug %in% v_incr) %>%
             inner_join(dt_hlts, by = 'hlt_code')
write.table(dt_incr, file = 'output/csv/fex_p.csv', sep = ',', row.names = FALSE, col.names = FALSE)

v_hltc <- unique(dt_incr$hlt_code)
dt_sgnl <- dt_ct22 %>%
             filter(hlt_code %in% v_hltc, ! drug %in% v_incr) %>%
             select(drug, hlt_code)
dt_hlts <- dt_hlts %>% filter(hlt_code %in% v_hltc)
dt_reac <- dt_reac %>% filter(hlt_code %in% v_hltc)
dt_ccmt <- dt_ccmt %>% filter(drug %in% unique(dt_sgnl$drug))

tables()
cat('', file = log_file <- 'output/log/glmm_log.txt')
cat('', file = mm_or_file <- 'output/csv/glmm_or.csv')
cat('', file = fm_or_file <- 'output/csv/glm_or.csv')

foreach(code = v_hltc, .packages = c('dplyr', 'data.table', 'glmmML')) %dopar% {
  reac <- dt_reac %>% filter(hlt_code == code)
  sgnl <- dt_sgnl %>% filter(hlt_code == code)
  ccmt <- dt_ccmt %>%
            filter(drug %in% sgnl$drug) %>%
            group_by(case_id) %>%
            summarize(concomit = n())
  hlt <- dt_hlts %>%
           filter(hlt_code == code) %>%
           mutate(total_count = nrow(reac))
  dt <- dt_base %>%
          left_join(ccmt, by = 'case_id') %>%
          mutate(event = as.factor(ifelse(case_id %in% reac$case_id, 1, 0)),
                 concomit = as.integer(ifelse(is.na(concomit), 0, concomit))) %>%
          select(event, dpp4i, glp1a, hg, concomit, age, sex, qid)

  lr <- list(event = t(hlt))
  e <- try({
    mix <- glmmML(event ~ dpp4i + glp1a + hg + concomit + age + sex, family = binomial, data = dt, cluster = qid, prior = 'gaussian')
    fix <- glm(event ~ dpp4i + glp1a + hg + concomit + age + sex, family = binomial, data = dt)
    lr <- c(lr, list(dt = summary(dt),
                     mixed = mix,
                     fixed = summary(fix),
                     mm_ci = data.frame(coef = mix$coefficients, ci_glmm(mix, alpha = alpha)),
                     fm_ci = data.frame(coef = fix$coefficients, confint.default(fix, level = 1 - alpha))))
    write_or(lr$mm_ci[2:3,], hlt = hlt, file = mm_or_file)
    write_or(lr$fm_ci[2:3,], hlt = hlt, file = fm_or_file)
  }, silent = FALSE)

  if (class(e) == 'try-error') lr <- c(lr, list(error = e))
  write_log(lr, log_file)
  return(lr)
}

save.image('output/rdata/glmm.Rdata')
