#!/usr/bin/env R

# package loading
load_pkgs <- function(pkgs, repos = 'http://cran.rstudio.com/') {
  update.packages(checkBuilt = TRUE, ask = FALSE, repos = repos)
  sapply(pkgs,
         function(p) {
           if(! p %in% installed.packages()[, 1]) install.packages(p, dependencies = TRUE, repos = repos)
           require(p, character.only = TRUE)
         })
}

require_v <- function(pkgs) {
  sapply(pkgs, function(p) require(p, character.only = TRUE))
}

# plot data
svg_plot <- function(data, file, w = 16, h = 10) {
  svg(file, width = w, height = h)
  plot(data)
  dev.off()
}

png_plot <- function(data, file, w = 880, h = 550) {
  png(file, width = w, height = h)
  plot(data)
  dev.off()
}

tif_plot <- function(data, file, w = 880, h = 550) {
  tiff(file, width = w, height = h)
  plot(data)
  dev.off()
}

jpg_plot <- function(data, file, w = 880, h = 550) {
  jpeg(file, width = w, height = h)
  plot(data)
  dev.off()
}

pdf_traceplot <- function(data, path, name) {
  pdf(paste(path, 'plot_', name, '.pdf', sep = ''))
  plot(data)
  dev.off()
  pdf(paste(path, 'traceplot_', name, '.pdf', sep = ''))
  traceplot(data)
  dev.off()
}

# database
connect_sqlite <- function(file, type = 'SQLite') {
  return(dbConnect(dbDriver(type), file))
}

sql_dt <- function(con, sql) {
  return(tbl_dt(data.table(dbGetQuery(con, sql))))
}

# init
require_v(pkgs <- c('dplyr',
                    'tidyr',
                    'data.table',
                    'RSQLite',
                    'foreach',
                    'doSNOW',
                    'ggplot2',
                    'gridExtra',
                    'grid',
                    'glmmML'))
select <- dplyr::select
