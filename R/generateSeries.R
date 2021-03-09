##' Expand interval dataframe into series
##'
##' Expand dataframe containing an interval (date or integer) into single-column series of values. This function mimics the generate_series function in PostgreSQL
##'
##' @param data R dataframe or tibble
##' @param start Variable defining start of interval
##' @param stop Variable defining end of interval
##' @param step Step size of output series. Default: 1
##' @param timeint Time increment, for dates only; Use Days, weeks, months, quarters or years. Default: 1 day
##' @param varname Name of series variable. Default: "generate_series"
##'
##' @return Dataframe containing series
##'
##' @export

generateSeries <- function(data, start, stop, step = 1, timeint = "day", varname = "series"){
  ## Make sure format is R data.frame
  data <- as.data.frame(data)

  ## Check if interval has type date
  date <- inherits(data[, start], "Date") & inherits(data[, end], "Date")
  if(date){
    step <- paste(step, timeint)
  }

  ## Generate sequence for each row in both columns
  seq.out <- Map(seq, data[, start], data[, stop], step)

  ## Repeat data.frame rows to match sequence length
  data.out <- as.data.frame(lapply(data, rep, sapply(seq.out, length)))

  ## Add sequence variable
  data.out$var <- if(date){as.Date(do.call(seq.out), origin = "1970-01-01")}
  else {unlist(seq.out)}

  ## Add variable name, return output
  names(data.out)[which(names(data.out)=="var")] <- varname
  return(data.out[,!names(data.out)%in% c(start, stop)])
}
