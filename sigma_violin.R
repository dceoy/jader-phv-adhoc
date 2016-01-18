#!/usr/bin/env Rscript

sapply(c('dplyr', 'tidyr', 'data.table', 'ggplot2', 'gridExtra'), require, character.only = TRUE)
setwd('~/GoogleDrive/lab/s3_phv/')
if(! dir.exists(img_dir <- 'output/img')) dir.create(img_dir)
select <- dplyr::select

v_model <- c('mixed', 'ar')
dt_soc_case <- tbl_dt(mutate(fread('input/csv/dt_soc_case.csv'),
                             soc_name = factor(soc_name, levels = rev(soc_name))))
dt_yid <- tbl_dt(fread('input/csv/dt_yid.csv'))
dt_post <- v_model %>%
  expand.grid(dt_soc_case$soc_code) %>%
  setnames(c('model', 'soc_code')) %>%
  apply(1,
        function(ms) return(mutate(fread(paste0('output/csv/posterior_', ms['model'], '_', ms['soc_code'], '.csv')),
                                   model = ms['model'], soc_code = as.integer(ms['soc_code'])))) %>%
  bind_rows() %>%
  inner_join(dt_soc_case, by = 'soc_code') %>%
  mutate(model = factor(model, levels = v_model)) %>%
  select(model, soc_name, total_case, sigma) %>%
  tbl_dt()

s_violin <- function(dt, text_color = '#000066') {
  return(ggplot(dt, aes(x = soc_name, y = sigma, fill = model)) +
           geom_hline(aes(yintercept = 0), linetype = 2, size = 0.4, alpha = 0.8, colour = '#6600FF') +
           geom_violin(trim = FALSE, linetype = 'blank', alpha = 0.8) +
           scale_x_discrete() +
           scale_y_continuous(limits = c(0, quantile(dt$sigma, 0.99))) +
           scale_fill_manual(label = c(mixed = 'MIXED', ar = 'AR'),
                             values = c(mixed = '#E377C2', ar = '#17BECF')) +
           labs(x = 'SOC', y = expression(sigma), fill = element_blank()) +
           coord_flip() +
           theme_bw() +
           theme(legend.position = 'top',
                 legend.background = element_blank(), legend.key = element_blank(),
                 legend.title = element_text(colour = text_color, size = 18),
                 legend.text = element_text(colour = text_color, size = 18),
                 axis.title.x = element_text(colour = text_color, vjust = -3, size = 22),
                 axis.title.y = element_text(colour = text_color, vjust = 3, size = 22),
                 axis.text = element_text(colour = text_color, size = 18),
                 plot.margin = unit(c(1, 0.5, 1.3, 1), 'lines'),
                 panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
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
                 axis.text.x = element_text(colour = text_color, size = 18),
                 axis.text.y = element_blank(),
                 axis.ticks.y = element_blank(),
                 plot.margin = unit(c(4, 1, 1, 0), 'lines'),
                 panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                 panel.border = element_blank(),
                 axis.line = element_line(colour = text_color)))
}

bar_violin <- function(dt) {
  return(grid.arrange(s_violin(dt), count_bar(distinct(dt, soc_name, total_case)),
                      ncol = 2, widths = c(9, 1)))
}

png('output/img/sigma_violin.png', width = 960, height = 720)
plot(bar_violin(dt_post))
dev.off()
