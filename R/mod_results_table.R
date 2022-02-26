#' UI function for results table
#'
#' @description UI for module to present results in tabular form.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom rlang .data :=
mod_results_table_ui <- function(id) {
  ns <- NS(id)
  tableOutput(ns("results_table"))
}

#' results_table Server Functions
#'
#' @description server for module to present results in tabular form.
#'
#' @noRd
mod_results_table_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    stopifnot(is.reactive(data))

    currency <- reactive({
      data() |>
        dplyr::pull(.data$currency) |>
        unique()
    })

    tx_1 <- reactive({
      data() |>
        dplyr::filter(.data$tx_nr == 1) |>
        dplyr::pull(.data$tx) |>
        unique()
    })

    tx_2 <- reactive({
      data() |>
        dplyr::filter(.data$tx_nr == 2) |>
        dplyr::pull(.data$tx) |>
        unique()
    })

    res_table <- reactive({
      data() |>
        dplyr::filter(.data$time_is == "ttd") |>
        dplyr::arrange(.data$stats, .data$tx_nr) |>
        dplyr::distinct(
          .data$tx,
          .data$stats,
          .data$time_value,
          .data$time_incr,
          .data$age,
          .data$currency,
          .data$dial_cost,
          .data$disc_rate
        ) |>
        dplyr::mutate(time_value_display = dplyr::if_else(
          is.na(.data$time_value),
          "Dialysis not reached",
          format(.data$time_value, digits = 2, nsmall = 2, big.mark = ",")
        )) |>
        dplyr::mutate(age_display = dplyr::if_else(
          is.na(.data$age),
          "",
          format(.data$age, digits = 2, nsmall = 2, big.mark = ",")
        )) |>
        dplyr::mutate(time_incr_display = dplyr::case_when(
          .data$time_incr == 0 ~ "0",
          .data$time_incr > 0 ~ paste0(
            format(abs(.data$time_incr),
              digits = 2,
              nsmall = 2,
              big.mark = ","
            ),
            " years later with ",
            tx_1()
          ),
          .data$time_incr < 0 ~ paste0(
            format(abs(.data$time_incr),
              digits = 2,
              nsmall = 2,
              big.mark = ","
            ),
            " years earlier with ",
            tx_1()
          ),
          is.na(.data$time_incr) ~ ""
        )) |>
        dplyr::mutate(
          age_round =
            plyr::round_any(
              .data$age,
              sloper::usrds_esrd_mort_2019$group_years[1],
              floor
            )
        ) |>
        dplyr::mutate(age_round = dplyr::case_when(
          .data$age_round >
            max(sloper::usrds_esrd_mort_2019$age_min, na.rm = TRUE) ~
          max(sloper::usrds_esrd_mort_2019$age_min),
          TRUE ~ age_round
        )) |>
        dplyr::left_join(sloper::usrds_esrd_mort_2019 |>
          dplyr::select(dplyr::all_of(c(
            "age_min",
            "remaining_years"
          ))),
        by = c("age_round" = "age_min")
        ) |>
        dplyr::mutate(
          remaining_years_display =
            dplyr::case_when(
              is.na(.data$remaining_years) & is.na(.data$age) ~
              "",
              is.na(.data$remaining_years) & !is.na(.data$age) ~
              "No mortality data",
              TRUE ~ format(.data$remaining_years,
                digits = 2,
                nsmall = 2,
                big.mark = ","
              )
            )
        ) |>
        dplyr::mutate(
          cost =
            calculate_cost(
              dial_cost = .data$dial_cost,
              discount_factor = .data$disc_rate[1],
              years_to_initiation = .data$time_value,
              years_of_tx = .data$remaining_years
            )
        ) |>
        dplyr::group_by(.data$stats) |>
        dplyr::mutate(cost_incr = .data$cost - dplyr::lead(.data$cost)) |>
        dplyr::ungroup() |>
        dplyr::mutate(cost_incr_display = dplyr::case_when(
          cost_incr == 0 ~ "0",
          cost_incr > 0 ~ paste0(
            currency(),
            " ",
            format(abs(cost_incr),
              digits = 2,
              nsmall = 2,
              scientific = FALSE,
              big.mark = ","
            ),
            " more with ", tx_1()
          ),
          cost_incr < 0 ~ paste0(
            currency(),
            " ",
            format(abs(cost_incr),
              digits = 2,
              nsmall = 2,
              scientific = FALSE,
              big.mark = ","
            ),
            " less with ", tx_1()
          ),
          is.na(cost_incr) ~ ""
        )) |>
        dplyr::mutate(
          cost_display =
            dplyr::case_when(
              is.na(.data$remaining_years) & is.na(.data$age) ~
              "",
              is.na(.data$remaining_years) & !is.na(.data$age) ~
              "",
              TRUE ~ format(.data$cost,
                digits = 2,
                nsmall = 2,
                scientific = FALSE,
                big.mark = ","
              )
            )
        ) |>
        dplyr::mutate(stats = dplyr::case_when(
          .data$stats == "central" ~ "Central",
          .data$stats == "lb" ~ "Lower",
          TRUE ~ "Upper"
        )) |>
        dplyr::select(dplyr::all_of(c(
          "tx",
          "stats",
          "time_value_display",
          "time_incr_display",
          "age_display",
          "remaining_years_display",
          "cost_display",
          "cost_incr_display"
        ))) |>
        dplyr::rename(
          "Treatment" = .data$tx,
          "Slope" = .data$stats,
          "TTD" = .data$time_value_display,
          "\u0394TTD" = .data$time_incr_display,
          "Age at dialysis initiation" = .data$age_display,
          "Time on dialysis" = .data$remaining_years_display,
          !!glue::glue("Costs ({currency()})") := .data$cost_display,
          !!glue::glue("\u0394Costs ({currency()})") :=
            .data$cost_incr_display
        )
    })

    output$results_table <- renderTable({
      res_table()
    })
  })
}

## To be copied in the UI
# mod_results_table_ui("results_table_ui_1")

## To be copied in the server
# mod_results_table_server("results_table_ui_1")
