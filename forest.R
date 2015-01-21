# coding: utf-8

pload <- function(p) {
  if (!is.element(p, installed.packages()[,1])) {
    install.packages(p, dep=TRUE)
  }
  require(p, character.only=TRUE)
}

r <- getOption('repos')
r['CRAN'] <- 'http://cran.us.r-project.org'
options(repos=r)
rm(r)

pkgs <- c('ggplot2', 'rjson')

for (pkg in pkgs) {
  pload(pkg)
}

data.path <- './or_dr.json'
ors <- fromJSON(paste(readLines(data.path), collapse=''))
df <- do.call(rbind.data.frame, ors$results)

print(mode(df))
print(str(df))
print(df)

ae <- 'hypoglycemia'
svg(paste(ae, '.svg', sep=''), width=6, height=7)
#png(paste(ae, '.png', sep=''), width=400, height=400)

#df$drug <- paste(df$drug, ' ', floor(df$odds_ratio*100)/100, ' ( ', floor(df$lower_ci95*100)/100, ' - ', floor(df$upper_ci95*100)/100, ' )', sep='')

ggplot(df, aes(x=drug, y=odds_ratio, ymin=lower_ci95, ymax=upper_ci95, colour=class)) +
geom_hline(aes(yintercept=1), colour='#4400FF', linetype=2) +
geom_pointrange(size=0.7, shape=15) +
scale_y_log10(name='odds ratio', limits=c(0.1, 10)) +
scale_x_discrete(name='variables', limits=rev(df$drug)) +
scale_colour_manual(values=c('#FF00FF', '#4400FF')) +
theme(panel.grid.major=element_blank(), panel.grid.minor=element_blank(), panel.background=element_rect(fill='#DDDDFF')) +
coord_flip()

dev.off()
