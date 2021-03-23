##' Plot missing values in dataframe
##'
##' Returns a bar plot with missing values for each variable
##' @param data dataframe
##' @return \code{ggplot2} plot
##'
##' @export
##'

plotNAs <- function(data){
  na.share <- data %>%
    dplyr::summarize_all(function(x){sum(is.na(x))/length(x)}) %>%
    mutate(idv = 1) %>%
    pivot_longer(names_to = "variable", values_to = "value", cols = -idv)

  p <- ggplot(na.share, aes(y = variable, x = value)) +
    geom_bar(stat = "identity") +
    scale_x_continuous(name = "share missing", breaks = seq(0, 1, 0.1), limits = c(0, 1)) +
    theme_classic()
  return(p)
}
