##Importing and formatting survey data



import_dem_data <- function(){
  
  dem <- read.csv("Fb_demographic.csv", header = TRUE)
  colnames(dem) <- as.character(unlist(dem[1,]))
  dem = dem[-1, ]
  return(dem)
 
}


import_hrv_data <- function(){
  hrv <- read.csv("hrv.csv", header = TRUE)
  return(hrv)
}


import_post_data <- function(){ 
  post <- read.csv("FB Post Survey.csv", header = TRUE)
  colnames(post) <- as.character(unlist(post[1,]))
  post = post[-1, ]
  return(post)
}

  
## Extracting variables for cluster analysis 
extract_variables <- function(dem, cols, colnames){

  dem_imp <- dem[ , cols]
  colnames(dem_imp) <- colnames
  dem_imp <- sapply(dem_imp, as.numeric)
  return(dem_imp)

}
# removing NaNs from dataframe

remove_Nan <- function(dem_imp){

  for(i in 1:ncol(dem_imp)){
    dem_imp[is.na(dem_imp[,i]), i] <- mean(dem_imp[,i], na.rm = TRUE)
  }
  
  dem_imp <- as.data.frame(dem_imp)
  return(dem_imp)

}

##Scree PLots
make_scree <- function(dem_imp){

  
  # Initialise ratio_ss
  ratio_ss <- rep(0, 7)
  
  
  set.seed(3)
  for (k in 1:7) {
    
    # Apply k-means to school_result: school_km
    kmeans <- kmeans(dem_imp, k, nstart = 20)
    
    # Save the ratio between of WSS to TSS in kth element of ratio_ss
    ratio_ss[k] <- kmeans$tot.withinss / kmeans$totss
    
  }
  
  # Make a scree plot with type "b" and xlab "k"
  plot(ratio_ss, type = "b", xlab = "k")

}

##Clustering


cluster_plot <- function(dem_imp , n){
  set.seed(3)
  results <- kmeans(dem_imp, n)
  plot(jitter(dem_imp$trusting), jitter(dem_imp$nervous) , col = results$cluster, pch = 20)
  return(results$cluster)
}

cluster_anova <- function(cluster_list, hrv){
  cluster_1 = data.frame(hrv = numeric() )
  for (i in range(length(cluster_list))){
    cluster = cluster_list[i]
    if (cluster == 1){
      cluster_1 = rbind(cluster_1,hrv$X[i])
      
    }
    
  }
  return(cluster_1)
  
}


# dem_life <- dem[ , c(65:69)]
# dem_life <- sapply(dem_life, as.numeric)
# dem_life <- as.data.frame(dem_life)
# aggregate(dem_life, by=list(results$cluster), FUN=mean)
# aggregate(dem_life, by=list(results$cluster), FUN=sd)

main <- function(){
  dem <- import_dem_data()
  hrv <- import_hrv_data()
  
  dem_imp <- extract_variables(dem, c(47, 48, 52, 54, 55),  c("reserved", "trusting","outgoing", "conscentious", "nervous"))
  dem_imp <- remove_Nan(dem_imp)
  make_scree(dem_imp)
  cluster_list <- cluster_plot(dem_imp, 3)
  length(cluster_list)
  
  # 
  # View(hrv)
  # class(hrv)
  # View(dem)
  cluster_1 <- c(NA, 75.358652812217414, 29.183360658530102, NA, 23.277351809774103, 60.199560903281217, 95.116408992949843, 152.66729732392608, 49.487181730046686, 70.647733670141704, 21.74251693432652, 77.905247199167164, 73.682013158889418, NA, 43.361079453604908, 34.92920148065631, 19.035429789955494, 35.02605970926593, 42.881982309352971, 64.190231101487242, 54.041333540464976, 87.480562790444779, 43.252561233997881, 57.905485040193824, 42.016138949258398, 71.532774677817059, 64.415626065077831, NA, 20.589819463421787, 40.761460180409735, 65.751746249293348, 55.910631789569628, 53.921395140821275, 53.406499953546266, 58.862454679411897)
  cluster_1 <- as.numeric(cluster_1)
  mean(cluster_1, na.rm = TRUE)
  cluster_2 <- c(NA, 77.928331553787672, 29.536402155432071, NA, 26.007898023713082, NA, 54.091669022111965, NA, 45.807466652432794, 45.994491946476018, 37.830502146487134, 68.366499232908907, 87.40376060625988, 45.741750857487936, 93.63170523777886, NA, 43.69844476583566, 23.68023455042551, NA, 18.423392107933566, NA, 20.659101095845543, 36.797096489954143, 29.447279947242102)
  cluster_2 <- as.numeric(cluster_2)
  mean(cluster_2, na.rm = TRUE)
  cluster_3 <- c(NA, 100.78490698132074, 99.797280399524141, 45.671390402034, 67.817889845974918, 66.560530019102401, 32.243876806818747, NA, NA, 30.906431374463544, 74.421194053131032, 39.27099684848033, 46.497674219956082, 25.394387996110474)
  cluster_3 <- as.numeric(cluster_3)
  mean(cluster_3, na.rm = TRUE)
  
  hrv_clusters <- c(cluster_1, cluster_2, cluster_3)
  hrv_clusters
  
  cl1 <- "Cluster 1"
  cl2 <- "Cluster 2"
  cl3 <- "Cluster 3"
  
  
  cluster_bar <- c(mean(cluster_1, na.rm = TRUE), mean(cluster_2, na.rm = TRUE), mean(cluster_3, na.rm = TRUE))
  barplot(cluster_bar)
  
  
  clu_1 <- rep(cl1, length(cluster_1))
  clu_2 <- rep(cl2, length(cluster_2))
  clu_3 <- rep(cl3, length(cluster_3))
  clusters <- c(clu_1, clu_2, clu_3)
  length(clusters)
  # length(hrv_clusters)
  
  clusters_hrv.df <- data.frame(clusters, hrv_clusters)
  clusters_hrv.df
  
  model <- lm(hrv_clusters~clusters, data = clusters_hrv.df)
  anova(model)
  summary(model)
  
  
}

main()




