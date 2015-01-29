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

pkgs <- c('RSQLite', 'dplyr', 'data.table', 'snow', 'foreach', 'doSNOW', 'parallel', 'Matrix', 'coda', 'ape', 'MCMCglmm')
sapply(pkgs, pload)

select <- dplyr::select
cl <- makeCluster(detectCores(), type = 'SOCK')
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

foreach (code = hlt_codes, .packages = pkgs) %dopar% {
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
