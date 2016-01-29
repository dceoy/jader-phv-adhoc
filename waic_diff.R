#!/usr/bin/env Rscript

sapply(c('dplyr', 'tidyr', 'data.table', 'ggplot2', 'gridExtra'), require, character.only = TRUE)
setwd('~/GoogleDrive/lab/s3_phv/')
if(! dir.exists(img_dir <- 'output/img')) dir.create(img_dir)
select <- dplyr::select

dt_case <- tbl_dt(fread('input/csv/dt_case.csv'))
dt_soc_case <- tbl_dt(fread('input/csv/dt_soc_case.csv'))
dt_waic <- tbl_dt(bind_rows(lapply(paste0('output/csv/waic_', dt_soc_case$soc_code, '.csv'), fread)))
dt_waic_wide <- dt_waic %>%
  select(soc_code, model, waic) %>%
  spread(model, waic) %>%
  inner_join(dt_soc_case, by = 'soc_code')
dt_waic_diff <- dt_waic_wide %>%
  mutate(mixed_fixed = mixed - fixed,
         ar_fixed = ar - fixed) %>%
  mutate(soc_name = factor(soc_name, levels = rev(dt_soc_case$soc_name))) %>%
  select(soc_name, total_case, mixed_fixed, ar_fixed) %>%
  gather(model, diff, -soc_name, -total_case)

waic_segment <- function(dt, text_color = '#000066') {
  return(ggplot(dt, aes(x = soc_name, y = diff, colour = model)) +
           geom_hline(aes(yintercept = 0), linetype = 2, size = 0.4, alpha = 0.6, colour = '#6600FF') +
           geom_point(size = 2, shape = 17, position = position_dodge(width = 0.8), alpha = 0.8) +
           scale_x_discrete(expand = c(0.02, 0.02)) +
           scale_y_continuous(expand = c(0.02, 0.02)) +
           scale_colour_manual(label = c(mixed_fixed = 'MIXED - FIXED', ar_fixed = 'AR - FIXED'),
                               values = c(mixed_fixed = '#E377C2', ar_fixed = '#17BECF')) +
           labs(x = 'SOC', y = 'WAIC difference', colour = element_blank()) +
           coord_flip() +
           theme_bw() +
           theme(legend.position = 'top',
                 legend.background = element_blank(), legend.key = element_blank(),
                 legend.title = element_text(colour = text_color, size = 18),
                 legend.text = element_text(colour = text_color, size = 18),
                 axis.title.x = element_text(colour = text_color, vjust = -3, size = 22),
                 axis.title.y = element_text(colour = text_color, vjust = 3, size = 22),
                 axis.text = element_text(colour = text_color, size = 15),
                 plot.margin = unit(c(1, 1, 1, 1), 'lines'),
                 panel.grid.minor = element_blank(),
                 panel.border = element_blank(),
                 axis.line = element_line(colour = text_color)))
}

count_bar <- function(dt, text_color = '#000066') {
  return(ggplot(dt, aes(x = soc_name, y = total_case)) +
           geom_bar(stat = 'identity', fill = '#000066', alpha = 0.2) +
           scale_y_continuous(breaks = c(0, 20000), expand = c(0, 0)) +
           labs(y = 'Case', fill = 'Year') +
           coord_flip() +
           theme_bw() +
           theme(axis.title.x = element_text(colour = text_color, vjust = -3, size = 22),
                 axis.title.y = element_blank(),
                 axis.text.x = element_text(colour = text_color, size = 15),
                 axis.text.y = element_blank(),
                 axis.ticks.y = element_blank(),
                 plot.margin = unit(c(4, 1, 1, 0), 'lines'),
                 panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                 panel.border = element_blank(),
                 axis.line = element_line(colour = text_color)))
}

bar_seg <- function(dt) {
  return(grid.arrange(waic_segment(dt), count_bar(distinct(dt, soc_name, total_case)),
                      ncol = 2, widths = c(9, 1)))
}

png('output/img/waic_diff.png', width = 960, height = 480)
plot(bar_seg(dt_waic_diff))
dev.off()
