#!/usr/bin/env Rscript

source('func.R')

if (file.exists(data_path <- 'output/csv/case_count.csv')) {
  dt <- setnames(fread(data_path), c('class', 'quarter', 'case_count'))
} else {
  db <- 'mj.sqlite3'
  con <- connect_sqlite(db)

  sql_q <- 'SELECT
              class,
              CASE
                WHEN quarter LIKE "%・第一" THEN REPLACE(quarter, "・第一", "q1")
                WHEN quarter LIKE "%・第二" THEN REPLACE(quarter, "・第二", "q2")
                WHEN quarter LIKE "%・第三" THEN REPLACE(quarter, "・第三", "q3")
                WHEN quarter LIKE "%・第四" THEN REPLACE(quarter, "・第四", "q4")
              END AS quarter,
              case_count
            FROM (
              SELECT
                class,
                quarter,
                COUNT(DISTINCT a.case_id) AS case_count
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
                  COUNT(DISTINCT a.case_id) AS case_count
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
                  COUNT(DISTINCT a.case_id) AS case_count
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

  dt <- sql_dt(con, sql_q)
  write.table(dt, file = data_path, sep = ',', row.names = FALSE, col.names = FALSE)
}

dr = c(dpp4_inhibitor = 'DPP-4 inhibitors',
       glp1_agonist = 'GLP-1 agonists',
       oral_hypoglycemic_drugs_except_dpp4_inhibitors = 'Oral hypoglycemic drugs except DPP-4 inhibitors',
       insulin = 'Insulin',
       any_antidiabetes_drugs = 'Any antidiabetes drugs')

dt_f <- dt %>%
          expand(class, quarter) %>%
          mutate(case_count = 0) %>%
          rbind(dt) %>%
          group_by(class, quarter) %>%
          summarize(case_count = sum(case_count)) %>%
          mutate(class = dr[class])

series <- ggplot(dt_f, aes(x = quarter, y = case_count, group = class, colour = class)) +
            geom_point(size = 2.4, shape = 18) +
            geom_line() +
            scale_x_discrete(breaks = c('2009q4', '2010q4', '2011q4', '2012q4', '2013q4'),
                             labels = c(2010, 2011, 2012, 2013, 2014)) +
            scale_y_continuous(limits = c(0, 1300), breaks = c(0, 1:2 * 500)) +
            scale_colour_discrete(limits = dr) +
            labs(x = 'Reporting Date', y = 'Unique Case Count', colour = element_blank()) +
            theme(legend.position = c(0, 1), legend.justification = c(0, 1),
                  legend.background = element_blank(), legend.key = element_blank(),
                  legend.text = element_text(colour = '#000066'),
                  axis.title.x = element_text(colour = '#000066', vjust = 0),
                  axis.title.y = element_text(colour = '#000066', vjust = 1),
                  panel.grid.major.x = element_blank(), panel.grid.minor = element_blank(),
                  panel.background = element_rect(fill = '#DDDDFF'))

svg('output/img/case_count.svg', width = 12, height = 8); plot(series); dev.off()
png('output/img/case_count.png', width = 800, height = 500); plot(series); dev.off()
tiff('output/img/case_count.tif', width = 800, height = 500); plot(series); dev.off()
