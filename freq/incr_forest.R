#!/usr/bin/env Rscript

source('func.R')

forest <- function(ci, ord, ulim = 200, plain_color = TRUE) {
  d <- ci %>%
         mutate(ar_or = ifelse(ul > ulim, or, NA),
                ar_ul = ifelse(ul > ulim, ulim, NA),
                ar_hlt = ifelse(ul > ulim, hlt, NA),
                ul = ifelse(ul > ulim, ulim, ul))
  if(plain_color) {
    return(ggplot(d) +
             geom_hline(aes(yintercept = 1), linetype = 2, size = 0.6) +
             geom_pointrange(aes(x = hlt, y = or, ymin = ll, ymax = ul),
                             size = 0.8, shape = 15) +
             geom_segment(aes(x = ar_hlt, y = ar_or, xend = ar_hlt, yend = ar_ul), size = 0.8,
                          arrow = arrow(length = unit(2, 'mm'))) +
             scale_y_log10(limits = c(0.5, ulim), breaks = c(10 ^ (0:2))) +
             scale_x_discrete(limits = ord) +
             labs(x = 'MedDRA HLT', y = 'Odds ratio with 99 % confidence interval') +
             coord_flip() +
             facet_grid(. ~ class) +
             theme_bw() +
             theme(axis.title.x = element_text(margin = margin(10, 0, 0, 0), size = 18),
                   axis.title.y = element_text(margin = margin(0, 10, 0, 0), size = 18),
                   axis.text = element_text(size = 12),
                   strip.text = element_text(vjust = 0.6, size = 14),
                   strip.background = element_rect(fill = '#EEEEEE', colour = NA),
                   plot.margin = unit(c(1, 1, 1, 1), 'lines'),
                   panel.grid.major.y = element_blank(), panel.grid.minor = element_blank()))
  } else {
    return(ggplot(d) +
             geom_hline(aes(yintercept = 1), linetype = 2, size = 0.6, colour = '#6600FF') +
             geom_pointrange(aes(x = hlt, y = or, ymin = ll, ymax = ul),
                             size = 0.8, shape = 15, colour = '#6600FF') +
             geom_segment(aes(x = ar_hlt, y = ar_or, xend = ar_hlt, yend = ar_ul), size = 0.8,
                          arrow = arrow(length = unit(2, 'mm')), colour = '#6600FF') +
             scale_y_log10(limits = c(0.5, ulim), breaks = c(10 ^ (0:2))) +
             scale_x_discrete(limits = ord) +
             labs(x = 'MedDRA HLT', y = 'Odds ratio with 99 % confidence interval', colour = '#000066') +
             coord_flip() +
             facet_grid(. ~ class) +
             theme_bw() +
             theme(axis.title.x = element_text(colour = '#000066', vjust = -1, size = 18),
                   axis.title.y = element_text(colour = '#000066', vjust = 1, size = 18),
                   axis.text = element_text(colour = '#000066', size = 12),
                   strip.text = element_text(colour = '#6600FF', vjust = 0.6, size = 14),
                   strip.background = element_rect(fill = '#EEEEFF', colour = NA),
                   plot.margin = unit(c(1, 1, 1, 1), 'lines'),
                   panel.grid.major.y = element_blank(), panel.grid.minor = element_blank()))
  }
}

dt_orci <- fread('output/csv/mixed_or.csv')[, c(1:4, 6), with = FALSE] %>%
             setnames(c('class', 'or', 'll', 'ul', 'hlt')) %>%
             filter(ll > 1) %>%
             mutate(class = ifelse(class == 'dpp4i', 'DPP-4 inhibitors', class)) %>%
             mutate(class = ifelse(class == 'glp1a', 'GLP-1 receptor agonists', class))

v_hlt <- dt_orci %>%
           group_by(hlt) %>%
           summarize(maxor = max(or)) %>%
           arrange(maxor) %>%
           .$hlt

svg_plot(forest(dt_orci, v_hlt),
         file = 'output/img/mixed_or.svg',
         w = 10, h = 11)
