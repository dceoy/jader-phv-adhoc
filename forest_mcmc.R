# coding: utf-8

pload <- function(p) {
  if (! p %in% installed.packages()[,1]) install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}

r <- getOption('repos')
r['CRAN'] <- 'http://cran.us.r-project.org'
options(repos = r)
rm(r)

ps <- c('RSQLite', 'plyr', 'dplyr', 'data.table', 'MCMCpack', 'ggplot2')
names(ps) <- ps
sapply(ps, pload)

#pload('epicalc')

driver <- dbDriver('SQLite')
db <- 'jader.sqlite3'
con <- dbConnect(driver, db)

aes <- c('hypoglycemia',
#        'hyperglycemia',
         'pancreatitis',
#        'pancreatic_neoplasms',
         'pancreatic_neoplasms_malignant',
         'neopl')

# -- 10021001 低血糖状態ＮＥＣ  Hypoglycaemic conditions NEC
# -- 10020638 高血糖ＮＥＣ Hyperglycaemic conditions NEC
# -- 10033646 急性および慢性膵炎  Acute and chronic pancreatitis
# -- 10033632 膵新生物  Pancreatic neoplasms
# -- 10033633 悪性膵新生物（膵島細胞腫瘍およびカルチノイドを除く）  Pancreatic neoplasms malignant (excl islet cell and carcinoid)
# -- 10022097 注射部位反応  Injection site reactions
# -- 10029104 良性、悪性および詳細不明の新生物（嚢胞およびポリープを含む）  Neoplasms benign, malignant and unspecified (incl cysts and polyps)


for (ae in aes) {
  sql <- paste('SELECT
                  d.case_id,
                  dpp4_inhibitor,
                  glp1_analog,
                  sulfonylurea,
                  rapid_acting_insulin_secretagogue,
                  alpha_glucosidase_inhibitor,
                  biguanide,
                  thiazolidinedione,
                  insulin,
                  age,
                  sex,
                  CASE
                    WHEN d.case_id IN (
                      SELECT DISTINCT case_id FROM ade10 WHERE pt IN (
                        SELECT pt FROM (
                          SELECT \'hypoglycemia\' AS ae, pt_kanji AS pt FROM pt_j WHERE pt_code IN (SELECT pt_code FROM hlt_pt WHERE hlt_code == 10021001)
                          UNION ALL SELECT \'hyperglycemia\', pt_kanji FROM pt_j WHERE pt_code IN (SELECT pt_code FROM hlt_pt WHERE hlt_code == 10020638)
                          UNION ALL SELECT \'pancreatitis\', pt_kanji FROM pt_j WHERE pt_code IN (SELECT pt_code FROM hlt_pt WHERE hlt_code == 10033646)
                          UNION ALL SELECT \'pancreatic_neoplasms\', pt_kanji FROM pt_j WHERE pt_code IN (SELECT pt_code FROM hlt_pt WHERE hlt_code == 10033632)
                          UNION ALL SELECT \'pancreatic_neoplasms_malignant\', pt_kanji FROM pt_j WHERE pt_code IN (SELECT pt_code FROM hlt_pt WHERE hlt_code == 10033633)
                          UNION ALL SELECT \'injection_site_reactions\', pt_kanji FROM pt_j WHERE pt_code IN (SELECT pt_code FROM hlt_pt WHERE hlt_code == 10022097)
                          UNION ALL SELECT \'neopl\', pt_kanji FROM pt_j WHERE pt_code IN (SELECT pt_code FROM pt WHERE pt_soc_code == 10029104)
                        ) aePt WHERE ae == \'', ae, '\'
                      )
                    ) THEN 1
                    ELSE 0
                  END AS event
                FROM drDf d
                INNER JOIN adDf a ON d.case_id == a.case_id
                WHERE d.case_id NOT IN (
                  SELECT
                    DISTINCT case_id
                  FROM hist
                  WHERE disease IN (
                   SELECT pt FROM aePt WHERE ae == \'', ae, '\'
                  )
                );',
                sep='')

  dt <- tbl_dt(data.table(dbGetQuery(con, sql)))

  print(dt)

  print(gsub('\\n +', ' ', sql))
  posterior <- MCMClogit(event ~ dpp4_inhibitor +
                                 glp1_analog +
                                 sulfonylurea +
                                 rapid_acting_insulin_secretagogue +
                                 alpha_glucosidase_inhibitor +
                                 biguanide +
                                 thiazolidinedione +
                                 insulin +
                                 age +
                                 sex,
                         data=dt, burnin=5000, mcmc=30000)
# plot(posterior)
  print(ae)
  results <- summary(posterior)
  print(results)
  print(raftery.diag(posterior))
  lr <- glm(event ~ dpp4_inhibitor +
                    glp1_analog +
                    sulfonylurea +
                    rapid_acting_insulin_secretagogue +
                    alpha_glucosidase_inhibitor +
                    biguanide +
                    thiazolidinedione +
                    insulin +
                    age +
                    sex,
            data=dt, family=binomial)
  print(summary(lr))
# print(logistic.display(lr))

  p <- data.frame(results$quantiles)
  p <- p[2:9,]
  p <- exp(p)
# p <- cbind(data.frame(results$statistics), data.frame(results$quantiles))
# print(mode(p))
# print(str(p))
# print(p)
  drug <- c(row.names(p))
  ci <- data.frame(drug)
  ci$class <- append(rep('incretin', times=2), rep('other', times=6))
  ci$odds_ratio <- p$X50.
  ci$lower_ci95 <- p$X2.5.
  ci$upper_ci95 <- p$X97.5.

  print(paste(ci$drug, ' ', floor(ci$odds_ratio*100)/100, ' ( ', floor(ci$lower_ci95*100)/100, ' - ', floor(ci$upper_ci95*100)/100, ' )', sep=''))

  svg(paste('img/', ae, '.svg', sep=''), width=6, height=7)

  forest <- ggplot(ci, aes(x=drug, y=odds_ratio, ymin=lower_ci95, ymax=upper_ci95, colour=class)) +
            geom_hline(aes(yintercept=1), colour='#4400FF', linetype=2) +
            geom_pointrange(size=0.7, shape=15) +
            scale_y_log10(limits=c(0.01, 100)) +
            scale_x_discrete(limits=rev(ci$drug)) +
            scale_colour_manual(values=c('#FF00FF', '#4400FF')) +
            theme(panel.grid.major=element_blank(), panel.grid.minor=element_blank(), panel.background=element_rect(fill='#DDDDFF')) +
            coord_flip()
  print(forest)

  dev.off()
}

