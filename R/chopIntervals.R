##' "Chopping" overlapping intervals in dataframe
##'
##' Function to chop overlapping ranges (date or integer) into non-overlapping ones
##'
##' @param data R data.frame or tibble
##' @param id A string specifying the name of the id column(s) used to group dataframe
##' @param start.col Column defining start of interval
##' @param start.col Column defining end of interval
##'
##' @return Grouped dataframe containing "chopped" (i.e. non-overlapping) intervals
##'
##' @export

chopIntervals <- function(data, id.vars, start.col, end.col){
  data %>%
    dplyr::select(c(all_of(id.vars), {{start.col}}, {{end.col}})) %>%
    pivot_longer(names_to = "var", values_to = "val", c(start.col, end.col)) %>%
    mutate(end = if_else(var==end.col, T,
                         if_else(var == start.col, F, NA))) %>%
    group_by_at(id.vars) %>%
    arrange_at(c(id.vars, "val")) %>%
    distinct() %>%
    mutate(end_next = lead(end),
           val_next = lead(val)) %>%
    filter(!is.na(end_next)) %>%
    mutate(start = if_else(!end, val, val + 1),
           end = if_else(!end_next, val_next - 1, val_next)) %>%
    filter(end >= start) %>%
    dplyr::select(all_of(id.vars), start, end)
}


