% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clustpro.R
\name{color_spectrum}
\alias{color_spectrum}
\title{Function to to define the color spectrum for heatmaps}
\usage{
color_spectrum(intervals, color_spect)
}
\arguments{
\item{intervals}{list of numerical vaules which define the breaks of the color space}

\item{color_spect}{list of colors}
}
\description{
This function allows you to define the color spectrum for heatmaps.
}
\examples{
color_spectrum(c(1,2,3),c('red','green'))
}
