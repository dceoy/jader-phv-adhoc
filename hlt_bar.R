#!/usr/bin/env Rscript

source('func.R')

if(file.exists(csv_file <- 'output/csv/hlt_count.csv')) {
  dt <- setnames(fread(csv_file), c('class', 'hlt', 'case_c'))
} else {
  con <- connect_sqlite('mj.sqlite3')

  sql_h <- 'SELECT
              class,
              hlt_name AS hlt,
              count(distinct case_id) AS case_c
            FROM
              ade a
            INNER JOIN
              d_class d ON d.drug == a.drug
            INNER JOIN
              hlt h ON h.hlt_code == a.hlt_code
            WHERE
              class IN ("dpp4_inhibitor", "glp1_agonist")
            GROUP BY
              class, hlt_name;'

  dt <- sql_dt(con, sql_h)
  write.table(dt, file = csv_file, sep = ',', row.names = FALSE, col.names = FALSE)
}

read_tc <- function(file) {
  return(fread(file)[,c(2, 3, 6, 8), with = FALSE] %>%
           setnames(c('or', 'll', 'hlt', 'total_c')) %>%
           mutate(total_c = as.integer(total_c)) %>%
           filter(ll > 1) %>%
           arrange(or) %>%
           distinct(hlt) %>%
           select(hlt, total_c))
}

ecount <- function(dt, odr) {
  return(ggplot(dt, aes(x = hlt, y = case_c, fill = class)) +
           geom_bar(stat='identity', position = 'dodge') +
           scale_y_continuous(limits = c(0, 400), breaks = c(0:3 * 100)) +
           scale_x_discrete(limits = odr) +
           labs(x = 'MedDRA High Level Term', y = 'Unique Case Count') +
           coord_flip() +
           theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(),
                 axis.title.x = element_text(colour = '#000066', vjust = 0, size = 24),
                 axis.title.y = element_text(colour = '#000066', vjust = 1, size = 24),
                 axis.text = element_text(colour = '#000066', size = 18),
                 panel.background = element_rect(fill = '#DDDDFF')))
}

v_hgdr <- c(dpp4_inhibitor = 'DPP-4 inhibitors', glp1_agonist = 'GLP-1 agonists')
tcc <- read_tc('output/csv/mixed_or.csv')
dt_e <- dt %>%
          filter(hlt %in% tcc$hlt) %>%
          mutate(class = v_hgdr[class])

three_plot(ecount(dt_e, odr = tcc$hlt), path = 'output/img/', name = 'hlt_bar')
