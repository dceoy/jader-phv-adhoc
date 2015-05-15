#!/usr/bin/env Rscript

source('func.R')

incr <- c('dpp4i', 'glp1a')
ct <- setnames(fread('output/csv/dm_or.csv')[,c(1, 4:5), with = FALSE], c('or', 'code', 'hlt')) %>%
        arrange(or) %>%
        select(code, hlt)

lals <- foreach (code = unique(ct$code), .packages = c('dplyr', 'tidyr', 'data.table')) %dopar% {
  return(tbl_dt(fread(paste('output/csv/stan_', code, '.csv', sep = ''))) %>%
           gather(class, value) %>%
           mutate(code = as.numeric(code)) %>%
           select(class, code, value))
}

ladt <- tbl_dt(data.table())
foreach (la = lals) %do% { ladt <- rbind(ladt, la) }

hltd <- ct$hlt
names(hltd) <- ct$code

ordt <- ladt %>%
          filter(class %in% incr) %>%
          mutate(class = factor(class, levels = rev(incr))) %>%
          inner_join(ct, by = 'code') %>%
          mutate(param = paste(hlt, 'vs', class, sep = '  ')) %>%
          mutate(value = exp(value)) %>%
          select(class, param, value)

violin <- function(smpl, odr) {
  return(ggplot(smpl, aes(x = param, y = ymed, ymin = ymin, ymax = ymax, colour = class, fill = class)) +
           geom_hline(aes(yintercept = 1), colour = '#4400FF', linetype = 2) +
           geom_pointrange(size = 0.7, shape = 15) +
           geom_violin(aes(y = value), trim = FALSE, linetype = 'blank', alpha = 0.3) +
           scale_y_log10(limits = c(0.005, 200), breaks = c(0.01, 0.1, 1, 10, 100)) +
           scale_x_discrete(limits = odr) +
           labs(x = 'MedDRA High Level Term', y = 'Odds Ratios [ 99 % Credible Intervals and Posterior Distribution ]') +
           coord_flip() +
           theme(axis.text.x = element_text(size = 14), axis.text.y = element_text(size = 14),
                 axis.title.x = element_text(colour = '#000066', vjust = 0),
                 axis.title.y = element_text(colour = '#000066', vjust = 1),
                 panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(),
                 legend.position = 'none', panel.background = element_rect(fill = '#DDDDFF')))
}

alpha <- 0.01
or_q <- ordt %>%
          group_by(class, param) %>%
          summarize(ymed = median(value),
                    ymin = quantile(value, prob = alpha / 2),
                    ymax = quantile(value, prob = 1 - alpha / 2))
orpl <- ordt %>% inner_join(or_q, by = c('class', 'param'))

x_order <- paste(sort(rep(factor(ct$hlt, levels = ct$hlt), 2)), 'vs', rev(incr), sep = '  ')

svg('output/img/violin.svg', width = 12, height = 8); plot(violin(orpl, x_order)); dev.off()
png('output/img/violin.png', width = 800, height = 500); plot(violin(orpl, x_order)); dev.off()
tiff('output/img/violin.tif', width = 800, height = 500); plot(violin(orpl, x_order)); dev.off()
