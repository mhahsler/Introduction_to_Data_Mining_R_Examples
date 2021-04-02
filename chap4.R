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
#' We will use tidyverse to prepare the data.
library(tidyverse)

#' Show fewer digits
options(digits=3)

#' # Load the Zoo Dataset and Create a Training Set
#' We will use the Zoo dataset which is included in the R package `mlbench` (you may have to install it).
#' The Zoo dataset containing 17 (mostly logical) variables on different 101 animals as a
#'   data frame with 17 columns (hair, feathers, eggs, milk, airborne, aquatic, predator, toothed, backbone, breathes, venomous, fins, legs, tail, domestic, catsize, type). We convert the data frame into a tidyverse tibble (optional).
data(Zoo, package="mlbench")
Zoo <- as_tibble(Zoo)
Zoo

#'
#' We will use the package [__caret__](https://topepo.github.io/caret/) to make preparing training sets and building classification (and regression) models easier. A great cheat sheet can be found [here](https://ugoproto.github.io/ugo_r_doc/pdf/caret.pdf).
#'

library(caret)

#' Use multi-core support for cross-validation.
#' __Note:__ It is commented out because it does not work with rJava used in RWeka below.
#library(doMC, quietly = TRUE)
#registerDoMC(cores = 4)
#getDoParWorkers()

#' Test data is not used in the model building process and needs to be set aside purely for testing the model after it is completely built. Here I use 80% for training.
inTrain <- createDataPartition(y = Zoo$type, p = .8, list = FALSE)
Zoo_train <- Zoo %>% slice(inTrain)
Zoo_test <- Zoo %>% slice(-inTrain)

#' # Fitting Different Classification Models to the Training Data

#' Create a fixed sampling scheme (10-folds) so we can compare the fitted models
#' later.
train_index <- createFolds(Zoo_train$type, k = 10)
#' The fixed folds are used in `train()` with the argument
#' `trControl = trainControl(method = "cv", indexOut = train_index))`. If you
#' don't need fixed folds, then remove `indexOut = train_index` in the code below.
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
ctreeFit <- Zoo_train %>% train(type ~ .,
  method = "ctree",
  data = .,
	tuneLength = 5,
	trControl = trainControl(method = "cv", indexOut = train_index))
ctreeFit
plot(ctreeFit$finalModel)

#' The final model can be directly used for predict()
predict(ctreeFit, head(Zoo_test))

#' ## C 4.5 Decision Tree
library(RWeka)
C45Fit <- Zoo_train %>% train(type ~ .,
  method = "J48",
  data = .,
	tuneLength = 5,
	trControl = trainControl(method = "cv", indexOut = train_index))
C45Fit
C45Fit$finalModel

#' ## K-Nearest Neighbors
#'
#' __Note:__ kNN uses Euclidean distance, so data should be standardized (scaled) first.
#' Here legs are measured between 0 and 6 while all other variables are between
#' 0 and 1. Scaling can be directly performed as preprocessing in `train` using the parameter
#' `preProcess = "scale"`.
knnFit <- Zoo_train %>% train(type ~ .,
  method = "knn",
  data = .,
  preProcess = "scale",
	tuneLength = 5,
  tuneGrid=data.frame(k = 1:10),
	trControl = trainControl(method = "cv", indexOut = train_index))
knnFit
knnFit$finalModel

#' ## PART (Rule-based classifier)
rulesFit <- Zoo_train %>% train(type ~ .,
  method = "PART",
  data = .,
  tuneLength = 5,
  trControl = trainControl(method = "cv", indexOut = train_index))
rulesFit
rulesFit$finalModel


#' ## Linear Support Vector Machines
svmFit <- Zoo_train %>% train(type ~.,
  method = "svmLinear",
  data = .,
	tuneLength = 5,
	trControl = trainControl(method = "cv", indexOut = train_index))
svmFit
svmFit$finalModel

#' ## Random Forest
randomForestFit <- Zoo_train %>% train(type ~ .,
  method = "rf",
  data = .,
	tuneLength = 5,
	trControl = trainControl(method = "cv", indexOut = train_index))
randomForestFit
randomForestFit$finalModel


#' ## Gradient Boosted Decision Trees (xgboost)
xgboostFit <- Zoo_train %>% train(type ~ .,
  method = "xgbTree",
  data = .,
  tuneLength = 5,
  trControl = trainControl(method = "cv", indexOut = train_index),
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
nnetFit <- Zoo_train %>% train(type ~ .,
  method = "nnet",
  data = .,
	tuneLength = 5,
	trControl = trainControl(method = "cv", indexOut = train_index),
  trace = FALSE)
nnetFit
nnetFit$finalModel

#' # Compare Models
#'
#' Collect the performance metrics from the models trained on the same data.
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

#' Calculate summary statistics
summary(resamps)

#' Perform inference about differences between models. For each metric, all pair-wise differences are computed and tested to assess if the difference is equal to zero. By default Bonferroni correction for multiple comparison is used. Differences are shown in the upper triangle and p-values are in the lower triangle.
difs <- diff(resamps)
difs
summary(difs)
#' All perform similarly well except ctree (differences in the first row are negative and the p-values in the first column are <.05 indicating that the null-hypothesis of a difference of 0 can be rejected).
#'
#'
#' # Using the Chosen Model on the Test Data
#'
#' Most models do similarly well on the data. We choose here the random forest model.

pr <- predict(randomForestFit, Zoo_test)
pr

#' Calculate the confusion matrix for the held-out test data.
confusionMatrix(Zoo_test$type, pr)


#' # More Information
#'
#'* [Example using deep learning with keras.](chap4_keras.html)
#'* [A visual comparison of decision boundaries.](chap4_decisionboundary.html)
#'* Package caret: http://topepo.github.io/caret/index.html
#'* Tidymodels (machine learning with tidyverse): https://www.tidymodels.org/
#'* R taskview on machine learning: http://cran.r-project.org/web/views/MachineLearning.html
#'

