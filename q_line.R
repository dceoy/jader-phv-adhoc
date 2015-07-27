#!/usr/bin/env Rscript

source('func.R')

if (file.exists(csv_file <- 'output/csv/q_count.csv')) {
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
                ade10 a
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
                  ade10 a
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
                  "any_antidiabetes_drugs" AS class,
                  quarter,
                  COUNT(DISTINCT a.case_id) AS case_c
                FROM
                  ade10 a
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
            );'

  dt_dr <- sql_dt(con, sql_q)
  write.table(dt_dr, file = csv_file, sep = ',', row.names = FALSE, col.names = FALSE)
}

v_hgdr <- c(dpp4_inhibitor = 'DPP-4 inhibitors',
            glp1_agonist = 'GLP-1 agonists',
            oral_hypoglycemic_drugs_except_dpp4_inhibitors = 'Oral hypoglycemic drugs except DPP-4 inhibitors',
            insulin = 'Insulin',
            any_antidiabetes_drugs = 'Any antidiabetes drugs')

dt_qc <- dt_dr %>%
          expand(class, quarter) %>%
          mutate(case_c = 0) %>%
          rbind(dt_dr) %>%
          group_by(class, quarter) %>%
          summarize(case_c = sum(case_c)) %>%
          mutate(class = v_hgdr[class])

qcount <- function(dt, od = v_hgdr) {
  return(ggplot(dt, aes(x = quarter, y = case_c, group = class, colour = class)) +
           geom_point(size = 3, shape = 18) +
           geom_line(size = 1.2) +
           scale_x_discrete(breaks = c('2009q4', '2010q4', '2011q4', '2012q4', '2013q4', '2014q4'),
                            labels = c(2010, 2011, 2012, 2013, 2014, 2015)) +
           scale_y_continuous(limits = c(0, 1300), breaks = c(0:2 * 500)) +
           scale_colour_discrete(limits = od) +
           labs(x = 'Reporting Date', y = 'Unique Case Count', colour = element_blank()) +
           theme(legend.position = c(0.01, 1), legend.justification = c(0, 1),
                 legend.background = element_blank(), legend.key = element_blank(),
                 legend.text = element_text(colour = '#000066', size = 18),
                 axis.title.x = element_text(colour = '#000066', vjust = 0, size = 22),
                 axis.title.y = element_text(colour = '#000066', vjust = 1, size = 22),
                 axis.text = element_text(colour = '#000066', size = 18),
                 panel.grid.major.x = element_blank(), panel.grid.minor = element_blank(),
                 panel.background = element_rect(fill = '#E8E8FF')))
}

three_plot(qcount(dt_qc), path = 'output/img/', name = 'q_count')
