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
setwd('~/GoogleDrive/lab/s3_phv/')
if(! dir.exists(img_dir <- 'output/img')) dir.create(img_dir)
select <- dplyr::select

if(file.exists(dt_rds <- 'input/rds/dt_bf_p.rds')) {
  dt_bf_p <- readRDS(file <- dt_rds)
} else {
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
      f <- fisher.test(matrix(v, nrow = 2), alternative = alt)
      return(c(v, p_val = f$p.value, or = f$estimate[[1]]))
    }
    return(inner_join(dt,
                      as.data.table(t(parApply(cl, distinct(select(dt, a:d)), 1, fisher_test))),
                      by = c('a', 'b', 'c', 'd')))
  }

  dt_test <- setnames(data.table(matrix(sample(0:1000, size = 400000, replace = TRUE), ncol = 4)),
                      c('a', 'b', 'c', 'd'))

  cl <- makeCluster(parallel::detectCores(), type = 'SOCK')
  dt_bf_p <- dt_test %>%
    append_p_value(cl) %>%
    append_bayes_factor(cl, cpp_file = 'bayes_factor.cpp')
  stopCluster(cl)
  saveRDS(dt_bf_p, file = dt_rds)
}

bf_scatter <- function(dt, bfmax = 400, pmax = 0.3, text_color = '#000066') {
  return(ggplot(filter(dt, bf <= bfmax, p_val <= pmax), aes(x = bf, y = p_val, colour = or)) +
           geom_point(shape = 18, size = 1) +
           scale_x_continuous(limits = c(0, bfmax), breaks = c(0:8 * 50), expand = c(0, 0)) +
           scale_y_continuous(limits = c(0, pmax), breaks = c(0:6 / 20), expand = c(0, 0)) +
           scale_colour_gradient(low = '#AAAADD', high = '#000066') +
           labs(x = 'Bayes factor', y = 'Two-sided p-value from Fisher\'s exact test', colour = 'Odds ratio') +
           theme_bw() +
           theme(legend.position = 'right',
                 legend.background = element_blank(), legend.key = element_blank(),
                 legend.title = element_text(colour = text_color, size = 18),
                 legend.text = element_text(colour = text_color, size = 12),
                 axis.title.x = element_text(colour = text_color, vjust = -3, size = 22),
                 axis.title.y = element_text(colour = text_color, vjust = 3, size = 22),
                 axis.text = element_text(colour = text_color, size = 18),
                 plot.margin = unit(c(1, 1, 1, 1), 'lines'),
                 panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                 panel.border = element_blank(),
                 axis.line = element_line(colour = text_color)))
}

png('output/img/bf_pval.png', width = 960, height = 720)
plot(bf_scatter(dt_bf_p))
dev.off()
setwd('~/Dropbox/lab/phv/')
