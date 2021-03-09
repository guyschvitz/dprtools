##' Union dataframes with non-matching column-names / numbers
##'
##' Union dataframes with non-matching column-names / numbers
##'
##' @param data1 R data.frame or tibble 1
##' @param data2 R data.frame or tibble 2
##' @param cols1 Columns of data.frame 1 to be included
##' @param cols2 Columns of data.frame 2 to be included
##'
##' @return Union of dataframe 1 and 2 for specified columns
##'
##' @export

unionDFs <- function(df1, df2, cols1, cols2){
  df1 <- data.frame(df1)
  df2 <- data.frame(df2)
  stopifnot(length(cols1) == length(cols2))
  df1 <- df1[, cols1]
  df2 <- setNames(df2[, cols2], names(df1))
  dplyr::union(df1, df2)
}
