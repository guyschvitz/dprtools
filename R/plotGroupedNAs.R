##' Plot missing values in dataframe by grouping variable
##'
##' Returns a tile plot with percentages of missing observations for each grouped variable
##'
##' @param data R data.frame or tibble
##' @param groupvar Variable to group missing observations by
##' @return \code{ggplot2} plot
##'
##' @export
##'

plotGroupedNAs <- function(data, groupvar){
  ## ... function: compute share of missing values
  shareNAs <- function(x){sum(is.na(x)) / length(x)}

  ## ... Compute and plot share of missing values by grouping variable
  q.groupvar <-  rlang::enquo(groupvar)
  na.share <- data %>%
    group_by(!!q.groupvar) %>%
    dplyr::summarize_all(shareNAs) %>%
    reshape2::melt(id.vars = quo_name(q.groupvar))

  p <- ggplot(na.share, aes(x=!!q.groupvar, y=variable, fill=value)) +
    theme_classic() +
    geom_tile(alpha=0.9) +
    viridis::scale_fill_viridis(name = "share missing", limits = c(0,1)) +
    theme(axis.text.x = element_text(angle = 90),
          axis.ticks.x = element_blank())
  return(p)
}



