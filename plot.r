#!/usr/bin/Rscript

library(readr)
library(ggplot2)
library(dplyr)
library(tidyr)
library(tibble)
library(stringr)
library(purrr)

args = commandArgs(trailingOnly=TRUE)

if (length(args) != 3) {
  cat("Usage: COMMAND metric_list csv outdir")
  quit()
}

metric_list <- args[1]
csv         <- args[2]
outdir      <- args[3]

df <- read_csv(csv)

top_n <- function(df, n = 5) {
  cols <- select(df, -time) %>%
    purrr::map_dbl(mean, na.rm=T)        %>%
    .[head(order(., decreasing=T), n=n)] %>%
    names()
  bind_cols(select(df, time, cols))
}

has_option <- function(args, cond) {
  any(str_detect(args, cond))
}

for (l in read_lines(metric_list)) {
  record <- str_split(l, regex("\\s+"))[[1]]
  metric <- record[1]
  if (metric == "") {
    break
  }
  args   <- tail(record, n=-1)

  info = ""
  d <- select(df, contains(metric), time)

  if (has_option(args, "top")) {
    d <- top_n(d)
    info = " (top10)"
  }

  p <- d %>%
    gather("col", "val", -time) %>%
    ggplot() + geom_line(mapping=aes(time, val, color=col)) +
      labs(y=str_c(metric, info), color="")

  path <- str_c(outdir, "/", metric, ".png")
  ggsave(file=path, plot=p)
}
