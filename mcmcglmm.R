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

ps <- c('RSQLite', 'plyr', 'dplyr', 'data.table', 'snow', 'foreach', 'doSNOW', 'Matrix', 'coda', 'ape', 'MCMCglmm')
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

hlt_codes <- c('10021001',
               '10033646',
               '10033632',
               '10033633')
# -- 10021001 低血糖状態ＮＥＣ  Hypoglycaemic conditions NEC
# -- 10033646 急性および慢性膵炎  Acute and chronic pancreatitis
# -- 10033632 膵新生物  Pancreatic neoplasms
# -- 10033633 悪性膵新生物（膵島細胞腫瘍およびカルチノイドを除く）  Pancreatic neoplasms malignant (excl islet cell and carcinoid)

out_path <- paste('output/glmm_', gsub('[ :]', '-', Sys.time()), '.txt', sep = '')
cat('mcmcglmm\n', file = out_path)

foreach (code = hlt_codes, .packages = ps) %dopar% {
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
          mutate(event = ifelse(case_id %in% reac$case_id, 1, 0))

  e <- try(p <- MCMCglmm(fixed = event ~ dpp4_inhibitor +
                                         glp1_agonist +
                                         concomit +
                                         age +
                                         sex,
                         random = ~ suspected,
                         family = 'categorical', data = dt,
                         nitt = 300000, burnin = 100000),
           silent = FALSE)

  if (class(e) != 'try-error') {
    pdf(paste('img/hlt', code, '.pdf', sep = ''))
      plot(p)
    dev.off()

    sink(file = out_path, append = TRUE)
      cat('\n\n\n')
      print(t(hlt))
      cat('\n')
      print(summary(p))
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
