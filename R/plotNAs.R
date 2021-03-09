##' Plot missing values in dataframe
##'
##' Returns a bar plot with missing values for each variable
##' @param data dataframe
##' @return \code{ggplot2} plot
##'
##' @export
##'

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
