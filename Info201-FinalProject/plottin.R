# Make graph
library(dplyr)
library(ggplot2)
library(R.utils)
AP_df <- data.table::fread("Admission_Predict_Ver1.1.csv", stringsAsFactors = FALSE)
univ_rate <- c(1:5)

# plot the admission rate based on TOEFL and GRE Test for each university rating
for(school in univ_rate){
  current_rate <- AP_df[AP_df$University_Rating == school, ]
  current_graph <- ggplot(current_rate,aes(x = TOEFL_Score + GRE_Score + CGPA + Research,
                                           y = Chance_of_Admit)) + 
    geom_point() + 
    geom_smooth(method = "lm", se = FALSE) + ggtitle(school)
  print(current_graph)
}