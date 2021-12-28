##UI.R
ui = fluidPage(

  useShinyjs(),
  tags$head(tags$style(".rightAlign{float:right;}")),

  div(style="color: #76bae0", h2("Baby Name Ranking")),
  p(paste("This app implements a MaxDiff exercise to help husbands and wives",
          "choose a name that is maximally preferred by both individuals.")),
  p("To begin, enter 5-30 names that you would consider naming your baby, or use a random set of 20 popular names."),
  p(paste("Once entered, both spouses will be asked to complete a series of questions",
          "indicating which names they most like and most dislike. The app will",
          "recommend a number of questions, but you can always answer more for",
          "more accurate results.")),

  textInput("Surname", "Enter the family surname"),
  uiOutput("PotentialNameGrabber"),
  hidden(
    div(id="MaxDiffQuestion",
        uiOutput("SpouseHeader"),
        uiOutput("QuestionText"),
        fluidRow(column(2,
                      radioButtons("LeastLiked", "Least",
                      selected=character(),
                      choiceNames = c("Baby 1", "Baby 2", "Baby 3", "Baby 4"),
                      choiceValues = 1:4, width="30px")),


                      column(1, radioButtons("MostLiked", "Most", width = "20px",
                                     selected=character(),
                                     choiceNames = list(HTML("&nbsp;"),HTML("&nbsp;"),HTML("&nbsp;"),HTML("&nbsp;")),
                                     choiceValues = 1:4))
        ),
        div(class="rightAlign",
            actionButton(style="background-color: #76bae0; margin-bottom:10px;","SubmitMD", "Submit Answer"),
br(),

                hidden(actionButton(style="background-color: #ffd1d7",
                                    "Finish", "Skip to next spouse early (not recommended)")))

        )),

  hidden(
    div(id="ResultsScreen",
        uiOutput("Recommendation"),
        plotOutput("Rankings"))
  ),

  br()

)
