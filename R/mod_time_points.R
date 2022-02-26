#' UI function for time_points
#'
#' @description UI for module to gather time points.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_time_points_ui <- function(id) {
  ns <- NS(id)
  tagList(
    splitLayout(
      numericInput(ns("acute_phase"),
        label = "Acute phase (weeks)",
        value = 12,
        min = 1,
        step = 1
      ),
      numericInput(ns("trial_end"),
        label = "Trial end (weeks)",
        value = 52,
        min = 2,
        step = 1
      )
    )
  )
}

#' time_points Server Functions
#'
#' @description Server for module to gather time points.
#'
#' @noRd
mod_time_points_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    iv <- shinyvalidate::InputValidator$new()
    iv$add_rule("acute_phase", shinyvalidate::sv_required())
    iv$add_rule("trial_end", shinyvalidate::sv_required())

    iv$add_rule("acute_phase", function(value) {
      if (value < 0) {
        "Must not be negative"
      }
    })

    iv$add_rule("trial_end", function(value) {
      if (value < 0) {
        "Must not be negative"
      }
    })
    iv$add_rule(
      "trial_end",
      function(value) {
        if (shinyvalidate::input_provided(input$acute_phase) &
          value <= input$acute_phase) {
          "Must be longer than acute phase."
        }
      }
    )
    iv$enable()

    time_points <- reactive({
      req(iv$is_valid())

      reactiveValues(
        acute = input$acute_phase,
        trial_end = input$trial_end
      )
    })
  })
}

## To be copied in the UI
# mod_time_points_ui("time_points_ui_1")

## To be copied in the server
# mod_time_points_server("time_points_ui_1")
