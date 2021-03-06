% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generateSeries.R
\name{generateSeries}
\alias{generateSeries}
\title{Expand interval dataframe into series}
\usage{
generateSeries(
  data,
  start,
  stop,
  step = 1,
  timeint = "day",
  varname = "series"
)
}
\arguments{
\item{data}{R dataframe or tibble}

\item{start}{Variable defining start of interval}

\item{stop}{Variable defining end of interval}

\item{step}{Step size of output series. Default: 1}

\item{timeint}{Time increment, for dates only; Use Days, weeks, months, quarters or years. Default: 1 day}

\item{varname}{Name of series variable. Default: "generate_series"}
}
\value{
Dataframe containing series
}
\description{
Expand dataframe containing an interval (date or integer) into single-column series of values. This function mimics the generate_series function in PostgreSQL
}
