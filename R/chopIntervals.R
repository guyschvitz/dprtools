##' "Chopping" overlapping intervals in dataframe
##'
##' Function to chop overlapping ranges (date or integer) into non-overlapping ones
##'
##' @param data R data.frame or tibble
##' @param id Id variable (function assumes grouped values)
##' @param start col Variable defining start of interval
##' @param start col Variable defining end of interval
##'
##' @return Dataframe containing series
##'
##' @export

chopIntervals <- function(data, id, start.col, end.col){
  q.id <- enquo(id)
  is.date <- inherits(data[, start.col], "Date")
  convFun <- function(x){
    if(is.date){as.Date(x, origin = "1970-01-01")
    }else{
      as.numeric(x)}
  }

  data %>%
    dplyr::select(c(!!q.id, {{start.col}}, {{end.col}})) %>%
    gather(var, val, -!!q.id) %>%
    mutate(end = ifelse(var=={{end.col}}, T,
                        ifelse(var == {{start.col}}, F, NA))) %>%
    group_by(!!q.id) %>%
    arrange(!!q.id, val) %>%
    distinct() %>%
    mutate(end_next = lead(end),
           val_next = lead(val)) %>%
    filter(!is.na(end_next)) %>%
    mutate(start = ifelse(!end, val, val + 1),
           end = ifelse(!end_next, val_next - 1, val_next)) %>%
    filter(end >= start) %>%
    dplyr::select(!!q.id, start, end) %>%
    mutate(start = convFun(start),
           end = convFun(end))
}
