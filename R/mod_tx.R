#' UI functions for tx
#'
#' @description UI for module to hold treatment (tx)-specific eGFR slopes.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_tx_ui <- function(id, ...) {
  ns <- NS(id)
  tagList(
    textInputTx(ns("tx_name"), label = NULL, ...),
    h5("Acute eGFR slope"),
    numericInputSlope(ns("slope_central_acute"), "Central value"),
    shinyWidgets::numericRangeInput(ns("slope_range_acute"),
      "Lower and upper values",
      value = c(-3, 0),
      separator = ""
    ),
    h5("Chronic eGFR slope"),
    numericInputSlope(ns("slope_central_chronic"), "Central value"),
    shinyWidgets::numericRangeInput(ns("slope_range_chronic"),
      "Lower and upper values",
      value = c(-3, -1),
      separator = ""
    ),
  )
}

#' tx Server Functions
#'
#' @description Server for module to hold treatment (tx)-specific eGFR slopes.
#'
#' @noRd
mod_tx_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    iv <- shinyvalidate::InputValidator$new()

    iv$add_rule("slope_central_acute", shinyvalidate::sv_required())
    iv$add_rule("slope_range_acute", shinyvalidate::sv_required())
    iv$add_rule("slope_central_chronic", shinyvalidate::sv_required())
    iv$add_rule("slope_range_chronic", shinyvalidate::sv_required())

    iv$enable()

    tx_data <- reactive({
      req(iv$is_valid())

      tibble::tribble(
        ~tx, ~phase, ~stats, ~slope,
        input$tx_name, "acute", "central", input$slope_central_acute,
        input$tx_name, "acute", "lb", input$slope_range_acute[1],
        input$tx_name, "acute", "ub", input$slope_range_acute[2],
        input$tx_name, "chronic", "central", input$slope_central_chronic,
        input$tx_name, "chronic", "lb", input$slope_range_chronic[1],
        input$tx_name, "chronic", "ub", input$slope_range_chronic[2]
      )
    })
  })
}

## To be copied in the UI
# mod_tx_ui("tx_ui_1")

## To be copied in the server
# mod_tx_server("tx_ui_1")
