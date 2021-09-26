library(shiny)
library(tidyverse)
library(shinyjs)

#' Start the Baby Name MaxDiff Shiny app
#'
#' @description
#' Will start a local Shiny app that will walk the user through a MaxDiff exercise
#'
#'
#' @export
baby_name_maxdiff <- function(){


  ##Sources the global code that will be run whenever the app starts a new process
  source("inst/global.R", local=T)

  #sources the ui object so it will exist in memory
  source("inst/ui.R", local=T)

  #sources the server object so it will exist in memory
  source("inst/server.R", local=T)

  # Runs the application using the sourced server and ui
  shinyApp(ui=ui, server=server)


}
