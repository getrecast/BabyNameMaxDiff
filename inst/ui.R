##UI.R
ui = fluidPage(

  useShinyjs(),
  tags$head(tags$style(".rightAlign{float:right;}")),

  h3("Baby Name Ranking"),
  p(paste("This app implements a MaxDiff exercise to help husbands and wives",
          "choose a name that is maximally preferred by both individuals.")),
  p("To begin, enter between 5-30 names that you would consider naming your baby."),
  p(paste("Once entered, both spouses will be asked to complete a series of questions",
          "indicating which names they most like and most dislike. The app will",
          "recommend a number of questions, but you can always answer more for",
          "more accurate results.")),

  textInput("Surname", "Enter the family surname", value="Curtis"),
  uiOutput("PotentialNameGrabber"),
  hidden(
    div(id="MaxDiffQuestion",
        h3("Spouse #1"),
        h5("Which of the following names do you like least and most?"),
        fluidRow(column(6, div(class = 'rightAlign',
                      radioButtons("LeastLiked", "Least", width="80px",
                      selected=character(),
                      choiceNames = c("Baby 1", "Baby 2", "Baby 3", "Baby 4"),
                      choiceValues = 1:4))),


                      column(6, radioButtons("MostLiked", "Most",
                                     selected=character(),
                                     choiceNames = c("", "", "", ""),
                                     choiceValues = 1:4))
        ),
        div(class="rightAlign", actionButton("SubmitMD", "Submit Answer"))

        )),

  br()

)
