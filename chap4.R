#' ---
#' title: "R Code for Chapter 4 of Introduction to Data Mining: Classification: Alternative Techniques"
#' author: "Michael Hahsler"
#' output:
#'  html_document:
#'    toc: true
#' ---

#' This code covers chapter 4 of _"Introduction to Data Mining"_
#' by Pang-Ning Tan, Michael Steinbach and Vipin Kumar.
#' __See [table of contents](https://github.com/mhahsler/Introduction_to_Data_Mining_R_Examples#readme) for code examples for other chapters.__
#'
#' ![CC](https://i.creativecommons.org/l/by/4.0/88x31.png)
#' This work is licensed under the
#' [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/). For questions please contact
#' [Michael Hahsler](http://michael.hahsler.net).
#'

library(tidyverse)
library(ggplot2)

#' Show fewer digits
options(digits=3)

#' Load the data set
data(Zoo, package="mlbench")
Zoo <- as_tibble(Zoo)
Zoo


#' Use multi-core support for cross-validation.
#' __Note:__ Does not work with rJava used in RWeka below.
#library(doParallel)
#registerDoParallel()
#getDoParWorkers()

#' # Fitting Different Classification Models
#'
#' Load the caret data mining package
library(caret)

#' Create fixed sampling scheme (10-folds) so we can compare the models
#' later on.
train <- createFolds(Zoo$type, k = 10)
#' The fixed folds are used in `train()` with the argument
#' `trControl = trainControl(method = "cv", indexOut = train))`. If you
#' don't need fixed folds, then remove `indexOut = train`.
#'
#' For help with building models in caret see: `? train`
#'
#' __Note:__ Be careful if you have many `NA` values in your data. `train()`
#' and cross-validation many fail in some cases. If that is the case then you
#' can remove features (columns) which have many `NA`s, omit `NA`s using
#' `na.omit()` or use imputation to replace them with reasonable
#' values (e.g., by the feature mean or via kNN). Highly imbalanced datasets are also problematic since there is a chance that a fold does
#' not contain examples of each class leading to a hard to understand error message.
#'

#' ## Conditional Inference Tree (Decision Tree)
ctreeFit <- Zoo %>% train(type ~ .,
  method = "ctree",
  data = .,
	tuneLength = 5,
	trControl = trainControl(method = "cv", indexOut = train))
ctreeFit
plot(ctreeFit$finalModel)

#' The final model can be directly used for predict()
predict(ctreeFit, head(Zoo))

#' ## C 4.5 Decision Tree
library(RWeka)
C45Fit <- Zoo %>% train(type ~ .,
  method = "J48",
  data = .,
	tuneLength = 5,
	trControl = trainControl(method = "cv", indexOut = train))
C45Fit
C45Fit$finalModel

#' ## K-Nearest Neighbors
#'
#' __Note:__ kNN uses Euclidean distance, so data should be standardized (scaled) first.
#' Here legs are measured between 0 and 6 while all other variables are between
#' 0 and 1.
Zoo_scaled <- Zoo %>% mutate_at(vars(-17), function(x) as.vector(scale(x)))

knnFit <- Zoo_scaled %>% train(type ~ .,
  method = "knn",
  data = .,
	tuneLength = 5,
  tuneGrid=data.frame(k = 1:10),
	trControl = trainControl(method = "cv", indexOut = train))
knnFit
knnFit$finalModel

#' ## PART (Rule-based classifier)
rulesFit <- Zoo %>% train(type ~ .,
  method = "PART",
  data = .,
  tuneLength = 5,
  trControl = trainControl(method = "cv", indexOut = train))
rulesFit
rulesFit$finalModel


#' ## Linear Support Vector Machines
svmFit <- Zoo %>% train(type ~.,
  method = "svmLinear",
  data = .,
	tuneLength = 5,
	trControl = trainControl(method = "cv", indexOut = train))
svmFit
svmFit$finalModel

#' ## Random Forest
randomForestFit <- Zoo %>% train(type ~ .,
  method = "rf",
  data = .,
	tuneLength = 5,
	trControl = trainControl(method = "cv", indexOut = train))
randomForestFit
randomForestFit$finalModel


#' ## Gradient Boosted Decision Trees (xgboost)
xgboostFit <- Zoo %>% train(type ~ .,
  method = "xgbTree",
  data = .,
  tuneLength = 5,
  trControl = trainControl(method = "cv", indexOut = train),
  tuneGrid = expand.grid(
    nrounds = 20,
    max_depth = 3,
    colsample_bytree = .6,
    eta = 0.1,
    gamma=0,
    min_child_weight = 1,
    subsample = .5
  ))
xgboostFit
xgboostFit$finalModel


#' ## Artificial Neural Network
nnetFit <- Zoo %>% train(type ~ .,
  method = "nnet",
  data = .,
	tuneLength = 5,
	trControl = trainControl(method = "cv", indexOut = train),
  trace = FALSE)
nnetFit
nnetFit$finalModel

#' # Compare Models
resamps <- resamples(list(
  ctree = ctreeFit,
  C45 = C45Fit,
  SVM = svmFit,
  KNN = knnFit,
  rules = rulesFit,
  randomForest = randomForestFit,
  xgboost = xgboostFit,
  NeuralNet = nnetFit
    ))
resamps
summary(resamps)

difs <- diff(resamps)
difs
summary(difs)
#' All perform similarly well except ctree
#'
#' # More Information
#'
#'* [Example using deep learning with keras.](chap4_keras.html)
#'* [A visual comparison of decision boundaries.](chap4_decisionboundary.html)
#'* Package caret: http://topepo.github.io/caret/index.html
#'* R taskview on machine learning: http://cran.r-project.org/web/views/MachineLearning.html
#'

