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
# [6,] dt_sgnl 40,010    2  1 drug,hlt_code
# Total: 7MB

out_path <- 'output/dm_stan_log.txt'
csv_path <- 'output/dm_stan_orci.csv'
cat('stan\n', file = out_path)
cat('', file = csv_path)

hlt_codes <- c(10027692, 10033646, 10035098, 10033632, 10033633, 10044657, 10021001, 10039078, 10039075, 10024948, 10043409, 10017988, 10018009, 10012981, 10012655, 10052738, 10029976, 10008616, 10003818, 10007217, 10027416, 10025614, 10020638, 10017933, 10052770, 10040768, 10029511)

st_model <- stan_model(model_code = 'data {
                                       int<lower=0> N;
                                       int<lower=0> M;
                                       int<lower=0, upper=1> y[N];
                                       matrix[N, M] x;
                                     }
                                     parameters {
                                       real alpha;
                                       vector[M] beta;
                                     }
                                     model {
                                       alpha ~ normal(0, 100);
                                       beta ~ normal(0, 100);
                                       for (i in 1:N)
                                         y[i] ~ bernoulli_logit(alpha + dot_product(x[i], beta));
                                     }')

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
          mutate(incretin = as.integer(ifelse(dpp4_inhibitor + glp1_agonist > 0, 1, 0))) %>%
          select(event, incretin, concomit, preexist, age, sex)

  ae_dat <- list(N = dt %>% nrow(),
                 M = 5,
                 y = dt$event,
                 x = dt %>% select(incretin, concomit, preexist, age, sex))

# stanfit <- sampling(object = st_model, data = ae_dat, iter = 1000, chains = 4)
  sflist <- foreach(i = 1:8, .packages = 'rstan') %dopar% {
              sampling(object = st_model, data = ae_dat, iter = 1000, chains = 1, chain_id = i, refresh = -1)
            }
  stanfit <- sflist2stanfit(sflist)

  plot_path <- paste('img/plot_', hlt$hlt_code, '.pdf', sep = '')
  traceplot_path <- paste('img/traceplot_', hlt$hlt_code, '.pdf', sep = '')
  violin_path <- paste('img/violin_', hlt$hlt_code, '.svg', sep = '')

  pdf(plot_path)
    plot(stanfit)
  dev.off()

  pdf(traceplot_path)
    traceplot(stanfit)
  dev.off()

  out <- list(event = t(hlt), stanfit = stanfit)
  sink(out_path, append = TRUE)
    cat('\n\n\n')
    print(out)
  sink()

  la <- extract(stanfit, permuted = TRUE)
  N <- dt %>% nrow()
  N_mc <- length(la$alpha)

  bs <- tbl_dt(data.table(la$beta))
  colnames(bs) <- c('icr', 'ccm', 'pre', 'age', 'sex')
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

  orci <- quantile(exp(bs$icr), c(0.5, 0.005, 0.995))
  if (orci[2] > 1) {
    write.table(matrix(c(orci, hlt), nrow = 1), file = csv_path, append = TRUE, sep = ',', row.names = FALSE, col.names = FALSE)
  }
}

# save.image('output/stan.Rdata')
