#' Match loanbook with asset level data
#'
#' FIXME: This is work in progress. At this stage these functions do useless
#' stuff. We use them only to test the interfaces they provide:
#' * `match_addin()`:
#'     * The user enter parameters on a pop-up window.
#'     * The app prints stuff on the R console.
#'     * It must run from R or RStudio (can't be hosted online).
#' * `match_app()`:
#'     * The user enter parameters on the web browser.
#'     * The app prints stuff on the web browser.
#'     * It can be hosted online, maybe on our private server.
#'
#' @return Called for its side effects.
#' @export
#'
#' @examples
#' \dontrun{
#' match_addin()
#'
#' match_app()
#' }
match_addin <- function() { # nocov start

  dep_ok <- vapply(
    c("rstudioapi", "shiny", "miniUI"),
    requireNamespace, logical(1), quietly = TRUE
  )
  if (any(!dep_ok)) {
    stop(
      "Install these packages in order to use the reprex addin:\n",
      collapse(names(dep_ok[!dep_ok])), call. = FALSE
    )
  }

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar(
      shiny::p("Match loanbook with asset level data"),
      right = miniUI::miniTitleBarButton("done", "Run", primary = TRUE)
    ),
    miniUI::miniContentPanel(
      shiny::fileInput("loanbook", "Where is the loanbook .csv file?"),
      shiny::checkboxInput(
        "run_matching",
        "Run matching?",
        FALSE
      ),
      shiny::checkboxInput(
        "run_analysis",
        "Run analysis?",
        FALSE
      )
    )
  )

  server <- function(input, output, session) {
    shiny::observeEvent(input$done, {
      shiny::stopApp(
        read_and_save(input$loanbook$datapath)
      )
    })
  }

  app <- shiny::shinyApp(ui, server, options = list(quiet = TRUE))
  shiny::runGadget(app, viewer = shiny::dialogViewer("Match loanbook with ALD"))
}

read_and_save <- function(input) {
  out <- readr::read_csv(input)
  print(out)

  path <- here::here('output.csv')
  readr::write_csv(out, path)
  usethis::ui_done("Output saved to {usethis::ui_path(path)}")
}

#' @export
#' @rdname match_addin
match_app <- function() {
  accept <- c("text/csv", "text/comma-separated-values,text/plain", ".csv")

  ui <- shiny::fluidPage(shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::fileInput(
        "loanbook", "Choose loanbook (.csv) file", accept = accept
      ),
      shiny::fileInput(
        "matching", "Choose matching (.csv) file", accept = accept
      ),
      shiny::tags$hr(),
      shiny::checkboxInput("run_matching", "Run matching", TRUE),
      shiny::checkboxInput("run_analysis", "Run analysis", TRUE)
    ),
    shiny::mainPanel(
      shiny::headerPanel("Loanbook file"),
      shiny::tableOutput("loanbook"),

      shiny::headerPanel("Matching file"),
      shiny::tableOutput("matching"),

      shiny::headerPanel("Programmed tasks"),
      shiny::textOutput("text_matching"),
      shiny::textOutput("text_analysis")
    )
  ))

  server <- function(input, output) {
    output$loanbook <- shiny::renderTable({
      if (is.null(input$loanbook)) return(NULL)
      readr::read_csv(input$loanbook$datapath)
    })

    output$matching <- shiny::renderTable({
      inFile <- input$matching
      if (is.null(inFile)) return(NULL)
      readr::read_csv(inFile$datapath)
    })

    output$text_matching <- shiny::renderText({
      ifelse(
        input$run_matching,
        "- Okay, we'll run the matching.",
        "- Okay, we won't run the matching."
      )
    })

    output$text_analysis <- shiny::renderText({
      ifelse(
        input$run_analysis,
        "- Okay, we'll run the analysis.",
        "- Okay, we won't run the analysis."
      )
    })
  }

  shiny::runApp(shiny::shinyApp(ui, server))
}

collapse <- function(x, sep = "\n") {
  stopifnot(is.character(sep), length(sep) == 1)
  paste(x, collapse = sep)
}
