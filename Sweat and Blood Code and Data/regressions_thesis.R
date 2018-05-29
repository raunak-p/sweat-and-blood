##Regressions


import_post_data <- function(){ 
  post <- read.csv("FB Post Survey.csv", header = TRUE)
  colnames(post) <- as.character(unlist(post[1,])) #setting column names correctly
  post = post[-1, ] #Removing last column, which is trash
  return(post)
}

import_phys_data <- function(){
  phys <- read.csv("movie.csv")
  return(phys)
}

##extracts important variables
extract_important <- function(post){
  post_imp <- data.frame(
    "fault_enjoy" = post$`How much did you enjoy watching the clip The Fault in our Stars?`,
    "fault_feel" = post$`Overall, how do you feel about The / Fault in our Stars?`,
    "fault_share" = post$`How likely would you be to share The Fault in our Stars  movie trailer with a friend?`,
    "hard_enjoy" = post$`How much did you enjoy watching the clip Get Hard?`,
    "hard_feel" = post$`Overall, how do you feel about Get / Hard?`,
    "hard-share" = post$`How likely would you be to share the Get Hard movie trailer with a friend?`,
    "ent_enjoy" = post$`How much did you enjoy watching the clip Entourage?`,
    "ent_feel" = post$`Overall, how do you feel / about Entourage?`,
    "ent_share" = post$`How likely would you be to share the Entourage movie trailer with a friend?`,
    "vic_enjoy" = post$`How much did you enjoy watching the clip Get Hard?`,
    "vic_feel" = post$`Overall, how do you feel / about Victoria's Secret?`,
    "vic_share" = post$`How likely would you be to share the Victoria's Secret ad with a friend?`
  )
  post_imp <- sapply(post_imp, as.numeric)
  return(post_imp)
}


#deleting every second row of dataframe. Every 2nd row contains data from mobile screen. We will use only computer monitor for this analysis
delete_every_2nd <- function(post){
  post[-(seq(2,to=nrow(post),by=2)),]

}

##pairwise plots of how people feel about the different movies. Just a quick sanity check as there should be correlations
pairwise_scatter <- function(post_imp){
  pairs(jitter(post_imp[ , c(1:3)]))
  pairs(jitter(post_imp[ , c(4:6)]))
  pairs(jitter(post_imp[ , c(7:9)]))
  pairs(jitter(post_imp[ , c(10:12)]))
}

##calculates column means of post_imp
post_mean <- function(post_imp){
  post_imp_mn <- data.frame(means = colMeans(subset(post_imp, select = c(1, 4, 7, 10))))
  return(post_imp_mn)
}


##Makes 3 scatter plots. RR vs EDA. Movie Enjoyment 
scatter_plots <- function(phys, post_imp_means){
  plot(phys$EDA, post_imp_means$means, main = "Enjoyment Levels vs EDA", pch =19, xlab = "EDA", ylab = "Enjoyment Levels" )
  plot(phys$RR, post_imp_means$means, pch =19, main = "Enjoyment Levels vs RR", xlab = "RR", ylab = "Enjoyment Levels")
  
}

#Extracts regression coefficient for movie enjoyment plottet against average RR and EDA for that movie
regression_coffiecient <- function(phys, post_imp_means){
  regression <- lm(post_imp_means$means ~ phys$RR + phys$EDA)
  return(summary(regression))
}

main <- function(){
  ##reading in data
  post <- import_post_data()
  phys <- import_phys_data()
  ##functions to make plots and results
  post <- delete_every_2nd(post)
  post_imp <- extract_important(post)
  pairwise_scatter(post_imp)
  post_imp_means <- post_mean(post_imp)
  scatter_plots(phys, post_imp_means)
  regression_coffiecient(phys, post_imp_means)

}


main()






