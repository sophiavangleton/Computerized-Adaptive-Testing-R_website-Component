#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinythemes)

ui <- fluidPage(
  theme = shinytheme("flatly"),
  
  tags$head(
    tags$style(HTML("
      body {
        background-color: #d4dcee !important;   /* Morph blue */
      }

      /* Centered quiz container with Morph blue background */
      .quiz-container {
        max-width: 700px;
        margin: 40px auto;
        padding: 30px;
        background-color: #d4dcee !important;   /* Match Morph background */
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      }

      /* Make text readable on blue */
      h3, label, .radio, .control-label {
        color: #2c3e50;
      
      }
    "))
  ),
  
  div(class = "quiz-container",
      titlePanel("Adaptive R Lessons Quiz"),
      uiOutput("question_ui"),
      uiOutput("feedback_ui"),
      uiOutput("results_ui")
  )
)
