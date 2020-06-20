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


#' For help with building models in caret see: ? train
#'
#' __Note:__ Be careful if you have many `NA` values in your data. `train()`
#' and cross-validation many fail in some cases. If that is the case then you
#' can remove features (columns) which have many `NA`s, omit `NA`s using
#' `na.omit()` or use imputation to replace them with reasonable
#' values (e.g., by the feature mean or via kNN).
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
#'* [Example using deep learning with keras.](chap5_keras.html)
#'* [A visual comparison of decision boundaries.](chap5_decisionboundary.html)
#'* Package caret: http://topepo.github.io/caret/index.html
#'* R taskview on machine learning: http://cran.r-project.org/web/views/MachineLearning.html
#'



#' # Class Imbalance Problem
#'
#' Classifiers have a hard time to learn from data where we have much more observations for one class (called the majority class). This is called the class imbalance problem.
#'
#' Here is a very good [article about the problem and solutions.](http://www.kdnuggets.com/2016/08/learning-from-imbalanced-classes.html)
#'
library(rpart)
library(rpart.plot)
data(Zoo, package="mlbench")
Zoo <- as_tibble(Zoo)

#' Class distribution
ggplot(Zoo, aes(y = type)) + geom_bar()

#' To create an imbalanced problem, we want to decide if an animal is an reptile.
#' First, we change the class variable
#' to make it into a binary reptile/no reptile classification problem.
#' __Note:__ We use here the training data for testing. You should use a
#' separate testing data set!

Zoo_reptile <- Zoo %>% mutate(
  type = factor(Zoo$type == "reptile", levels = c(FALSE, TRUE),
    labels = c("nonreptile", "reptile")))

#' Do not forget to make the class variable a factor (a nominal variable)
#' or you will get a regression tree instead of a classification tree.

summary(Zoo_reptile)

#' See if we have a class imbalance problem.
ggplot(Zoo_reptile, aes(y = type)) + geom_bar()

#' the new class variable is clearly not balanced. This is a problem
#' for building a tree!
#'
#' ## Option 1: Use the Data As Is and Hope For The Best

fit <- Zoo_reptile %>% train(type ~ .,
  data = .,
  method = "rpart",
  trControl = trainControl(method = "cv"))
fit
rpart.plot(fit$finalModel, extra = 2)
#' the tree predicts everything as non-reptile. Have a look at the error on
#' the training set.

confusionMatrix(data = predict(fit, Zoo_reptile),
  ref = Zoo_reptile$type, positive = "reptile")
#' The accuracy is exactly the same as the no-information rate
#' and kappa is zero. Sensitivity is also zero, meaning that we do not identify
#' any positive (reptile). If the cost of missing a positive is much
#' larger than the cost associated with misclassifying a negative, then accuracy
#' is not a good measure!
#' By dealing with imbalance, we are __not__ concerned
#' with accuracy, but we want to increase the
#' sensitivity, i.e., the chance to identify positive examples.
#'
#' __Note:__ The positive class value (the one that
#' you want to detect) is set manually to reptile.
#' Otherwise sensitivity/specificity will not be correctly calculated.
#'
#' ## Option 2: Balance Data With Resampling
#'
#' We use stradified sampling with replacement (to oversample the
#' minority/positive class).
#' You could also use SMOTE (in package __DMwR__) or other sampling strategies (e.g., from package __unbalanced__). We
#' use only 50+50 observations here since our dataset has only 101 observations total.
library(sampling)
id <- strata(Zoo_reptile, stratanames = "type", size = c(50, 50), method = "srswr")
Zoo_reptile_balanced <- Zoo_reptile %>% slice(id$ID_unit)
table(Zoo_reptile_balanced$type)

fit <- Zoo_reptile_balanced %>% train(type ~ .,
  data = .,
  method = "rpart",
  trControl = trainControl(method = "cv"),
  control = rpart.control(minsplit = 5))
fit
rpart.plot(fit$finalModel, extra = 2)

#' Check on balanced training data.
confusionMatrix(data = predict(fit, Zoo_reptile_balanced),
  ref = Zoo_reptile_balanced$type, positive = "reptile")
#' We see that sensitivity is now 1 which means that we are able to identify all
#' reptiles (pos. examples).
#'
#'
#' However, real data that we will make predictions for will not be balanced.
#' Check on original data with original class distribution.

confusionMatrix(data = predict(fit, Zoo_reptile),
  ref = Zoo_reptile$type, positive = "reptile")

#' __Note__ that the accuracy is below the no information rate! However,
#' you see that this model is able to find all reptiles (sensitivity of 1),
#' but it also misclassifies
#' many non-reptiles as reptiles. The tradeoff can be controlled using the sample
#' proportions.
#'

#' ## Option 3: Build A Larger Tree and use Predicted Probabilities
#'
#' Increase complexity and require less data for splitting a node.
#' Here I also use AUC (area under the ROC) as the tuning metric.
#' You need to specify the two class
#' summary function. Note that the tree still trying to improve accuracy on the
#' data and not AUC! I also enable class probabilities since I want to predict
#' probabilities later.

fit <- Zoo_reptile %>% train(type ~ .,
  data = .,
  method = "rpart",
  tuneLength = 20,
  trControl = trainControl(method = "cv",
    classProbs = TRUE,                 ## necessary for predict with type="prob"
    summaryFunction=twoClassSummary),  ## necessary for ROC
  metric = "ROC",
  control = rpart.control(minsplit = 5))
fit

rpart.plot(fit$finalModel, extra = 2)

confusionMatrix(data = predict(fit, Zoo_reptile),
  ref = Zoo_reptile$type, positive = "reptile")
#' __Note:__ Accuracy is high, but it is close to the no-information rate!
#'
#' ### Create A Biased Classifier
#'
#' We can create a classifier which will detect more reptiles
#' at the expense of misclassifying non-reptiles. This is equivalent
#' to increasing the cost of misclassifying a reptile as a non-reptile.
#' The usual rule is to predict in each node
#' the majority class from the test data in the node.
#' For a binary classification problem that means a probability of >50%.
#' In the following, we reduce this threshold to 25% or more.
#' This means that if the new observation ends up in a leaf node with 25% or
#'  more reptiles from training then the observation
#'  will be classified as a reptile.
#'
#'  __Note__ that you should use an unseen test set
#'  for `predict()` here! I did not do that since the data set is too small!
prob <- predict(fit, Zoo_reptile, type = "prob")
tail(prob)
pred <- as.factor(ifelse(prob[,"reptile"]>=.25, "reptile", "nonreptile"))


confusionMatrix(data = pred,
  ref = Zoo_reptile$type, positive = "reptile")
#' __Note__ that accuracy goes down and is below the no information rate.
#' However, both measures are based on the idea that all errors have the same
#' cost. What is important is that we are now able to find all almost all
#' reptiles (sensitivity is .8) while before we only found 2 out of 5
#' (sensitivity of .4)
#'

#' ### Plot the ROC Curve
#' Since we have a binary classification problem and a classifier that predicts
#' a probability for an observation to be a reptile, we can also use a
#' [receiver operating characteristic (ROC)](https://en.wikipedia.org/wiki/Receiver_operating_characteristic)
#' curve. For the ROC curve all different cutoff thresholds for the probability
#' are used and then connected with a line.
library("pROC")
r <- roc(Zoo_reptile$type == "reptile", prob[,"reptile"])
r

plot(r)
#' This also reports the area under the curve.
#'

#' ## Option 4: Use a Cost-Sensitive Classifier
#'
#' The implementation of CART in `rpart` can use a cost matrix for making splitting
#' decisions (as parameter `loss`). The matrix has the form
#'
#'  TP FP
#'  FN TN
#'
#' TP and TN have to be 0. We make FN very expensive (100).

cost <- matrix(c(
  0,   1,
  100, 0
), byrow = TRUE, nrow = 2)
cost


fit <- Zoo_reptile %>% train(type ~ .,
  data = .,
  method = "rpart",
  parms = list(loss = cost),
  trControl = trainControl(method = "cv"))
#' The warning "There were missing values in resampled performance measures"
#' means that some folds did not contain any reptiles (because of the class imbalance)
#' and thus the performance measures could not be calculates.

fit

rpart.plot(fit$finalModel, extra = 2)

confusionMatrix(data = predict(fit, Zoo_reptile),
  ref = Zoo_reptile$type, positive = "reptile")
#' The high cost for false negatives results in a classifier that does not miss any reptile.
#'
#' __Note:__ Using a cost-sensitive classifier is often the best option. Unfortunately, the most classification algorithms (or their implementation) do not have the ability to consider misclassification cost.

