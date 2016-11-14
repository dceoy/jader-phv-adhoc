#!/usr/bin/env Rscript

sapply(c('dplyr', 'tidyr', 'dtplyr', 'data.table', 'ggplot2'), require, character.only = TRUE)
setwd('~/GoogleDrive/lab/s3_phv/')
if(! dir.exists(img_dir <- 'output/img')) dir.create(img_dir)
select <- dplyr::select

dt_soc <- tbl_dt(fread('input/csv/dt_soc.csv'))
dt_yid <- tbl_dt(fread('input/csv/dt_yid.csv'))
dt_case <- tbl_dt(bind_rows(lapply(dt_soc$soc_code,
                                   function(cd) {
                                     return(fread(paste0('input/csv/dt_', cd, '.csv')) %>%
                                            filter(event == 1) %>%
                                            group_by(yid) %>%
                                            summarize(case_count = n()) %>%
                                            mutate(soc_code = cd))
                                   }))) %>%
  inner_join(dt_yid, by = 'yid') %>%
  inner_join(dt_soc, by = 'soc_code')
dt_soc_case <- dt_case %>%
  group_by(soc_code) %>%
  summarize(total_case = sum(case_count)) %>%
  inner_join(dt_soc, by = 'soc_code') %>%
  arrange(total_case)
write.table(dt_case, file = 'input/csv/dt_case.csv', sep = ',', row.names = FALSE)
write.table(dt_soc_case, file = 'input/csv/dt_soc_case.csv', sep = ',', row.names = FALSE)
dt_bar <- dt_case %>%
  mutate(soc_name = factor(soc_name, levels = rev(dt_soc_case$soc_name)),
         year = factor(year, level = rev(sort(unique(year)))))

y_bar <- function(dt, plain_color = TRUE, text_color = '#000066') {
  if(plain_color) {
    return(ggplot(dt, aes(x = soc_name, y = case_count, fill = year)) +
             geom_bar(stat = 'identity') +
             scale_x_discrete() +
             scale_y_continuous(expand = c(0, 0)) +
             scale_fill_grey(guide = guide_legend(reverse = TRUE)) +
             labs(x = 'SOC', y = 'Case count', fill = 'Fiscal year') +
             coord_flip() +
             theme_bw() +
             theme(legend.position = 'top',
                   legend.background = element_blank(), legend.key = element_blank(),
                   legend.title = element_text(size = 14),
                   legend.text = element_text(size = 14),
                   axis.title.x = element_text(vjust = -3, size = 20),
                   axis.title.y = element_text(vjust = 3, size = 20),
                   axis.text = element_text(size = 12),
                   plot.margin = unit(c(1, 2, 1, 1), 'lines'),
                   panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                   panel.border = element_blank(),
                   axis.line = element_line()))
  } else {
    return(ggplot(dt, aes(x = soc_name, y = case_count, fill = year)) +
             geom_bar(stat = 'identity', alpha = 0.8) +
             scale_x_discrete() +
             scale_y_continuous(expand = c(0, 0)) +
             labs(x = 'SOC', y = 'Case count', fill = 'Fiscal year') +
             coord_flip() +
             theme_bw() +
             theme(legend.position = 'top',
                   legend.background = element_blank(), legend.key = element_blank(),
                   legend.title = element_text(colour = text_color, size = 18),
                   legend.text = element_text(colour = text_color, size = 18),
                   axis.title.x = element_text(colour = text_color, vjust = -3, size = 22),
                   axis.title.y = element_text(colour = text_color, vjust = 3, size = 22),
                   axis.text.x = element_text(colour = text_color, size = 18),
                   axis.text.y = element_text(colour = text_color, size = 16),
                   plot.margin = unit(c(1, 2, 1, 1), 'lines'),
                   panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                   panel.border = element_blank(),
                   axis.line = element_line(colour = text_color)))
  }
}

svg('output/img/year_count.svg', width = 10, height = 10)
plot(y_bar(dt_bar))
dev.off()
