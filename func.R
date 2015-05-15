#!/usr/bin/env R

# package loading
load_pkgs <- function(pkgs, repos = 'http://cran.rstudio.com/') {
  sapply(pkgs,
         function(p) {
           if (p %in% installed.packages()[,1]) {
             update.packages(p, checkBuilt = TRUE, ask = FALSE, repos = repos)
           } else {
             install.packages(p, dependencies = TRUE, repos = repos)
           }
           require(p, character.only = TRUE)
         })
}

v_require <- function(pkgs) {
  sapply(pkgs, function(p) require(p, character.only = TRUE))
}


# database
connect_sqlite <- function(b) {
  return(dbConnect(dbDriver('SQLite'), b))
}

sql_dt <- function(c, q) {
  return(tbl_dt(data.table(dbGetQuery(c, q))))
}


# fisher test
fex <- function(t, alt = 'two.sided', cnf = 0.95) {
  f <- fisher.test(matrix(t, nrow = 2), alternative = alt, conf.level = cnf)
  return(c(p_val = as.numeric(f$p.value),
           or_mle = as.numeric(f$estimate),
           or_ll = as.numeric(f$conf.int[1]),
           or_ul = as.numeric(f$conf.int[2])))
}


# init cluster
pkgs <- c('RSQLite', 'dplyr', 'tidyr', 'data.table', 'foreach', 'doSNOW', 'parallel', 'ggplot2', 'ggmcmc', 'yaml', 'rstan', 'devtools')
load_pkgs(pkgs)
select <- dplyr::select

registerDoSNOW(cl <- makeCluster(detectCores(), type = 'SOCK'))
.Last <- function() try(stopCluster(cl))

