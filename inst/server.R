#server.R
server <- function(session, input, output) {

  n_names = reactiveVal(5)
  potentials = reactiveVal(NULL)
  dummied_names = reactiveVal(NULL)
  person = reactiveVal(NULL)
  data_matrix = reactiveVal(NULL)
  currently_showing = reactiveVal(NULL)
  questions_answered = reactiveVal(NULL)
  utilities<-reactiveVal(NULL)

  output$PotentialNameGrabber<- renderUI({



    list(
      fluidRow(column(4, actionButton("RandomBoys", "Random 20 popular boy names",
                                      style="background-color: #76bae0;")),
               column(6, actionButton("RandomGirls", "Random 20 popular girl names",
                                      style="background-color: #ffd1d7"))),
      actionButton("UseMyOwn", "Use my own list of names", style="margin-top:10px;"),
      hidden(div(id="OwnNames",
      lapply(1:30, function(i){
        if(i>5){
        hidden(textInput(paste0("potential_name_", i),
                                      paste0("Potential Name #", i)))
        }else{
          textInput(paste0("potential_name_", i),
                    paste0("Potential Name #", i))
        }
        }),
      fluidRow(actionButton("AddMore", "Add Another Name",
                            style="background-color: #ffd1d7"),
               actionButton("BeginRanking", "Use my names",
                            style="background-color:#76bae0")),
      br(),
      hidden(actionButton("RemoveName", "Remove Name"))


    )))
  })

  observeEvent(input$UseMyOwn,{
    show("OwnNames")
    hide("UseMyOwn")
    hide("RandomBoys")
    hide("RandomGirls")
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
    toggleState("RandomBoys", condition=nchar(input$Surname)>0)
    toggleState("RandomGirls", condition=nchar(input$Surname)>0)
    toggleState("UseMyOwn", condition=nchar(input$Surname)>0)

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
    person(1)
    updateQuestion()
  })

  updateQuestion <- function(){

    which_names =  sample(1:length(potentials()), 4, replace=F)
    currently_showing(which_names)
    q_names = potentials()[which_names]
    updateRadioButtons(session, "LeastLiked", choiceValues = 1:4,
                       choiceNames =map(q_names, ~HTML(paste0("&nbsp;&nbsp;&nbsp;", .x))),
                       selected=character())
    updateRadioButtons(session, "MostLiked",  selected=character())

  }

  observe({
    toggleState("SubmitMD", condition=length(input$MostLiked)>0 & length(input$LeastLiked)>0)
  })

  observeEvent(potentials(), ignoreNULL = T, {
    dummied_names(fastDummies::dummy_columns(potentials(), remove_selected_columns = T))
  })

  ##Handle when the user submits a MaxDiff answer
  observeEvent(input$SubmitMD, {
    if(is.null(data_matrix())){
      questions_answered(1)
     data_matrix(create_rows())
    }else{
      questions_answered(questions_answered()+1)
      data_matrix(data_matrix() %>%
                    bind_rows(create_rows()))
    }
    show("Finish")
   updateQuestion()
  })

  observeEvent(questions_answered(), {
    if (person()==1 & questions_answered()>(length(potentials()))){
      updateActionButton(session, "Finish", "Proceed to next spouse")
    }
    if (person()==2 & questions_answered()>(length(potentials()))){
      updateActionButton(session, "Finish", "See results")
    }
  }, ignoreNULL = T)

  create_rows <- function(){
    tibble(id=person(),
           question_set=rep((questions_answered()*2-1):(questions_answered()*2), each=4),
           choices=rep(1:4,2)) %>%
      bind_cols(
        bind_rows(dummied_names()[currently_showing(),],
                  dummied_names()[currently_showing(),]*-1) %>%
          setNames(potentials())
      ) %>%
      mutate(y=c(as.numeric(input$MostLiked), rep(0, 3), as.numeric(input$LeastLiked), rep(0,3)))
  }

  ##If MOST is clicked, uncheck least
  observeEvent(input$MostLiked, {
    if(!is.null(input$LeastLiked)){
      if(input$MostLiked==input$LeastLiked){
        updateRadioButtons(session, "LeastLiked", selected=character())
      }
  }
  })

  ##If least is clicked, uncheck most
  observeEvent(input$LeastLiked, {
    if(!is.null(input$MostLiked)){
      if(input$LeastLiked==input$MostLiked){
        updateRadioButtons(session, "MostLiked", selected=character())
      }
    }
  })



  output$SpouseHeader<-renderUI({
    color = if_else(person()==1, "#ffb8c1", "#76bae0")
    div(style=paste0("color:", color), h3(paste0("Spouse #", person())))
  })

  observeEvent(input$Finish, {
    if (person()==1){
      person(2)
      questions_answered(0)
      hide("Finish")
      updateActionButton(session, "Finish", "Finish early (not recommended)")
      }else{
      hide(id="MaxDiffQuestion")
      shinybusy::show_modal_spinner(text="Calculating name scores", color="#ffd1d7")
      utils= estimate_utilities(data_matrix())
      shinybusy::remove_modal_spinner()
      utilities(utils)
      show("ResultsScreen")
    }
  })

  output$Recommendation<-renderUI({
    name = utilities() %>%
      select(-id) %>%
      summarize(across(everything(), mean))%>%
      pivot_longer(everything()) %>%
      arrange(desc(value)) %>%
      slice(1) %>% select(name) %>% pull
    h3(paste("Your recommended baby name is", name, input$Surname))
  })

  output$Rankings<-renderPlot({
    utilities=utilities()
    #save(utilities, file="Temp.RData")
    utilities %>%
      pivot_longer(-id) %>%
      group_by(name) %>%
      mutate(order=mean(value)) %>%
      ungroup %>%
      arrange(order, desc(id)) %>%
      mutate(name=fct_inorder(name), id=fct_inorder(paste("Spouse", id)))%>%
      ggplot(aes(y=name, x=value, fill=id))+
      geom_col(position="dodge")+
      geom_segment(
                   aes(x = order, xend=order, color="Average",
                       y = as.numeric(name)-.4, yend = as.numeric(name)+.4),
                   size=1,  inherit.aes = F)+
      #geom_point(aes(x=order), color="Red")+
      #geom_(width=.6, aes(x=order, ymin=name, ymax=name), color="Red")+
      ggtitle("Name Rankings")+
      scale_x_continuous("Utility Score")+
      scale_y_discrete(NULL)+
      scale_fill_manual(values=c("#76bae0", "#ffd1d7"))+
      guides(fill=guide_legend(reverse=T))+
      theme_minimal()+
      theme(legend.title = element_blank(),
            title = element_text(size=20),
            axis.title.x = element_text(size=16),
            #panel.grid.major.y = element_blank(),
            axis.text.y=element_text(size=16),
            legend.position = "top")
  })

}
