#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom rlang .data
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  ## Weeks per year
  weeks_per_year <- 365.25 / 7

  ## Time points
  time_points <- mod_time_points_server("time_points_ui_1")
  acute_year <- reactive(time_points()$acute / weeks_per_year)
  trial_end_year <- reactive(time_points()$trial_end / weeks_per_year)

  ## eGFR data
  egfr_data <- mod_egfr_data_server("egfr_data_ui_1")
  base_egfr <- reactive(egfr_data()$base_egfr)
  dial_threshold <- reactive(egfr_data()$dial_threshold)

  ## Treatments
  tx_1 <- mod_tx_server("tx_ui_1")
  tx_2 <- mod_tx_server("tx_ui_2")

  ## Calculate time to dialysis
  tx <- reactive({
    req(base_egfr() >= dial_threshold())
    req(acute_year() <= trial_end_year())

    dplyr::bind_rows(tx_1(), tx_2(), .id = "tx_nr") |>
      tidyr::pivot_wider(
        names_from = "phase",
        names_prefix = "slope_",
        values_from = "slope"
      ) |>
      dplyr::mutate(
        egfr_acute = base_egfr() + .data$slope_acute,
        egfr_trialend =
          .data$egfr_acute +
            .data$slope_chronic *
              trial_end_year(),
        egfr_ttd = dial_threshold(),
        time_acute = acute_year(),
        time_trialend = trial_end_year(),
        time_ttd = (dial_threshold() -
          .data$egfr_acute) /
          .data$slope_chronic
      ) |>
      dplyr::select(-dplyr::all_of(dplyr::contains("slope"))) |>
      tidyr::pivot_longer(
        cols = dplyr::starts_with("egfr_"),
        names_to = "egfr_state",
        values_to = "egfr_value"
      ) |>
      tidyr::pivot_longer(
        cols = dplyr::starts_with("time_"),
        names_to = "time_year",
        values_to = "time_value"
      ) |>
      tidyr::separate(.data$egfr_state, into = c("egfr_label", "egfr_time")) |>
      tidyr::separate(.data$time_year, into = c("time_label", "time_is")) |>
      dplyr::filter(.data$egfr_time == .data$time_is) |>
      dplyr::distinct(
        .data$tx_nr,
        .data$tx,
        .data$stats,
        .data$egfr_value,
        .data$time_is,
        .data$time_value
      ) |>
      dplyr::mutate(time_value = dplyr::if_else(
        .data$time_value < 0, NA_real_, .data$time_value
      )) |>
      dplyr::arrange(.data$tx_nr, .data$stats) |>
      dplyr::group_by(.data$stats, .data$time_is) |>
      dplyr::mutate(time_incr = .data$time_value -
        dplyr::lead(.data$time_value)) |>
      dplyr::ungroup() |>
      dplyr::mutate(trial_data = dplyr::if_else(.data$time_is == "ttd",
        "no",
        "yes"
      )) |>
      dplyr::mutate(age = input$base_age + .data$time_value) |>
      dplyr::mutate(currency = input$currency) |>
      dplyr::mutate(dial_cost = input$dial_cost) |>
      dplyr::mutate(disc_rate = input$disc_rate_perc / 100)
  })

  output$tx <- renderTable(tx())

  mod_results_table_server("results_table_ui_1", data = tx)

  mod_egfr_plot_server("egfr_plot_ui_1",
    data = tx,
    base_egfr = base_egfr,
    dial_threshold = dial_threshold,
    acute_year = acute_year,
    trial_end_year = trial_end_year
  )

  ## Population
}
