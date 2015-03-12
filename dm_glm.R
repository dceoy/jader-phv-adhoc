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

if (file.exists(data_path <- 'output/dm_tbl.Rdata')) {
  load(data_path)
} else {
  db <- 'mj.sqlite3'
  source('dm_tbl.R')
}
#      NAME      NROW NCOL MB COLS                                                          KEY
# [1,] dt_base  6,897    7  1 case_id,suspected,quarter,age,sex,dpp4_inhibitor,glp1_agonist
# [2,] dt_ccmt 55,700    2  2 case_id,drug
# [3,] dt_hist 29,492    2  1 case_id,hlt_code
# [4,] dt_hlts    628    4  1 hlt_code,hlt_name,hlt_kanji,case_count                        hlt_code
# [5,] dt_reac 14,157    2  1 case_id,hlt_code
# [6,] dt_sgnl 38,346    2  1 drug,hlt_code
# Total: 7MB

stdout_path <- 'output/dm_glm_log.txt'
csv_path <- 'output/dm_glm_orci.csv'
cat('glm\n', file = stdout_path)
cat('', file = csv_path)

hlt_codes <- c(
               10008424, # Chemical injuries
               10028004, # Motor neurone diseases
               10027692, # Pancreatic disorders NEC
               10033646, # Acute and chronic pancreatitis
               10033632, # Pancreatic neoplasms
               10035098, # Pituitary neoplasms
               10033633, # Pancreatic neoplasms malignant (excl islet cell and carcinoid)
               10001438, # Affect alterations NEC
               10017989, # Gastrointestinal neoplasms benign NEC
               10014714, # Endocrine neoplasms NEC
               10044657, # Triglyceride analyses
               10017950, # Gastrointestinal dyskinetic disorders
               10021001, # Hypoglycaemic conditions NEC
               10039078, # Rheumatoid arthropathies
               10039075, # Rheumatoid arthritis and associated conditions
               10024948, # Lower gastrointestinal neoplasms benign
               10017988, # Benign neoplasms gastrointestinal (excl oral cavity)
               10018009, # Gastrointestinal stenosis and obstruction NEC
               10052738, # Skin autoimmune disorders NEC
               10012981, # Digestive enzymes
               10012655, # Diabetic complications NEC
               10043409, # Therapeutic and nontherapeutic responses
               10029976, # Obstructive bile duct disorders (excl neoplasms)
               10008616  # Cholecystitis and cholelithiasis
               )

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
  ce <- s$coefficient

  qn <- qnorm(1 - alpha / 2, 0, 1)
  or_wald <- exp(cbind(ce[,1],
                       ce[,1] - qn * ce[,2],
                       ce[,1] + qn * ce[,2]))
  colnames(or_wald) <- c('OR', 'LL', 'UL')

  out <- list(event = t(hlt),
              summary = s,
              or_wald_ci = or_wald,
              hlt = hlt)

  if (ce[2,1] > 1 && ce[2,4] < alpha) {
    plci <- confint(lr, level = 1 - alpha)
    or_pl <- exp(cbind(ce[,1], plci[,1:2]))
    colnames(or_pl) <- c('OR', 'LL', 'UL')

    write.table(matrix(c(or_pl[2,], hlt), nrow = 1),
                file = csv_path, append = TRUE,
                sep = ',', row.names = FALSE, col.names = FALSE)

    out <- list(out,
                or_profile_likelihood_ci = or_pl,
                incretin_or = paste('HLT', hlt$hlt_code, ';', or_wald[2,1], '[', or_wald[2,2], '-', or_wald[2,3], ']'))
  }

  sink(stdout_path, append = TRUE)
    cat('\n\n\n')
    print(out)
  sink()
}
