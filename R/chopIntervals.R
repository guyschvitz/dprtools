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

  ## Function to convert numeric or string dates
  ## to date format (ifelse converts dates into numeric)
  dateConv <- function(x){
    if(inherits(x, "Date")){
      return(as.Date(x))
    } else {
      return(x)
    }}

  ## Main code
  data %>%
    dplyr::select(c(all_of(id.vars), {{start.col}}, {{end.col}})) %>%
    pivot_longer(names_to = "var", values_to = "val", c(start.col, end.col)) %>%
    mutate(end = ifelse(var==end.col, T,
                         ifelse(var == start.col, F, NA))) %>%
    group_by_at(id.vars) %>%
    arrange_at(c(id.vars, "val")) %>%
    distinct() %>%
    mutate(end_next = lead(end),
           val_next = lead(val)) %>%
    filter(!is.na(end_next)) %>%
    mutate(start = ifelse(!end, val, val + 1),
           end = ifelse(!end_next, val_next - 1, val_next)) %>%
    filter(end >= start) %>%
    dplyr::select(all_of(id.vars), start, end)
}


