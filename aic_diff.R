#!/usr/bin/env Rscript

source('func.R')

dt_aics <- fread('output/csv/aic_hlt.csv')[,c(1, 2, 4, 6), with = FALSE] %>%
             setnames(c('aic_mixed', 'aic_fixed', 'hlt_name', 'case_count')) %>%
             mutate(aic_diff = aic_mixed - aic_fixed,
#                   lab = ifelse(aic_diff < -80, hlt_name, ''),
                    favor = ifelse(aic_diff < 0, 'mixed', 'fixed'))

daic <- function(dt) {
  return(ggplot(dt, aes(x = case_count, xend = case_count, y = 0, yend = aic_diff, colour = favor)) +
           geom_segment(size = 1.2, arrow = arrow(length = unit(0.2, 'cm'))) +
#          geom_text(aes(x = case_count, y = aic_diff, label = lab), hjust = 1, colour = '#000066') +
           scale_x_log10(limits = c(1, 10100), breaks = c(10 ^ (0:4))) +
           scale_y_continuous(limits = c(-200, 3)) +
           scale_colour_discrete(name = 'MedDRA High Level Terms',
                                 label = c(mixed = 'favor the MIXED model',
                                           fixed = 'favor the FIXED model')) +
           labs(x = 'Unique Case Count', y = 'AIC Difference', colour = element_blank()) +
           theme(legend.position = c(0.04, 0.04), legend.justification = c(0, 0),
                 legend.background = element_blank(), legend.key = element_blank(),
                 legend.title = element_text(colour = '#000066', size = 18),
                 legend.text = element_text(colour = '#000066', size = 18),
                 axis.title.x = element_text(colour = '#000066', vjust = 0, size = 22),
                 axis.title.y = element_text(colour = '#000066', vjust = 1, size = 22),
                 axis.text = element_text(colour = '#000066', size = 18),
                 panel.grid.major.x = element_blank(), panel.grid.minor = element_blank(),
                 panel.background = element_rect(fill = '#E8E8FF')))
}

three_plot(daic(dt_aics), path = 'output/img/', name = 'aic_diff')
