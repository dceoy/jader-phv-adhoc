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

pkgs <- c('RSQLite', 'plyr', 'dplyr', 'tidyr', 'data.table', 'snow', 'foreach', 'doSNOW', 'parallel', 'ggplot2', 'rstan')
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

out_path <- 'output/dm_stan_log.txt'
cat('stan\n', file = out_path)

hlt_codes <- c(10033632, # 膵新生物
               10033633, # 悪性膵新生物（膵島細胞腫瘍およびカルチノイドを除く）
               10033646, # 急性および慢性膵炎
               10039078, # リウマチ性関節症
               10039075, # 関節リウマチおよびその関連疾患
               10018009, # 消化管狭窄および閉塞ＮＥＣ
               10025614, # 悪性腸管新生物
               10012981, # 消化酵素
               10008616, # 胆嚢炎および胆石症
               10040768) # 骨格筋および心筋検査

st_model <- stan_model(file = 'car.stan')

foreach (code = hlt_codes) %do% {
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
          select(event, dpp4_inhibitor, glp1_agonist, concomit, preexist, age, sex, suspected, quarter)

  ae_dat <- list(N = dt %>% nrow(),
                 M = 6,
                 L = dt %>% distinct(quarter) %>% nrow(),
                 y = dt$event,
                 x = dt %>% select(dpp4_inhibitor, glp1_agonist, concomit, preexist, age, sex),
                 t = dt %>%
                       distinct(quarter) %>%
                       mutate(q_id = 1:nrow(.)) %>%
                       select(quarter, q_id) %>%
                       inner_join(dt, by = 'quarter') %>%
                       .$q_id)

  sflist <- foreach(i = 1:8, .packages = 'rstan') %dopar% {
              sampling(object = st_model, data = ae_dat, iter = 1000, chains = 1, chain_id = i, refresh = -1)
            }
  stanfit <- sflist2stanfit(sflist)

  plot_path <- paste('img/plot_', hlt$hlt_code, '.pdf', sep = '')
  traceplot_path <- paste('img/traceplot_', hlt$hlt_code, '.pdf', sep = '')
  violin_path <- paste('img/violin_', hlt$hlt_code, '.svg', sep = '')
  rdata_path <- paste('output/stan_', hlt$hlt_code, '.Rdata', sep = '')

  pdf(plot_path)
    plot(stanfit)
  dev.off()

  pdf(traceplot_path)
    traceplot(stanfit)
  dev.off()

  la <- extract(stanfit, permuted = TRUE)
  N <- dt %>% nrow()
  N_mc <- length(la$alpha)

  bs <- tbl_dt(data.table(la$beta))
  colnames(bs) <- c('dpp', 'glp', 'ccm', 'pre', 'age', 'sex')
  bs_g <- bs %>% gather(param, value)
  bs_gq <- bs_g %>%
             gather(param, value) %>%
             group_by(param) %>%
             summarize(value = median(value),
                       ymax = quantile(value, prob = 0.975),
                       ymin = quantile(value, prob = 0.025))
  bs_g <- bs_gq %>% inner_join(bs_g, by = 'param')
  colnames(bs_g) <- c('param', 'value', 'median', 'ymax', 'ymin')

  p <- ggplot(bs_g, aes(x = param, y = value, group = param, ymax = ymax, ymin = ymin, color = param)) +
         geom_violin(trim = FALSE, fill = '#5B423D', linetype = 'blank', alpha = I(1/3)) +
         geom_pointrange(data = bs_gq, size = 0.75) +
         labs(x = '', y = '') +
         theme(axis.text.x = element_text(size = 14), axis.text.y = element_text(size = 14))

  svg(violin_path, width = 12, height = 8)
    print(p)
  dev.off()

  ors <- bs %>%
           apply(2, function(b) quantile(b, c(0.5, 0.005, 0.025, 0.975, 0.995))) %>%
           t() %>%
           exp()

  out <- list(event = t(hlt), stanfit = stanfit, odds_ratio = ors)
  sink(out_path, append = TRUE)
    cat('\n\n\n')
    print(out)
  sink()

  save.image(rdata_path)
}
