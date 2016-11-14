#!/usr/bin/env Rscript

source('func.R')

dt_daic <- fread('output/csv/aic_hlt.csv')[, c(1:4, 6, 8), with = FALSE] %>%
             setnames(c('aic_mixed', 'aic_fixed', 'sigma', 'sigma_sd', 'hlt_name', 'case_count')) %>%
             mutate(aic_diff = aic_mixed - aic_fixed,
                    favor = ifelse(aic_mixed < aic_fixed, 'mixed', 'fixed'))

segment <- function(dt, plain_color = TRUE) {
  if(plain_color) {
    return(ggplot(dt, aes(x = case_count, y = aic_diff, colour = favor)) +
             geom_point(alpha = 0.5) +
             scale_x_log10(breaks = c(10 ^ (1:4)), expand = c(0.02, 0.02)) +
             scale_y_continuous(limits = c(-240, 10), expand = c(0.02, 0.02)) +
             scale_colour_manual(values = c('#999999', '#333333')) +
             labs(x = 'Case count', y = 'AIC difference', colour = element_blank()) +
             theme_bw() +
             theme(legend.position = 'none',
                   plot.margin = unit(c(0, 1, 1, 1), 'lines'),
                   axis.title.x = element_text(vjust = -1, size = 20),
                   axis.title.y = element_text(vjust = 2, size = 20),
                   axis.text = element_text(size = 16),
                   panel.grid.minor = element_blank()))
  } else {
    return(ggplot(dt, aes(x = case_count, y = aic_diff, colour = favor)) +
             geom_point(size = 5, shape = 18, alpha = 0.7) +
             scale_x_log10(breaks = c(10 ^ (1:4)), expand = c(0.02, 0.02)) +
             scale_y_continuous(limits = c(-240, 10), expand = c(0.02, 0.02)) +
             scale_colour_manual(values = c('#E377C2', '#17BECF')) +
             labs(x = 'Case count', y = 'AIC difference', colour = element_blank()) +
             theme_bw() +
             theme(legend.position = 'none',
                   plot.margin = unit(c(0, 1, 1, 1), 'lines'),
                   axis.title.x = element_text(colour = '#000066', vjust = -1, size = 24),
                   axis.title.y = element_text(colour = '#000066', vjust = 2, size = 24),
                   axis.text = element_text(colour = '#000066', size = 20),
                   panel.grid.minor = element_blank()))
  }
}

histogram <- function(dt, plain_color = TRUE) {
  if(plain_color) {
    return(ggplot(dt, aes(x = case_count, fill = favor)) +
             geom_histogram(position = 'dodge', alpha = 0.5, colour = NA) +
             scale_x_log10(labels = NULL, breaks = NULL, expand = c(0.02, 0.02)) +
             scale_y_continuous(expand = c(0, 0.02)) +
             scale_fill_manual(name = 'MedDRA HLTs',
                               label = c(mixed = 'favor the MIXED model',
                                         fixed = 'favor the FIXED model'),
                               values = c('#999999', '#333333')) +
             labs(y = 'Frequency') +
             theme_bw() +
             theme(legend.position = c(0, 0.7), legend.justification = c(0, 0),
                   legend.background = element_blank(), legend.key = element_blank(),
                   legend.title = element_text(size = 16),
                   legend.text = element_text(size = 16),
                   panel.background = element_blank(),
                   panel.grid.major = element_blank(),
                   panel.grid.minor = element_blank(),
                   panel.border = element_rect(color = NA),
                   plot.margin = unit(c(1, 1, -0.9, 3.5), 'lines'),
                   axis.ticks = element_blank(),
                   axis.text = element_blank(),
                   axis.title.x = element_blank(),
                   axis.title.y = element_text(vjust = 3, size = 20)))
  } else {
    return(ggplot(dt, aes(x = case_count, fill = favor)) +
             geom_histogram(position = 'identity', colour = NA, alpha = 0.3) +
             scale_x_log10(labels = NULL, breaks = NULL, expand = c(0.02, 0.02)) +
             scale_y_continuous(expand = c(0, 0.02)) +
             scale_fill_manual(name = 'MedDRA HLTs',
                               label = c(mixed = 'favor the MIXED model',
                                         fixed = 'favor the FIXED model'),
                               values = c('#E377C2', '#17BECF')) +
             labs(y = 'Frequency') +
             theme_bw() +
             theme(legend.position = c(0, 0.6), legend.justification = c(0, 0),
                   legend.background = element_blank(), legend.key = element_blank(),
                   legend.title = element_text(colour = '#000066', size = 20),
                   legend.text = element_text(colour = '#000066', size = 20),
                   panel.background = element_blank(),
                   panel.grid.major = element_blank(),
                   panel.grid.minor = element_blank(),
                   panel.border = element_rect(color = NA),
                   plot.margin = unit(c(1, 1, -0.9, 3.5), 'lines'),
                   axis.ticks = element_blank(),
                   axis.text = element_blank(),
                   axis.title.x = element_blank(),
                   axis.title.y = element_text(colour = '#000066', vjust = 3, size = 24)))
  }
}

hst_seg <- function(dt) {
  return(grid.arrange(histogram(dt), segment(dt), nrow = 2, heights = c(2, 3)))
}

svg_plot(hst_seg(dt_daic),
         file = 'output/img/aic_diff.svg',
         w = 10, h = 10)
