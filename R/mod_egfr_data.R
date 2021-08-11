#' UI function for eGFR data
#'
#' @description UI for module to capture baseline eGFR and eGFR at which
#'   dialysis is initiated.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_egfr_data_ui <- function(id){
  ns <- NS(id)
  tagList(
    splitLayout(
      numericInputEGFR(ns("base_egfr"),
                       "Baseline eGFR",
                       value = 90),
      numericInputEGFR(ns("dial_threshold"),
                       "eGFR threshold for dialysis",
                       value = 10)
    )
  )
}
    
#' Server function for eGFR data
#'
#' @description Server for module to capture baseline eGFR and eGFR at which
#'   dialysis is initiated.
#' @noRd 
mod_egfr_data_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    iv <- shinyvalidate::InputValidator$new()
    iv$add_rule("base_egfr", shinyvalidate::sv_required())
    iv$add_rule("base_egfr", function(value) {
      if (value < 0) {"Must not be negative"}
    })
    
    iv$add_rule("dial_threshold", shinyvalidate::sv_required())
    iv$add_rule("dial_threshold", function(value) {
      if (value < 0) {"Must not be negative"}
    })
    iv$add_rule("dial_threshold",
                function(value) {
                  if (shinyvalidate::input_provided(input$base_egfr) & 
                      value > input$base_egfr) {
                    "Must not be higher than base eGFR."
                  }
                })

    iv$enable()
    
    egfr_data <- reactive({
      req(iv$is_valid())
      
        reactiveValues(
          base_egfr = input$base_egfr,
          dial_threshold = input$dial_threshold
        )
    })
 
  })
}
    
## To be copied in the UI
# mod_egfr_data_ui("egfr_data_ui_1")
    
## To be copied in the server
# mod_egfr_data_server("egfr_data_ui_1")
