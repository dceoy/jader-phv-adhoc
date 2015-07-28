#!/usr/bin/env Rscript

source('func.R')

dt_daic <- fread('output/csv/aic_hlt.csv')[,c(1:4, 6, 8), with = FALSE] %>%
             setnames(c('aic_mixed', 'aic_fixed', 'sigma', 'sigma_sd', 'hlt_name', 'case_count')) %>%
             mutate(aic_diff = aic_mixed - aic_fixed,
#                   lab = ifelse(aic_diff < -220, hlt_name, ''),
                    favor = ifelse(aic_mixed < aic_fixed, 'mixed', 'fixed'))

segment <- function(dt) {
  return(ggplot(dt, aes(x = case_count, y = aic_diff, colour = favor)) +
#          geom_text(aes(label = lab), vjust = 0, hjust = 1.04, colour = '#003366') +
           geom_point(size = 4, shape = 18, alpha = 0.8) +
           scale_x_log10(breaks = c(10 ^ (1:4)), expand = c(0.02, 0.02)) +
           scale_y_continuous(expand = c(0.02, 0.02)) +
           labs(x = 'Unique Case Count', y = 'AIC Difference', colour = element_blank()) +
           theme_bw() +
           theme(legend.position = 'none',
                 plot.margin = unit(c(0, 1, 1, 1), 'lines'),
                 axis.title.x = element_text(colour = '#000066', vjust = -1, size = 22),
                 axis.title.y = element_text(colour = '#000066', vjust = 2, size = 22),
                 axis.text = element_text(colour = '#000066', size = 18),
                 panel.grid.minor = element_blank()))
}

histogram <- function(dt) {
  return(ggplot(dt, aes(x = case_count, fill = favor)) +
           geom_histogram(position = 'identity', colour = NA, alpha = 0.3) +
           scale_x_log10(labels = NULL, breaks = NULL, expand = c(0.02, 0.02)) +
           scale_y_continuous(expand = c(0, 0.02)) +
           scale_fill_discrete(name = 'MedDRA HLTs',
                               label = c(mixed = 'favor the MIXED model',
                                         fixed = 'favor the FIXED model')) +
           labs(y = 'Frequency') +
           theme_bw() +
           theme(legend.position = c(1, 0.7), legend.justification = c(1, 0),
                 legend.background = element_blank(), legend.key = element_blank(),
                 legend.title = element_text(colour = '#000066', size = 18),
                 legend.text = element_text(colour = '#000066', size = 18),
                 panel.background = element_blank(),
                 panel.grid.major = element_blank(),
                 panel.grid.minor = element_blank(),
                 panel.margin = unit(0, 'null'),
                 panel.border = element_rect(color = NA),
                 plot.margin = unit(c(1, 1, -0.9, 3.5), 'lines'),
                 axis.ticks = element_blank(),
                 axis.text = element_blank(),
                 axis.title.x = element_blank(),
                 axis.title.y = element_text(colour = '#000066', vjust = 2, size = 22)))
}

hst_seg <- function(dt) {
  return(grid.arrange(histogram(dt), segment(dt), nrow = 2, heights = c(1, 2)))
}

png_plot(hst_seg(dt_daic), file = 'output/img/aic_diff.png', w = 900, h = 700)
