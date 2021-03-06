#'
#' @title Scatterplot with marginal distributions for all levels of a grouping
#'   variable
#' @name grouped_ggscatterstats
#' @aliases grouped_ggscatterstats
#' @author Indrajeet Patil
#' @description Grouped scatterplots from `ggplot2` combined with marginal
#'   histograms/boxplots/density plots with statistical details added as a
#'   subtitle.
#'
#' @param grouping.var Grouping variable.
#' @param title.prefix Character specifying the prefix text for the fixed plot
#'   title (name of each factor level) (Default: `"Group"`).
#' @inheritParams ggscatterstats
#' @inheritDotParams combine_plots
#'
#' @import ggplot2
#'
#' @importFrom dplyr select
#' @importFrom dplyr group_by
#' @importFrom dplyr summarize
#' @importFrom dplyr n
#' @importFrom dplyr arrange
#' @importFrom dplyr mutate
#' @importFrom dplyr mutate_at
#' @importFrom dplyr mutate_if
#' @importFrom magrittr "%<>%"
#' @importFrom magrittr "%>%"
#' @importFrom rlang enquo
#' @importFrom rlang quo_name
#' @importFrom purrr set_names
#'
#' @seealso \code{\link{ggscatterstats}} \code{\link{ggcorrmat}} \code{\link{grouped_ggcorrmat}}
#'
#' @inherit ggscatterstats return references
#' @inherit ggscatterstats return details
#'
#' @examples
#' 
#' # to ensure reproducibility
#' set.seed(123)
#' 
#' # basic function call
#' ggstatsplot::grouped_ggscatterstats(
#'   data = dplyr::filter(
#'     ggstatsplot::movies_long,
#'     genre == "Comedy" |
#'       genre == "Drama"
#'   ),
#'   x = length,
#'   y = rating,
#'   method = "lm",
#'   formula = y ~ x + I(x^3),
#'   grouping.var = genre
#' )
#' 
#' # using labeling
#' ggstatsplot::grouped_ggscatterstats(
#'   data = dplyr::filter(ggplot2::mpg, cyl != 5),
#'   x = displ,
#'   y = hwy,
#'   grouping.var = cyl,
#'   title.prefix = "Cylinder count",
#'   type = "robust",
#'   label.var = manufacturer,
#'   label.expression = hwy > 25 & displ > 2.5,
#'   messages = FALSE
#' )
#' 
#' # labeling without expression
#' ggstatsplot::grouped_ggscatterstats(
#'   data = dplyr::filter(
#'     .data = ggstatsplot::movies_long,
#'     rating == 8,
#'     genre %in% c("Drama", "Comedy")
#'   ),
#'   x = budget,
#'   y = length,
#'   grouping.var = genre,
#'   label.var = title,
#'   results.subtitle = FALSE,
#'   marginal = FALSE,
#'   title.prefix = "Genre",
#'   caption.text = "All movies have IMDB rating greater than 8."
#' )
#' @export
#'

# defining the function
grouped_ggscatterstats <- function(data,
                                   x,
                                   y,
                                   label.var = NULL,
                                   label.expression = NULL,
                                   grouping.var,
                                   title.prefix = "Group",
                                   xlab = NULL,
                                   ylab = NULL,
                                   method = "lm",
                                   method.args = list(),
                                   formula = y ~ x,
                                   line.size = 1.5,
                                   line.color = "blue",
                                   marginal = TRUE,
                                   marginal.type = "histogram",
                                   marginal.size = 5,
                                   margins = c("both", "x", "y"),
                                   width.jitter = NULL,
                                   height.jitter = NULL,
                                   xfill = "#009E73",
                                   yfill = "#D55E00",
                                   xalpha = 1,
                                   yalpha = 1,
                                   xsize = 0.7,
                                   ysize = 0.7,
                                   centrality.para = NULL,
                                   type = "pearson",
                                   results.subtitle = TRUE,
                                   caption = NULL,
                                   subtitle = NULL,
                                   nboot = 100,
                                   beta = 0.1,
                                   k = 3,
                                   axes.range.restrict = FALSE,
                                   ggtheme = ggplot2::theme_bw(),
                                   ggstatsplot.layer = TRUE,
                                   messages = TRUE,
                                   ...) {

  # create a list of function call to check for label.expression
  param_list <- base::as.list(base::match.call())

  # check that label.var and grouping.var are different
  if ("label.var" %in% names(param_list) && "grouping.var" %in% names(param_list)) {
    if (as.character(param_list$label.var) == as.character(param_list$grouping.var)) {
      base::message(cat(
        crayon::red("Error:"),
        crayon::blue(
          "Identical variable (",
          crayon::yellow(param_list$label.var),
          ") was used for both grouping and labeling, which is not allowed."
        )
      ))
    }
  }

  # check labeling variable has been entered
  if ("label.var" %in% names(param_list)) {
    point.labelling <- TRUE
  } else {
    point.labelling <- FALSE
  }

  # check labeling expression has been specified
  if ("label.expression" %in% names(param_list)) {
    expression.present <- TRUE
  } else {
    expression.present <- FALSE
  }

  # ========================================= preparing dataframe =======================================================

  # getting the dataframe ready
  df <- dplyr::select(
    .data = data,
    !!rlang::enquo(grouping.var),
    !!rlang::enquo(x),
    !!rlang::enquo(y),
    dplyr::everything()
  ) %>%
    dplyr::mutate(
      .data = .,
      title.text = !!rlang::enquo(grouping.var)
    )

  # creating a nested dataframe
  df %<>%
    dplyr::mutate_if(
      .tbl = .,
      .predicate = purrr::is_bare_character,
      .funs = ~as.factor(.)
    ) %>%
    dplyr::mutate_if(
      .tbl = .,
      .predicate = is.factor,
      .funs = ~base::droplevels(.)
    ) %>%
    dplyr::arrange(.data = ., !!rlang::enquo(grouping.var)) %>%
    dplyr::group_by(.data = ., !!rlang::enquo(grouping.var)) %>%
    tidyr::nest(data = .)

  if (isTRUE(point.labelling)) {
    if (isTRUE(expression.present)) {
      # creating a list of plots
      plotlist_purrr <- df %>%
        dplyr::mutate(
          .data = .,
          plots = data %>%
            purrr::set_names(!!rlang::enquo(grouping.var)) %>%
            purrr::map(
              .x = .,
              .f = ~ggstatsplot::ggscatterstats(
                data = .,
                x = !!rlang::enquo(x),
                y = !!rlang::enquo(y),
                label.var = !!rlang::enquo(label.var),
                label.expression = !!rlang::enquo(label.expression),
                title = glue::glue("{title.prefix}: {as.character(.$title.text)}"),
                xlab = xlab,
                ylab = ylab,
                method = method,
                method.args = method.args,
                formula = formula,
                line.size = line.size,
                line.color = line.color,
                marginal = marginal,
                marginal.type = marginal.type,
                marginal.size = marginal.size,
                margins = margins,
                width.jitter = width.jitter,
                height.jitter = height.jitter,
                xfill = xfill,
                yfill = yfill,
                xalpha = xalpha,
                yalpha = yalpha,
                xsize = xsize,
                ysize = ysize,
                centrality.para = centrality.para,
                type = type,
                results.subtitle = results.subtitle,
                subtitle = subtitle,
                caption = caption,
                nboot = nboot,
                beta = beta,
                k = k,
                axes.range.restrict = axes.range.restrict,
                ggtheme = ggtheme,
                ggstatsplot.layer = ggstatsplot.layer,
                messages = messages
              )
            )
        )
    } else {
      # creating a list of plots
      plotlist_purrr <- df %>%
        dplyr::mutate(
          .data = .,
          plots = data %>%
            purrr::set_names(!!rlang::enquo(grouping.var)) %>%
            purrr::map(
              .x = .,
              .f = ~ggstatsplot::ggscatterstats(
                data = .,
                x = !!rlang::enquo(x),
                y = !!rlang::enquo(y),
                label.var = !!rlang::enquo(label.var),
                title = glue::glue("{title.prefix}: {as.character(.$title.text)}"),
                xlab = xlab,
                ylab = ylab,
                method = method,
                method.args = method.args,
                formula = formula,
                line.size = line.size,
                line.color = line.color,
                marginal = marginal,
                marginal.type = marginal.type,
                marginal.size = marginal.size,
                margins = margins,
                width.jitter = width.jitter,
                height.jitter = height.jitter,
                xfill = xfill,
                yfill = yfill,
                xalpha = xalpha,
                yalpha = yalpha,
                xsize = xsize,
                ysize = ysize,
                centrality.para = centrality.para,
                type = type,
                results.subtitle = results.subtitle,
                subtitle = subtitle,
                caption = caption,
                nboot = nboot,
                beta = beta,
                k = k,
                axes.range.restrict = axes.range.restrict,
                ggtheme = ggtheme,
                ggstatsplot.layer = ggstatsplot.layer,
                messages = messages
              )
            )
        )
    }
  } else {
    # creating a list of plots
    plotlist_purrr <- df %>%
      dplyr::mutate(
        .data = .,
        plots = data %>%
          purrr::set_names(!!rlang::enquo(grouping.var)) %>%
          purrr::map(
            .x = .,
            .f = ~ggstatsplot::ggscatterstats(
              data = .,
              x = !!rlang::enquo(x),
              y = !!rlang::enquo(y),
              title = glue::glue("{title.prefix}: {as.character(.$title.text)}"),
              xlab = xlab,
              ylab = ylab,
              method = method,
              method.args = method.args,
              formula = formula,
              line.size = line.size,
              line.color = line.color,
              marginal = marginal,
              marginal.type = marginal.type,
              marginal.size = marginal.size,
              margins = margins,
              width.jitter = width.jitter,
              height.jitter = height.jitter,
              xfill = xfill,
              yfill = yfill,
              xalpha = xalpha,
              yalpha = yalpha,
              xsize = xsize,
              ysize = ysize,
              centrality.para = centrality.para,
              type = type,
              results.subtitle = results.subtitle,
              subtitle = subtitle,
              caption = caption,
              nboot = nboot,
              beta = beta,
              k = k,
              axes.range.restrict = axes.range.restrict,
              ggtheme = ggtheme,
              ggstatsplot.layer = ggstatsplot.layer,
              messages = messages
            )
          )
      )
  }
  # combining the list of plots into a single plot
  combined_plot <-
    ggstatsplot::combine_plots(
      plotlist = plotlist_purrr$plots,
      ...
    )

  # return the combined plot
  return(combined_plot)
}
