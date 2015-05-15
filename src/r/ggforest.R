#!/usr/bin/env R

sapply(c('data.table', 'ggplot2'), function(p) require(p, character.only = TRUE))

or_ci <- fread('odds_ratio.csv')

forest <- ggplot(or_ci, aes(x = group, y = odds_ratio, ymin = ci_lower, ymax = ci_upper, colour = class)) +
            geom_hline(aes(yintercept = 1), colour = '#4400FF', linetype = 2) +
            geom_pointrange(size = 0.7, shape = 15) +
            scale_y_log10(limits = c(0.01, 100), breaks = c(0.1, 1, 10)) +
            scale_x_discrete(limits = rev(or_ci$group)) +
            scale_colour_manual(values = c('#FF00FF', '#4400FF')) +
            theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(), panel.background = element_rect(fill = '#DDDDFF')) +
            coord_flip()

svg('forest.svg', width = 6, height = 7)
print(forest)
dev.off()
