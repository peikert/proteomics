% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clustpro.R
\name{order_dataframe_by_list}
\alias{order_dataframe_by_list}
\title{order_dataframe_by_list
order a data.frame by the order of a list
.................}
\usage{
order_dataframe_by_list(x, list, col, reverse = FALSE)
}
\arguments{
\item{x}{numeric data.frame}

\item{list}{list, unique list of numbers or character in whished order}

\item{col}{character or numerical, col with should be ordered in accordance to list}

\item{reverse}{boolean, if TRUE reverse order of list}
}
\description{
order_dataframe_by_list
order a data.frame by the order of a list
.................
}
\examples{
df_tmp <- mtcars
df_tmp$model <- rownames(df_tmp)
order_dataframe_by_list(x = df_tmp
,list = sample(df_tmp$model,nrow(df_tmp)
,replace = FALSE)
,col = 'model')
}
