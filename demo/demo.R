
library(dprtools)
library(tidyverse)

setwd("~/Documents/ICR/github/dprtools/R")


################################################################################
## UnionDFs
################################################################################

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

################################################################################
## Generate series
################################################################################

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

################################################################################
## Chopintervals
################################################################################

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

chopIntervals(my.df5, id = id, start.col = "start", end.col = "end")

# id    start      end
# a     1990-01-01 1995-09-07
# a     1995-09-08 1996-01-10
# a     1996-01-11 1999-12-30
# a     1999-12-31 2001-08-01
# a     2001-08-02 2020-03-23

## Create example dataset 3 (time series with random NAs)
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

pdf("../demo/plotNAs.pdf", 7,5)
plotNAs(my.df6)
dev.off()

pdf("../demo/plotNAs.pdf", 7,5)
plotGroupedNAs(my.df6, year)
dev.off()


################################################################################
## Demonstrate functions
################################################################################

## Union dfs
union(exmpl.df1, exmpl.df2)
unionDFs(exmpl.df1, exmpl.df2, names(exmpl.df1), names(exmpl.df2))

## Chop Intervals
exmpl.df1.chop <- chopIntervals(exmpl.df1, id, "start", "end")

exmpl.df1$version <- "Before"
exmpl.df1.chop$version <- "After"
exmpl.df1.full <- unionDFs(exmpl.df1, exmpl.df1.chop, names(exmpl.df1), names(exmpl.df1.chop))

## Plot results
cols <- rev(viridis::viridis_pal(option="C")(3)[1:2])

exmpl.plot <- ggplot(exmpl.df1.full, aes(x = fct_rev(id), y = end, col = fct_rev(id))) +
  geom_errorbar(aes(ymin = start, ymax = end + 1), width = 0.3,
                position = position_dodge2(width = 1), size = 0.8) +
  scale_color_manual(values = cols, name = "id") +
  scale_y_continuous(breaks = seq(1:max(iv.df$end))) +
  coord_flip() +
  theme_void() +
  facet_wrap(vars(fct_rev(version))) +
  guides(colour = guide_legend(reverse=T)) +
  theme(plot.margin = unit(rep(0.5, 4), "cm"), legend.position = "none")

pdf("chop_intervals_illustration.pdf", 5.5,2)
exmpl.plot
dev.off()




plotNAs(na.df)
plotGroupedNAs(na.df, year)
iv.df2 <- chopIntervals(iv.df, id, "start", "end")



plotNAs <- function(data){
  sumNAs <- function(x){sum(is.na(x))}
  na.count <- data %>%
    dplyr::summarize_all(sumNA) %>%
    mutate(idv = 1) %>%
    melt(., id.vars = "idv")

  p <- ggplot(na.count, aes(y = variable, x = value)) +
    geom_bar(stat = "identity") +
    scale_x_continuous(name = "missing obs.") +
    theme_GS()
  return(p)
}




