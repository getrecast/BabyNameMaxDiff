#server.R
server <- function(session, input, output) {

  n_names = reactiveVal(5)
  potentials = reactiveVal(NULL)

  output$PotentialNameGrabber<- renderUI({

    list(
      lapply(1:30, function(i){
        if(i>5){
        hidden(textInput(paste0("potential_name_", i),
                                      paste0("Potential Name #", i)))
        }else{
          textInput(paste0("potential_name_", i),
                    paste0("Potential Name #", i),
                    value = i)
        }
        }),
      fluidRow(actionButton("AddMore", "Add Another Name",
                            style="background-color: #ffd1d7"),
               actionButton("BeginRanking", "Begin Ranking",
                            style="background-color:#76bae0")),
      br(),
      hidden(actionButton("RemoveName", "Remove Name"))


    )
  })

  observeEvent(input$AddMore, {
    n_names(n_names()+1)
  })

  observeEvent(input$RemoveName, {
    n_names(n_names()-1)
  })

  observeEvent(n_names(), {
    for (i in 1:30){
      toggle(paste0("potential_name_", i), condition=i<=n_names())
    }
  })

  observe({
    if(n_names()>=30){
      disable("AddMore")
    }
  })

  observe({
    if(n_names()>5)show("RemoveName") else hide("RemoveName")
  })

  observe({
    names = sapply(1:n_names(), function(i)input[[paste0("potential_name_", i)]])
    toggleState("BeginRanking", condition=all(nchar(names)>0) & nchar(input$Surname)>0)
  })

  observeEvent(input$BeginRanking, {
    potentials(sapply(1:n_names(), function(i)input[[paste0("potential_name_", i)]]))
    hide("Surname")
    hide("PotentialNameGrabber")
    show("MaxDiffQuestion")
  })







}
