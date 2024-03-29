% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/d3TreeFunctions.R
\name{df2tree}
\alias{df2tree}
\title{df2tree}
\usage{
df2tree(struct, rootname = "root", tool_tip = NULL)
}
\arguments{
\item{struct}{data.frame containing the structure the tree will represent}

\item{rootname}{character name of the root node}

\item{tool_tip}{charater vector of the label to give to the
nodes in each hierarchy}
}
\description{
converts dataframe to json to send to javascript
}
\examples{
titanic_df <- as.data.frame(Titanic)

df2tree(struct = titanic_df,rootname = 'Titanic')

df2tree(
  struct = titanic_df,
  rootname = 'Titanic',
  tool_tip = letters[1:5]
)

}
