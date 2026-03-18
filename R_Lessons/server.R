library(shiny)
item_bank <- read.csv("item_bank.csv", stringsAsFactors = FALSE)




# Difficulty-based next item selector
select_next_item <- function(item_bank, used_ids, current_difficulty) {
  remaining <- item_bank[!item_bank$id %in% used_ids, ]
  candidates <- remaining[remaining$difficulty == current_difficulty, ]
  if (nrow(candidates) == 0) candidates <- remaining
  selected <- candidates[sample(nrow(candidates), 1), ]
  return(selected)
}

server <- function(input, output, session) {
  
  rv <- reactiveValues(
    used_ids = c(),
    current_difficulty = 2,
    current_item = NULL,
    iteration = 0,
    done = FALSE,
    feedback = NULL,
    correct_count = 0, 
    wrong_count = 0,
    streak_correct = 0
  )
  
  # Select first item
  observeEvent(TRUE, {
    rv$current_item <- select_next_item(item_bank, rv$used_ids, rv$current_difficulty)
  }, once = TRUE)
  
  # Display question
  output$question_ui <- renderUI({
    req(!rv$done)
    item <- rv$current_item
    list(
      h3(item$question),
      radioButtons(
        "answer",
        "Choose one:",
        choices = as.character(unlist(item[c("choice1","choice2","choice3","choice4")]))
      ),
      actionButton("submit", "Submit")
    )
  })
  
  # Color-coded feedback
  output$feedback_ui <- renderUI({
    req(rv$feedback)
    color <- if (rv$feedback == "Correct!") "green" else "red"
    div(
      style = paste0("margin-top: 10px; font-weight: bold; color:", color, ";"),
      rv$feedback
    )
  })
  
  # Handle submission
  observeEvent(input$submit, {
    req(input$answer)
    
    rv$iteration <- rv$iteration + 1
    item <- rv$current_item
    
    # Score based on matching selected text to correct text
    correct <- as.integer(
      input$answer == item[[ paste0("choice", item$answer) ]]
    )
    
    # Store feedback
    rv$feedback <- if (correct == 1) "Correct!" else "Incorrect."
    
    # Track total correct answers
    rv$correct_count <- rv$correct_count + correct
    
    
    # Track consecutive correct answers
    if (correct == 1) {
      rv$streak_correct <- rv$streak_correct + 1
    } else {
      rv$streak_correct <- 0
      rv$wrong_count <- rv$wrong_count + 1   # increment wrong answer counter
    }
    
    # the adaptive part, updates diffuculty based on answering 3 correct in cur dif
    if (rv$streak_correct >= 3) { #this lets ppl move on in difficulty once 3 correct
      rv$current_difficulty <- min(rv$current_difficulty + 1, 6) #+1 out of 6, starts at 2
      rv$streak_correct <- 0   # reset streak after leveling up
    } else if (correct == 0) {
      rv$current_difficulty <- max(rv$current_difficulty - 1, 1)
    }
    
    
    # Mark item as used using id from csv
    rv$used_ids <- c(rv$used_ids, item$id)
    
    #stopping rule, can get 9/13 but lower = stops quiz
    if (rv$wrong_count >= 4) {
      rv$done <- TRUE
      return()
    }
    
    # Stopping rule 2: max 13 questions. 3,3,3,3,1 = 13 total if all correct
    if (rv$iteration >= 13) {
      rv$done <- TRUE
    } else {
      rv$current_item <- select_next_item(item_bank, rv$used_ids, rv$current_difficulty)
    }
  })
  
  # adding in the final results of the quiz, capped at 13 q if other threshold criteria met
  output$results_ui <- renderUI({
    req(rv$done)
    
    score_text <- paste0(
      "You answered ", rv$correct_count, 
      " out of ", rv$iteration, " questions correctly."
    )
    
    div(
      h3("Quiz Complete!"),
      h4(score_text),
      p("This quiz adapts to your skill level, so take it again over the course of this series to see if you have improved! \n If you got more than 4 answers wrong, the quiz automatically stops. This means you need to practice more with the material and need to come back later to re-take the quiz. ")
    )
  })
}

