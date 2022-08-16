library(shiny)
library(dplyr)
library(ggplot2)
library(R.utils)

# read the dataset into a dataframe
AP_df <- data.table::fread("Admission_Predict_Ver1.1.csv", stringsAsFactors = FALSE)
univ_level <- c("easy", "relatively easy", "average", "competitive","very competitive")

shinyServer(function(input, output) {
  # return the dataframe with the selected university rating
  get_df <- reactive({
    univ_df <- AP_df %>% filter(University_Rating == input$univ)
    return(univ_df)
  })
  # show the text description of the estimated admission rate
  output$Est_Des <- renderText({
    univ_df <- get_df()
    coe <- lm(Chance_of_Admit ~ TOEFL_Score + GRE_Score + CGPA + Research,
            data = univ_df)
    coe <- coe$coefficients
    coe <- as.numeric(coe)
    est_AR <- coe[1] + coe[2] * input$TS+ coe[3] * input$GS + coe[4] * input$GPA + coe[5] * as.numeric(input$research)
    est_AR <- round(est_AR *100, 2)
    paste0("The estimated admission rate is for the ", univ_level[as.numeric(input$univ)], " university,
           it is based on the given user input data which is shown in the table below. The plot
           below shows the every data point in the dataset and the generated linear regression line.
           The estimation for the current user is ", est_AR, "%.")
  })
  # show a plot showing the relation between four factors and the admission rate for given university rating
  output$Factors_v_AR <- renderPlot({
    univ_df <- get_df()
    tit <- paste0("Admission Prediction for ",univ_level[as.numeric(input$univ)], " university")
    current_graph <- ggplot(univ_df,aes(x = TOEFL_Score + GRE_Score + 
                                               CGPA + Research,
                                             y = Chance_of_Admit)) + 
      geom_point() + 
      geom_smooth(method = "lm", se = FALSE) + 
      ggtitle(tit) + ylab("Admission Prediction")
    print(current_graph)
  })
  # show the input of the user in a table
  output$User_data <- renderTable({
    user_input <- list("TOEFL_Score" = input$TS, "GRE_Score" = input$GS,
                       "CPGA" = input$GPA, 
                       "Research_Experience" = ifelse(1, "Yes", "No"))
  })
  
  # return a dataframe of the seleted university rating
  get_uni <- reactive({
    uni <- AP_df %>% filter(University_Rating == input$reportUniv)
    return(uni)
  })
  # show a plot showing the relationship between TOEFL score and admmission prediction for given university rating
  output$report_toefl <- renderPlot({
    uni <- get_uni()
    g <- ggplot(uni, aes(x = TOEFL_Score, y = Chance_of_Admit)) + geom_point() +
      geom_smooth(method = "lm", se = FALSE) + ggtitle("TOEFL Score v. Admission Prediction")
    print(g)
  })
  # show a plot showing the relationship between GRE score and admmission prediction for given university rating
  output$report_gre <- renderPlot({
    uni <- get_uni()
    g <- ggplot(uni, aes(x = GRE_Score, y = Chance_of_Admit)) + geom_point() +
      geom_smooth(method = "lm", se = FALSE) + ggtitle("GRE Score v. Admission Prediction")
    print(g)
  })
  # show a plot showing the relationship between GPA and admmission prediction for given university rating
  output$report_cgpa <- renderPlot({
    uni <- get_uni()
    g <- ggplot(uni, aes(x = CGPA, y = Chance_of_Admit)) + geom_point() +
      geom_smooth(method = "lm", se = FALSE) + ggtitle("CGPA v. Admission Prediction")
    print(g)
  })
  # show a plot showing the relationship between Research Experience and admmission prediction for given university rating
  output$report_research <- renderPlot({
    uni <- get_uni()
    uni <- uni %>% mutate(Research_Experience = ifelse(Research == "1", "Yes", "No"))
    g <- ggplot(uni, aes(x = Research_Experience, y = Chance_of_Admit)) + geom_col() +
         ggtitle("Research v. Admission Prediction")
    print(g)
  })
  
})
