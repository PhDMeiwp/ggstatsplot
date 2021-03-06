% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ggpiestats.R
\name{ggpiestats}
\alias{ggpiestats}
\title{Pie charts with statistical tests}
\usage{
ggpiestats(data, main, condition = NULL, counts = NULL, ratio = NULL,
  paired = FALSE, factor.levels = NULL, stat.title = NULL,
  sample.size.label = TRUE, title = NULL, caption = NULL,
  nboot = 25, legend.title = NULL, facet.wrap.name = NULL, k = 3,
  facet.proptest = TRUE, ggtheme = ggplot2::theme_bw(),
  ggstatsplot.layer = TRUE, package = "RColorBrewer",
  palette = "Dark2", direction = 1, messages = TRUE)
}
\arguments{
\item{data}{The data as a data frame (matrix or tables will not be accepted).}

\item{main}{The variable to use as the \strong{rows} in the
contingency table.}

\item{condition}{The variable to use as the \strong{columns} in the contingency
table.}

\item{counts}{A string naming a variable in data containing counts, or \code{NULL}
if each row represents a single observation (Default).}

\item{ratio}{A vector of numbers: the expected proportions for the proportion
test. Default is \code{NULL}, which means if there are two levels \code{ratio = c(1,1)}, etc.}

\item{paired}{Logical indicating whether data came from a within-subjects
design study (Default: \code{FALSE}). If \code{TRUE}, McNemar test subtitle will be
returned. If \code{FALSE}, Pearson's chi-square test will be returned.}

\item{factor.levels}{A character vector with labels for factor levels of
\code{main} variable.}

\item{stat.title}{Title for the effect being investigated with the chi-square
test. The default is \code{NULL}, i.e. no title will be added to describe the
effect being shown. An example of a \code{stat.title} argument will be something
like \code{"main x condition"} or \code{"interaction"}.}

\item{sample.size.label}{Logical that decides whether sample size information
should be displayed for each level of the grouping variable \code{condition} (Default:
\code{TRUE}).}

\item{title}{The text for the plot title.}

\item{caption}{The text for the plot caption.}

\item{nboot}{Number of bootstrap samples for computing effect size (Default:
\code{25}).}

\item{legend.title}{Title text for the legend.}

\item{facet.wrap.name}{The text for the facet_wrap variable label.}

\item{k}{Number of digits after decimal point (should be an integer) (Default: \code{k = 3}).}

\item{facet.proptest}{Decides whether proportion test for \code{main} variable is
to be carried out for each level of \code{condition} (Default: \code{TRUE}).}

\item{ggtheme}{A function, \code{ggplot2} theme name. Default value is
\code{ggplot2::theme_bw()}. Any of the \code{ggplot2} themes, or themes from
extension packages are allowed (e.g., \code{ggthemes::theme_economist()},
\code{hrbrthemes::theme_ipsum_ps()}, \code{ggthemes::theme_fivethirtyeight()}).}

\item{ggstatsplot.layer}{Logical that decides whether \code{theme_ggstatsplot}
theme elements are to be displayed along with the selected \code{ggtheme}
(Default: \code{TRUE}).}

\item{package}{Name of package from which the palette is desired as string
or symbol.}

\item{palette}{If a character string (e.g., \code{"Set1"}), will use that named
palette. If a number, will index into the list of palettes of appropriate
type. Default palette is \code{"Dark2"}.}

\item{direction}{Either \code{1} or \code{-1}. If \code{-1} the palette will be reversed.}

\item{messages}{Decides whether messages references, notes, and warnings are
to be displayed (Default: \code{TRUE}).}
}
\description{
Pie charts for categorical data with statistical details
included in the plot as a subtitle.
}
\examples{

# for reproducibility
set.seed(123)

# simple function call with the defaults (with condition)
ggstatsplot::ggpiestats(
  data = datasets::mtcars,
  main = vs,
  condition = cyl,
  nboot = 10,
  factor.levels = c("0 = V-shaped", "1 = straight"),
  legend.title = "Engine"
)

# simple function call with the defaults (without condition; with count data)
library(jmv)

ggstatsplot::ggpiestats(
  data = as.data.frame(HairEyeColor),
  main = Eye,
  counts = Freq
)
}
\references{
\url{https://cran.r-project.org/package=ggstatsplot/vignettes/ggpiestats.html}
}
\author{
Indrajeet Patil
}
