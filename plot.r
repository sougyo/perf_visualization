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
df <- df %>%
  filter(apply(!is.na(df %>% select(-time)), 1, any))

top_n <- function(df, n = 10) {
  cols <- select(df, -time)       %>%
    purrr::map_dbl(mean, na.rm=T) %>%
    sort()                        %>%
    rev()                         %>%
    names()                       %>%
    head(n=n)

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
  args <- tail(record, n=-1)

  info = ""
  d <- select(df, contains(metric), time)

  if (has_option(args, "fillna")) {
    d[is.na(d)] <- 0
  }

  if (has_option(args, "top")) {
    d <- top_n(d)
    info = " (top10)"
  }

  p <- d %>% gather("col", "val", -time) %>% ggplot()
  if (has_option(args, "stack")) {
    p <- p + geom_area(mapping=aes(time, val, group=col, fill=col))
  } else {
    p <- p + geom_line(mapping=aes(time, val, color=col))
  }
  p <- p + ylim(0, NA) +
         labs(y=str_c(metric, info), color="", fill="") +
         theme(legend.position = "bottom", legend.direction = "vertical") +
         scale_y_continuous(labels = scales::comma)

  path <- str_c(outdir, "/", metric, ".png")
  ggsave(file=path, plot=p)
}
