# coding: utf-8

pload <- function(p) {
  if (! p %in% installed.packages()[,1]) install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}

r <- getOption('repos')
r['CRAN'] <- 'http://cran.us.r-project.org'
options(repos = r)
rm(r)

ps <- c('RSQLite', 'ggplot2')
names(ps) <- ps
sapply(ps, pload)


driver <- dbDriver('SQLite')
db <- 'jader.sqlite3'
con <- dbConnect(driver, db)

tab_sql <- 'SELECT
              hlt, class, ROR, LL95, UL95
            FROM
              dmHltRor
            WHERE
              LL95 >= 1 AND LL95 != \'NA\';'

df <- data.frame(dbGetQuery(con, tab_sql))

hlt_ttl_sql <- 'SELECT
                  hlt
                FROM
                  dmHltRor
                WHERE
                  LL95 >= 1 AND LL95 != \'NA\'
                GROUP BY
                  hlt
                ORDER BY
                  max(ROR) DESC;'

hlt_ttl <- dbGetQuery(con, hlt_ttl_sql)

hlts <- as.vector(hlt_ttl$hlt)

df$class <- gsub('_', ' ', df$class)
drugs <- c('DPP-4 Inhibitor',
           'GLP-1 Analog',
           'Sulfonylurea',
           'Rapid Acting Insulin Secretagogue',
           'Alpha-Glucosidase Inhibitor',
           'Biguanide',
           'Thiazolidinedione',
           'Insulin')

file_name <- 'ror'
svg(paste('img/', file_name, '.svg', sep=''), width=12, height=8)

p <- ggplot(df, aes(x=hlt, y=class, fill=ROR)) +
     geom_tile() +
     scale_fill_gradient(trans='log', breaks=c(4, 40, 400), low='grey', high='blue', na.value='#FFFFFF') +
     labs(x='MedDRA HLT', y='Drug Class') +
     scale_x_discrete(expand=c(0, 0), limits=hlts) +
     scale_y_discrete(expand=c(0, 0), limits=rev(drugs)) +
     theme(axis.ticks=element_blank(), axis.text.x=element_text(size=4, angle=270, hjust=0, colour='#000000'))

print(p)

dev.off()
