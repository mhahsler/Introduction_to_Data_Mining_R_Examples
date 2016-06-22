#' ---
#' title: "R Code for Chapter 5 of Introduction to Data Mining: Classification"
#' author: "Michael Hahsler"
#' output:
#'  html_document:
#'    toc: true
#' ---

#' This code covers chapter 5 of _"Introduction to Data Mining"_
#' by Pang-Ning Tan, Michael Steinbach and Vipin Kumar.
#'
#' ![CC](https://i.creativecommons.org/l/by/4.0/88x31.png)
#' This work is licensed under the
#' [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/). For questions please contact
#' [Michael Hahsler](http://michael.hahsler.net).
#'

#' Load the data set
data(Zoo, package="mlbench")
head(Zoo)


#' Use multi-core support for cross-validation
library(doParallel)
registerDoParallel()
getDoParWorkers()

#' # Fitting Different Classification Models
#'
#' Load the caret data mining package
library(caret)

#' Create fixed sampling scheme (10-folds) so we can compare the models
#' later on.
train <- createFolds(Zoo$type, k=10)


#' For help with building models in caret see: ? train
#'
#' __Note:__ Be careful if you have many `NA` values in your data. `train()`
#' and cross-validation may fail in some cases. If that is the case then you
#' can remove features (columns) which have many `NA`s, omit `NA`s using
#' `na.omit()` or use imputation to replace them with reasonable
#' values (e.g., by the feature mean or via kNN).
#'

#' ## Conditional Inference Tree (Decision Tree)
ctreeFit <- train(type ~ ., method = "ctree", data = Zoo,
	tuneLength = 5,
	trControl = trainControl(
		method = "cv", indexOut = train))
ctreeFit
plot(ctreeFit$finalModel)

#' The final model can be directly used for predict()
predict(ctreeFit, Zoo[1:2,])

#' ## C 4.5 Decision Tree
library(RWeka)
C45Fit <- train(type ~ ., method = "J48", data = Zoo,
	tuneLength = 5,
	trControl = trainControl(
		method = "cv", indexOut = train))
C45Fit
C45Fit$finalModel

#' ## K-Nearest Neighbors
#'
#' __Note:__ kNN uses Euclidean distance, so data should be scaled first.
#' Here legs are measured between 0 and 6 while all other variables are between
#' 0 and 1.
Zoo_scaled <- cbind(as.data.frame(scale(Zoo[,-17])), type = Zoo[,17])
knnFit <- train(type ~ ., method = "knn", data = Zoo_scaled,
	tuneLength = 5,  tuneGrid=data.frame(k=1:10),
	trControl = trainControl(
		method = "cv", indexOut = train))
knnFit
knnFit$finalModel

#' ## PART (Rule-based classifier)
rulesFit <- train(type ~ ., method = "PART", data = Zoo,
  tuneLength = 5,
  trControl = trainControl(
    method = "cv", indexOut = train))
rulesFit
rulesFit$finalModel


#' ## Linear Support Vector Machines
svmFit <- train(type ~., method = "svmLinear", data = Zoo,
	tuneLength = 5,
	trControl = trainControl(
		method = "cv", indexOut = train))
svmFit
svmFit$finalModel


#' ## Artificial Neural Network
nnetFit <- train(type ~ ., method = "nnet", data = Zoo,
	tuneLength = 5,
	trControl = trainControl(
		method = "cv", indexOut = train))
nnetFit
nnetFit$finalModel


#' ## Random Forest
randomForestFit <- train(type ~ ., method = "rf", data = Zoo,
	tuneLength = 5,
	trControl = trainControl(
		method = "cv", indexOut = train))
randomForestFit
randomForestFit$finalModel

#' # Compare Models
resamps <- resamples(list(
  ctree=ctreeFit,
  C45=C45Fit,
  SVM=svmFit,
  KNN=knnFit,
  rules=rulesFit,
  NeuralNet=nnetFit,
  randomForest=randomForestFit))
resamps
summary(resamps)

difs <- diff(resamps)
difs
summary(difs)
#' All perform similarly well except ctree
#'
#' # More Information
#'
#'* Package caret: http://topepo.github.io/caret/index.html
#'* R taskview on machine learning: http://cran.r-project.org/web/views/MachineLearning.html

