#' UI function for egfr_plot
#'
#' @description UI for module to plot observed and projected eGFR curves.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_egfr_plot_ui <- function(id) {
  ns <- NS(id)

  highcharter::highchartOutput(ns("egfr_plot"))
}

#' Server function for egfr_plot
#'
#' @description Server for module to plot observed and projected eGFR curves.
#'
#' @noRd
mod_egfr_plot_server <- function(id, data, base_egfr, dial_threshold,
                                 acute_year, trial_end_year) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    stopifnot(is.reactive(data))
    stopifnot(is.reactive(base_egfr))
    stopifnot(is.reactive(dial_threshold))
    stopifnot(is.reactive(acute_year))
    stopifnot(is.reactive(trial_end_year))

    tx1 <- reactive({
      data() |>
        dplyr::filter(.data$tx_nr == 1) |>
        dplyr::pull(.data$tx) |>
        unique()
    })

    tx2 <- reactive({
      data() |>
        dplyr::filter(.data$tx_nr == 2) |>
        dplyr::pull(.data$tx) |>
        unique()
    })

    base_data <- reactive({
      data() |>
        dplyr::distinct(.data$tx_nr, .data$tx, .data$stats) |>
        dplyr::mutate(egfr_value = base_egfr()) |>
        dplyr::mutate(time = "baseline") |>
        dplyr::mutate(time_value = 0) |>
        dplyr::mutate(time_incr = NA) |>
        dplyr::mutate(trial_data = "yes")
    })

    plot_data <- reactive({
      dplyr::bind_rows(data(), base_data()) |>
        dplyr::select(dplyr::all_of(c(
          "tx",
          "stats",
          "time_value",
          "egfr_value",
          "trial_data"
        ))) |>
        tidyr::pivot_wider(
          names_from = "stats",
          names_prefix = "egfr_",
          values_from = "egfr_value"
        ) |>
        dplyr::arrange(.data$tx, .data$time_value)
    })

    output$plotdata <- renderTable({
      plot_data()
    })

    # Colors
    central_colors <- c("#08519c", "#a63603")
    lb_colors <- c("#3182bd", "#e6550d")
    ub_colors <- c("#6baed6", "#fd8d3c")
    tx_symbols <- c("circle", "diamond")

    output$egfr_plot <- highcharter::renderHighchart({
      highcharter::highchart() |>
        highcharter::hc_add_series(plot_data(),
          "line",
          highcharter::hcaes(
            x = .data$time_value,
            y = .data$egfr_central,
            group = .data$tx
          ),
          name = paste0(
            "Central: ",
            c(tx1(), tx2())
          ),
          color = central_colors,
          marker = list(symbol = c("square")),
          id = "central",
          showInLegend = TRUE
        ) |>
        highcharter::hc_add_series(plot_data(),
          "line",
          highcharter::hcaes(
            x = .data$time_value,
            y = .data$egfr_lb,
            group = .data$tx
          ),
          name = paste0("Lower: ", c(tx1(), tx2())),
          color = lb_colors,
          marker = list(symbol = c("triangle-down")),
          linkedTo = "central",
          showInLegend = TRUE
        ) |>
        highcharter::hc_add_series(plot_data(),
          "line",
          highcharter::hcaes(
            x = .data$time_value,
            y = .data$egfr_ub,
            group = .data$tx
          ),
          name = paste0("Upper: ", c(tx1(), tx2())),
          color = ub_colors,
          marker = list(symbol = c("triangle")),
          linkedTo = "central",
          showInLegend = TRUE
        ) |>
        highcharter::hc_xAxis(
          title = list(text = "Years"),
          plotLines = list(
            list(
              value = acute_year(),
              label = list(
                text = "Acute phase ends",
                rotation = 0
              )
            ),
            list(
              value = trial_end_year(),
              label = list(
                text = "Trial ends",
                rotation = 0,
                verticalAlign = "middle"
              )
            )
          )
        ) |>
        highcharter::hc_yAxis(
          title = list(text = "eGFR (mL/min/1.73m<sup>2</sup>)", useHTML = TRUE),
          plotLines = list(
            list(
              value = dial_threshold(),
              label = list(
                text = "Dialysis initiation threshold",
                align = "center"
              )
            )
          ),
          min = 0
        ) |>
        highcharter::hc_plotOptions(series = list(
          connectNulls = TRUE,
          lineMarkers = TRUE
        )) |>
        highcharter::hc_tooltip(enabled = FALSE) |>
        highcharter::hc_legend(itemStyle = list(fontWeight = "regular"))
    })
  })
}

## To be copied in the UI
# mod_egfr_plot_ui("egfr_plot_ui_1")

## To be copied in the server
# mod_egfr_plot_server("egfr_plot_ui_1")
