#!/usr/bin/env Rscript

source('func.R')

if(file.exists(csv_file <- 'output/csv/q_count.csv')) {
  dt_dr <- setnames(fread(csv_file), c('class', 'quarter', 'case_c'))
} else {
  con <- connect_sqlite('mj.sqlite3')

  sql_q <- 'SELECT
              class,
              CASE
                WHEN quarter LIKE "%・第一" THEN REPLACE(quarter, "・第一", "q1")
                WHEN quarter LIKE "%・第二" THEN REPLACE(quarter, "・第二", "q2")
                WHEN quarter LIKE "%・第三" THEN REPLACE(quarter, "・第三", "q3")
                WHEN quarter LIKE "%・第四" THEN REPLACE(quarter, "・第四", "q4")
              END AS quarter,
              case_c
            FROM (
              SELECT
                class,
                quarter,
                COUNT(DISTINCT a.case_id) AS case_c
              FROM
                ade a
              INNER JOIN
                demo d ON d.case_id == a.case_id
              INNER JOIN
                d_class c ON c.drug == a.drug
              WHERE
                class IN ("dpp4_inhibitor", "glp1_agonist", "insulin")
              GROUP BY
                class, quarter
              UNION ALL
                SELECT
                  "oral_hypoglycemic_drugs_except_dpp4_inhibitors" AS class,
                  quarter,
                  COUNT(DISTINCT a.case_id) AS case_c
                FROM
                  ade a
                INNER JOIN
                  demo d ON d.case_id == a.case_id
                WHERE
                  drug IN (
                    SELECT DISTINCT
                      drug
                    FROM
                      d_class
                    WHERE
                      class NOT IN ("dpp4_inhibitor", "glp1_agonist", "insulin")
                  )
                GROUP BY
                  quarter
              UNION ALL
                SELECT
                  "any_hypoglycemic_drugs" AS class,
                  quarter,
                  COUNT(DISTINCT a.case_id) AS case_c
                FROM
                  ade a
                INNER JOIN
                  demo d ON d.case_id == a.case_id
                WHERE
                  drug IN (
                    SELECT DISTINCT
                      drug
                    FROM
                      d_class
                  )
                GROUP BY
                  quarter
              UNION ALL
                SELECT
                  "all" AS class,
                  quarter,
                  COUNT(DISTINCT a.case_id) AS case_c
                FROM
                  ade a
                INNER JOIN
                  demo d ON d.case_id == a.case_id
                GROUP BY
                  quarter
            );'

  dt_dr <- sql_dt(con, sql_q)
  write.table(dt_dr, file = csv_file, sep = ',', row.names = FALSE, col.names = FALSE)
}

v_hgdr <- c(dpp4_inhibitor = 'DPP-4 inhibitors',
            glp1_agonist = 'GLP-1 agonists',
            oral_hypoglycemic_drugs_except_dpp4_inhibitors = 'Oral hypoglycemic drugs except DPP-4 inhibitors',
            insulin = 'Insulin',
            any_hypoglycemic_drugs = 'Any hypoglycemic drugs',
            all = 'all')

dt_qc <- dt_dr %>%
           expand(class, quarter) %>%
           mutate(case_c = 0) %>%
           rbind(dt_dr) %>%
           group_by(class, quarter) %>%
           summarize(case_c = sum(case_c)) %>%
           ungroup() %>%
           mutate(class = v_hgdr[class])

count_line <- function(dt, dc, plain_color = TRUE) {
  if(plain_color) {
    return(ggplot(dt, aes(x = quarter, y = case_c, group = class, linetype = class)) +
             geom_line(size = 1.2) +
             scale_x_discrete(breaks = c('2009q4', '2010q4', '2011q4', '2012q4', '2013q4', '2014q4')) +
             scale_y_continuous(limits = c(0, 1300), breaks = c(500 * (0:2)), expand = c(0, 0)) +
             scale_linetype_discrete(limits = dc) +
             labs(y = 'Case count', linetype = element_blank()) +
             theme_bw() +
             theme(legend.position = c(0.02, 1), legend.justification = c(0, 1),
                   legend.background = element_blank(),
                   legend.key.width = unit(5, 'line'),
                   legend.text = element_text(size = 16),
                   axis.title.x = element_blank(),
                   axis.title.y = element_text(vjust = 3.5, size = 18),
                   axis.text.x = element_blank(),
                   axis.text.y = element_text(size = 16),
                   plot.margin = unit(c(1, 1, 1, 1.7), 'lines'),
                   panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                   panel.border = element_blank(),
                   axis.line = element_line()))
  } else {
    return(ggplot(dt, aes(x = quarter, y = case_c, group = class, colour = class)) +
             geom_point(size = 4, shape = 18) +
             geom_line(size = 1.6, alpha = 0.5) +
             scale_x_discrete(breaks = c('2009q4', '2010q4', '2011q4', '2012q4', '2013q4', '2014q4')) +
             scale_y_continuous(limits = c(0, 1300), breaks = c(500 * (0:2)), expand = c(0, 0)) +
             scale_colour_discrete(limits = dc) +
             labs(y = 'Case count', colour = element_blank()) +
             theme_bw() +
             theme(legend.position = c(0.02, 1), legend.justification = c(0, 1),
                   legend.background = element_blank(), legend.key = element_blank(),
                   legend.text = element_text(colour = '#000066', size = 20),
                   axis.title.x = element_blank(),
                   axis.title.y = element_text(colour = '#000066', vjust = 3.5, size = 24),
                   axis.text.x = element_blank(),
                   axis.text.y = element_text(colour = '#000066', size = 20),
                   plot.margin = unit(c(1, 1, 1, 1.7), 'lines'),
                   panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                   panel.border = element_blank(),
                   axis.line = element_line(colour = '#000066')))
  }
}

count_area <- function(dt, plain_color = TRUE) {
  if(plain_color) {
    return(ggplot(dt, aes(x = quarter, y = case_c, group = class)) +
             geom_area(fill = '#AAAAAA') +
             scale_x_discrete(breaks = c('2009q4', '2010q4', '2011q4', '2012q4', '2013q4', '2014q4'),
                              labels = c(2010, 2011, 2012, 2013, 2014, 2015)) +
             scale_y_continuous(breaks = c(0, 10000), expand = c(0, 0)) +
             labs(x = 'Reporting period', y = 'Total', colour = element_blank()) +
             theme_bw() +
             theme(legend.position = 'none',
                   axis.title.x = element_text(vjust = -1, size = 18),
                   axis.title.y = element_text(vjust = 2, size = 18),
                   axis.text = element_text(size = 16),
                   plot.margin = unit(c(0, 1, 1, 1), 'lines'),
                   panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                   panel.border = element_blank(),
                   axis.line = element_line()))
  } else {
    return(ggplot(dt, aes(x = quarter, y = case_c, group = class)) +
             geom_area(fill = '#000066', alpha = 0.2) +
             scale_x_discrete(breaks = c('2009q4', '2010q4', '2011q4', '2012q4', '2013q4', '2014q4'),
                              labels = c(2010, 2011, 2012, 2013, 2014, 2015)) +
             scale_y_continuous(breaks = c(0, 10000), expand = c(0, 0)) +
             labs(x = 'Reporting period', y = 'Total', colour = element_blank()) +
             theme_bw() +
             theme(legend.position = 'none',
                   axis.title.x = element_text(colour = '#000066', vjust = -1, size = 24),
                   axis.title.y = element_text(colour = '#000066', vjust = 2, size = 24),
                   axis.text = element_text(colour = '#000066', size = 20),
                   plot.margin = unit(c(0, 1, 1, 1), 'lines'),
                   panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                   panel.border = element_blank(),
                   axis.line = element_line(colour = '#000066')))
  }
}

line_area <- function(dt, dc) {
  return(grid.arrange(count_line(filter(dt, class != 'all'), setdiff(dc, 'all')),
                      count_area(filter(dt, class == 'all')),
                      nrow = 2, heights = c(5, 1)))
}

svg_plot(line_area(dt_qc, v_hgdr),
         file = 'output/img/q_count.svg',
         w = 10, h = 10)
