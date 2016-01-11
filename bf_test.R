#!/usr/bin/env Rscript
#
#               outcome
#              +       -
#          +-------+-------+
#        + |   a   |   b   | a + b
#  group   +-------+-------+
#        - |   c   |   d   | c + d
#          +-------+-------+
#            a + c   b + d
#

sapply(c('dplyr', 'data.table', 'Rcpp', 'snow', 'ggplot2'), function(p) require(p, character.only = TRUE))
if(! dir.exists(img_dir <- 'output/img')) dir.create(img_dir)
select <- dplyr::select

append_bayes_factor <- function(dt, cl, cpp_file) {
  par_cal_bf <- function(dt, cl) {
    divide_dt <- function(dt, k) {
      return(lapply(1:k, function(i) return(filter(dt, i == rep(1:k, nrow(dt))))))
    }
    cal_bf <- function(d) {
      Rcpp::sourceCpp(cpp_file)
      return(as.data.frame(t(apply(d, 1, bayes_factor))))
    }
    return(as.data.table(bind_rows(parLapply(cl, divide_dt(dt, length(cl)), cal_bf))))
  }
  return(inner_join(dt,
                    par_cal_bf(distinct(select(dt, a:d)), cl),
                    by = c('a', 'b', 'c', 'd')))
}

append_p_value <- function(dt, cl) {
  fisher_test <- function(v, alt = 'two.sided') {
    return(c(v, p_val = fisher.test(matrix(v, nrow = 2), alternative = alt)$p.value))
  }
  return(inner_join(dt,
                    as.data.table(t(parApply(cl, distinct(select(dt, a:d)), 1, fisher_test))),
                    by = c('a', 'b', 'c', 'd')))
}

dt_test <- setnames(data.table(matrix(abs(ceiling(rnorm(40000) * 100)), ncol = 4)),
                    c('a', 'b', 'c', 'd'))

cl <- makeCluster(floor(parallel::detectCores() * 3 / 4), type = 'SOCK')
dt_bf_p <- dt_test %>%
  append_bayes_factor(cl, cpp_file = 'bayes_factor.cpp') %>%
  append_p_value(cl)
stopCluster(cl)

bf_scatter <- function(dt, text_color = '#000066') {
  return(ggplot(dt, aes(x = bf, y = p_val)) +
           geom_point(colour = '#000066', alpha = 0.2) +
           scale_x_continuous(limits = c(0, 2000), expand = c(0, 0)) +
           scale_y_continuous(limits = c(0, 0.2), expand = c(0, 0)) +
           labs(x = 'Bayes factor', y = 'p-value from Fisher\'s exact test') +
           theme_bw() +
           theme(axis.title.x = element_text(colour = text_color, vjust = -3, size = 22),
                 axis.title.y = element_text(colour = text_color, vjust = 3, size = 22),
                 axis.text = element_text(colour = text_color, size = 18),
                 plot.margin = unit(c(2, 2, 1, 1), 'lines'),
                 panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                 panel.border = element_blank(),
                 axis.line = element_line(colour = text_color)))
}

setwd('~/GoogleDrive/lab/s3_phv/')
png('output/img/bf_pval.png', width = 720, height = 720)
plot(bf_scatter(dt_bf_p))
dev.off()
setwd('~/Dropbox/lab/phv/')
