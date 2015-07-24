#!/usr/bin/env Rscript

source('func.R')

read_or <- function(file) {
  return(fread(file)[,c(1:4, 6), with = FALSE] %>%
           setnames(c('class', 'or', 'll', 'ul', 'hlt')) %>%
           filter(ll > 1))
}

forest <- function(ci, ulim = 400) {
  return(ggplot(ci %>%
                  mutate(ar_or = ifelse(ul > ulim, or, NA),
                         ar_ul = ifelse(ul > ulim, ulim, NA),
                         ar_hlt = ifelse(ul > ulim, hlt, NA),
                         ul = ifelse(ul > ulim, ulim, ul))) +
           geom_hline(aes(yintercept = 1), linetype = 2, size = 0.6, colour = '#4400FF') +
           geom_pointrange(aes(x = hlt, y = or, ymin = ll, ymax = ul),
                           size = 1, shape = 15, colour = '#4400FF') +
           geom_segment(aes(x = ar_hlt, y = ar_or, xend = ar_hlt, yend = ar_ul), size = 1,
                        arrow = arrow(length = unit(0.2, 'cm')), colour = '#4400FF') +
           scale_y_log10(limits = c(0.25, ulim), breaks = c(1, 10, 100)) +
           scale_x_discrete(limits = arrange(ci, or)$hlt) +
           labs(x = 'MedDRA High Level Term', y = 'Odds Ratio 99% Confidence Intervals') +
           coord_flip() +
           theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(),
                 axis.title.x = element_text(colour = '#000066', vjust = 0, size = 22),
                 axis.title.y = element_text(colour = '#000066', vjust = 1, size = 22),
                 axis.text = element_text(colour = '#000066', size = 18),
                 panel.background = element_rect(fill = '#E8E8FF')))
}

ls_dt <- sapply(md <- c('mixed', 'fixed'),
                function(m) return(read_or(paste('output/csv/', m, '_or.csv', sep = ''))))

lapply(c('dpp4i', 'glp1a'),
       function(d) lapply(md,
                          function(m) three_plot(forest(filter(as.data.table(ls_dt[,m]), class == d)),
                                                 path = 'output/img/',
                                                 name = paste(m, '_or_', d, sep =''))))
