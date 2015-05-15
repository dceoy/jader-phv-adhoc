#!/usr/bin/env Rscript

sapply(c('dplyr', 'data.table', 'ggplot2'), function(p) require(p, character.only = TRUE))

sc <- setnames(fread('output/csv/sc_or.csv')[,c(1:3, 5), with = FALSE], c('or', 'll', 'ul', 'hlt'))
dm <- setnames(fread('output/csv/dm_or.csv')[,c(1:3, 5), with = FALSE], c('or', 'll', 'ul', 'hlt'))

forest <- function(ci) {
  return(ggplot(ci, aes(x = hlt, y = or, ymin = ll, ymax = ul)) +
           geom_hline(aes(yintercept = 1), colour = '#4400FF', linetype = 2) +
           geom_pointrange(size = 0.7, shape = 15, colour = '#4400FF') +
           scale_y_log10(limits = c(0.5, 500), breaks = c(1, 10, 100)) +
           scale_x_discrete(limits = ci %>% arrange(or) %>% .$hlt) +
           labs(x = 'MedDRA High Level Term', y = 'Odds Ratios [ 99 % Confidence Intervals ]') +
           coord_flip() +
           theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(),
                 axis.title.x = element_text(colour = '#000066', vjust = 0),
                 axis.title.y = element_text(colour = '#000066', vjust = 1),
                 panel.background = element_rect(fill = '#DDDDFF')))
}

svg('output/img/sc_forest.svg', width = 12, height = 8); plot(forest(sc)); dev.off()
png('output/img/sc_forest.png', width = 800, height = 500); plot(forest(sc)); dev.off()
tiff('output/img/sc_forest.tif', width = 800, height = 500); plot(forest(sc)); dev.off()

svg('output/img/dm_forest.svg', width = 12, height = 8); plot(forest(dm)); dev.off()
png('output/img/dm_forest.png', width = 800, height = 500); plot(forest(dm)); dev.off()
tiff('output/img/dm_forest.tif', width = 800, height = 500); plot(forest(dm)); dev.off()
