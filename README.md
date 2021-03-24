# dprtools
Guy Schvitz, March 23 2021

This package includes a set of functions that help simplify data pre-processing in R and are particularly suited for dealing with interval or time series data. This document walks you through the main functions with some illustrative examples. 

## Contents
  * [Installation](#installation)
  * [`unionDFs`: Union data frames with non-matching columns](#-uniondfs---union-data-frames-with-non-matching-columns)
  * [`chopIntervals`: Break down overlapping intervals in data frame into non-overlapping ones](#-chopintervals---break-down-overlapping-intervals-in-data-frame-into-non-overlapping-ones)
  * [`generateSeries`: Expand interval data frame into series](#-generateseries---expand-interval-data-frame-into-series)
  * [`plotNAs`: Plot share of NA values by variable](#-plotnas---plot-share-of-na-values-by-variable)
  * [`plotGroupedNAs`: Plot share of grouped NA values by variable](#-plotgroupednas---plot-share-of-grouped-na-values-by-variable)

## Installation
You can install the package as follows:

```r
library(devtools)
install_github("guyschvitz/dprtools")
```
You also need to install `dplyr` and `ggplot2` from CRAN (or alternatively `tidyverse`, which includes both), as well as the `viridis` package, if not already installed

```r
sapply(c("tidyverse", "viridis"), function(x){
         if(!x %in% installed.packages()[,"Package"]){install.packages(x)}})
library(tidyverse)
library(viridis)
library(dprtools)
```

## `unionDFs`: Union data frames with non-matching columns
This function allows you to union two data frames with different column names and/or number of columns, as long as the specified columns have the same types. This is illustrated below with two example datasets

```r
## Create example datasets with non-matching names
my.df1 <- data.frame(id = letters[rep(1:2, c(2,3))],
                        start = c(1,3,2,4,9),
                        end = c(5,9,6,8,12))

my.df2 <- data.frame(id = letters[rep(3:4, c(3,2))],
                        start = c(2,5,11,1,3),
                        stop = c(4,10,13,6,10))

## If we try dplyr::union we get an error
dplyr::union(my.df1, my.df2)

# Error: not compatible:
#   not compatible:
#   - Cols in y but not x: `stop`.
# - Cols in x but not y: `end`.

## Instead, use dprtools::unionDFs
unionDFs(my.df1, my.df2, c("id", "start", "end"), c("id", "start", "stop"))

# id start end
# a     1   5
# a     3   9
# b     2   6
# b     4   8
# b     9  12
# c     2   4
# c     5  10
# c    11  13
# d     1   6
# d     3  10                    
```

## `chopIntervals`: Break down overlapping intervals in data frame into non-overlapping ones
This function allows you to "chop" overlapping intervals in a dataframe (date or integer) into non-overlapping (i.e. consecutive) ones. Input must be an R data.frame (or tibble) with an id variable and two columns denoting the start and the end of an interval. To illustrate the procedure, see the figure and code below.

<img src="/demo/chop_intervals_illustration.png?raw=true" width="700">

```r
## Recall first example dataframe with overlapping intervals
my.df1

# id start end
# a     1   5
# a     3   9
# b     2   6
# b     4   8
# b     9  12

## Chop into consecutive intervals
chopIntervals(data = my.df1, id = id, start.col = "start", end.col = "end")

# id    start   end
# a         1     2
# a         3     5
# a         6     9
# b         2     3
# b         4     6
# b         7     8
# b         9    12

## This also works with dates, for example:
my.df5 <- data.frame(id = rep("a", 3),
                     start = as.Date(c("1990-01-01", "1995-09-08", "1999-12-31")),
                     end = as.Date(c("1996-01-10", "2001-08-01", "2020-03-23")))

## Chop into consecutive date intervals
chopIntervals(my.df5, id = id, start.col = "start", end.col = "end")

# id    start      end       
# a     1990-01-01 1995-09-07
# a     1995-09-08 1996-01-10
# a     1996-01-11 1999-12-30
# a     1999-12-31 2001-08-01
# a     2001-08-02 2020-03-23
```


## `generateSeries`: Expand interval data frame into series
This function mimics PostgreSQL's `generate_series` function (see [here](https://www.postgresql.org/docs/9.1/functions-srf.html)). Input must be an R data.frame (or tibble) containing an id variable, as well as two columns denoting the start and the end of an interval on each row (integer or date). Use is illustrated below using the previous example dataset.

```r

## Create example dataset
my.df3 <- data.frame(id = letters[rep(1:2, c(2,3))],
                        start = c(1,5,1,4,9),
                        end = c(4,9,3,8,12))

## Expand into "series"
my.df3.out <- generateSeries(data = my.df3, start = "start", end = "end",
                              step = 1, varname = "my_series")

## Show first couple of rows
head(my.df3.out)

# id my_series
# a         1
# a         2
# a         3
# a         4
# a         5
# a         6

## This also works with dates, for example:
my.df4 <- data.frame(id = "Switzerland",
                        start = as.Date("1990-01-01"),
                        end = as.Date("2020-01-01"))

## Create yearly series
my.df4.out <- generateSeries(data = my.df4,
                             start = "start",
                             end = "end",
                             step = 1,
                             timeint = "year",
                             varname = "date")

## Preview results
head(exmpl.df4.out)

# id       date
# Switzerland 1990-01-01
# Switzerland 1991-01-01
# Switzerland 1992-01-01
# Switzerland 1993-01-01
# Switzerland 1994-01-01
# Switzerland 1995-01-01
```

## `plotNAs`: Plot share of NA values by variable
This is a simple function that plots the share of missing values in a data frame for each variable. Returns a bar plot with bars indicating share of missings (no bars: no missings).

```r
## Create example dataframe with three random variables
set.seed(1999)
years <- 1990:2020
ids <- letters[1:10]
values <- 1:1000
out.len <- length(years) * length(ids)

my.df6 <- data.frame(id = rep(ids, each = length(years)),
                        year = rep(years, length(ids)),
                        var1 = sample(values, size = out.len, replace = T),
                        var2 = sample(values, size = out.len, replace = T),
                        var3 = sample(values, size = out.len, replace = T))

## Randomly set some values to NA
my.df6$var2 <- ifelse(sample(c(T, F), size = out.len,
                               replace = T, prob = c(0.9, 0.1)), my.df6$var2, NA)
my.df6$var3 <- ifelse(sample(c(T, F), size = out.len,
                                replace = T, prob = c(0.6, 0.4)), my.df6$var3, NA)

## Plot NA's
plotNAs(my.df6)
```

<img src="/demo/plotNAs.png?raw=true" width="700">


## `plotGroupedNAs`: Plot share of grouped NA values by variable
This function does the same as the previous one, but summarizes the missing values by a grouping variable, to give a better sense of their distribution (example: share of missing values for each variable per year). Returns a tile plot with colors indicating share of missings in each variable-group combination.

```r
plotGroupedNAs(my.df6, year)
```
<img src="/demo/plotGroupedNAs.png?raw=true" width="700">


