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

if(file.exists(dt_rds <- 'output/rds/dt_bf_p.rds')) {
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

  dt_test <- setnames(data.table(matrix(sample(1:1000, size = 4000000, replace = TRUE), ncol = 4)),
                      c('a', 'b', 'c', 'd'))

  cl <- makeCluster(parallel::detectCores(), type = 'SOCK')
  dt_bf_p <- dt_test %>%
    append_p_value(cl) %>%
    append_bayes_factor(cl, cpp_file = 'bayes_factor.cpp')
  stopCluster(cl)
  saveRDS(dt_bf_p, file = dt_rds)
}

bf_scatter <- function(dt, plain_color = TRUE, text_color = '#000066') {
  d <- dt %>% filter(log10(bf) <= 4)
  if(plain_color) {
    return(ggplot(d, aes(x = bf, y = p_val)) +
             geom_point(shape = 18, size = 1.2) +
             scale_x_log10(limits = 10 ^ c(-4, 4), breaks = 10 ^ c(-3:3), expand = c(0, 0),
                           label = as.character(10 ^ c(-3:3))) +
             scale_y_continuous(breaks = c(0, 0.05, 0.25, 0.5, 1), expand = c(0, 0)) +
             labs(x = 'Bayes factor', y = 'Two-sided p-value from Fisher\'s exact test') +
             theme_bw() +
             theme(axis.title.x = element_text(margin = margin(10, 0, 0, 0), size = 18),
                   axis.title.y = element_text(margin = margin(0, 10, 0, 0), size = 18),
                   axis.text = element_text(size = 16),
                   plot.margin = unit(c(1, 1, 1, 1), 'lines'),
                   panel.grid.minor = element_blank()))
  } else {
    return(ggplot(d, aes(x = bf, y = p_val, colour = or)) +
             geom_point(shape = 18, size = 1.2) +
             scale_x_log10(limits = 10 ^ c(-4, 4), breaks = 10 ^ c(-3:3), expand = c(0, 0),
                           label = as.character(10 ^ c(-3:3))) +
             scale_y_continuous(breaks = c(0, 0.05, 0.25, 0.5, 1), expand = c(0, 0)) +
             scale_colour_gradient(low = '#DDDDFF', high = '#222288', trans = 'log', limits = 1000 ^ c(-1, 1),
                                   breaks = 100 ^ (-1:1), label = as.character(100 ^ (-1:1))) +
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
                   panel.grid.minor = element_blank(),
                   panel.border = element_blank(),
                   axis.line = element_line(colour = text_color)))
  }
}

svg('output/img/bf_pval.svg', width = 10, height = 10)
plot(bf_scatter(dt_bf_p))
dev.off()
