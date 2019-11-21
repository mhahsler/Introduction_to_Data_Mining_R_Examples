#' ---
#' title: "R Code for Chapter 3 of Introduction to Data Mining: Classification: Basic Concepts and Techniques"
#' author: "Michael Hahsler"
#' output:
#'  html_document:
#'    toc: true
#' ---

#' This code covers chapter 3 of _"Introduction to Data Mining"_
#' by Pang-Ning Tan, Michael Steinbach and Vipin Kumar.
#' __See [table of contents](https://github.com/mhahsler/Introduction_to_Data_Mining_R_Examples#readme) for code examples for other chapters.__
#'
#' ![CC](https://i.creativecommons.org/l/by/4.0/88x31.png)
#' This work is licensed under the
#' [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/). For questions please contact
#' [Michael Hahsler](http://michael.hahsler.net).
#'


#' # Prepare Zoo Data Set
data(Zoo, package="mlbench")
head(Zoo)

#' Get summary statistics
summary(Zoo)

#' translate all the TRUE/FALSE values into factors (nominal) or the tree
for(i in c(1:12, 14:16)) Zoo[[i]] <- as.factor(Zoo[[i]])

summary(Zoo)


#' # A First Decision Tree
#'
#' Recursive Partitioning (similar to CART) uses the Gini index to make
#' splitting decisions and early stopping (pre-pruning).

library(rpart)

#' ## Create Tree With Default Settings (uses pre-pruning)
tree_default <- rpart(type ~ ., data = Zoo)
tree_default

#' __Note:__ the class variable needs a factor (nominal) or rpart
#' will create a regression tree instead of a decision tree. Use `as.factor()`
#' if necessary.
#'
#' Plotting
library(rpart.plot)
rpart.plot(tree_default, extra = 2, under = TRUE, varlen=0, faclen=0)
#' _Note:_ `extra=2` prints for each leaf node the number of correctly
#' classified objects from data and the total number of objects
#' from the training data falling into that node (correct/total).
#'
#' ## Create a Full Tree
#'
#' To create a full tree, we set the complexity parameter cp to 0 (split even
#' if it does not improve the tree) and we set the minimum number of
#' observations in a node needed to split to the smallest value of 2
#' (see: `?rpart.control`).
#' _Note:_ full trees overfit the training data!
tree_full <- rpart(type ~., data=Zoo, control=rpart.control(minsplit=2, cp=0))
rpart.plot(tree_full, extra = 2, under = TRUE,  varlen=0, faclen=0)
tree_full

#' Training error on tree with pre-pruning
head(predict(tree_default, Zoo))
pred <- predict(tree_default, Zoo, type="class")
head(pred)

confusion_table <- table(Zoo$type, pred)
confusion_table

correct <- sum(diag(confusion_table))
correct
error <- sum(confusion_table)-correct
error

accuracy <- correct / (correct+error)
accuracy

#' Use a function for accuracy
accuracy <- function(truth, prediction) {
    tbl <- table(truth, prediction)
    sum(diag(tbl))/sum(tbl)
}

accuracy(Zoo$type, pred)

#' Training error of the full tree
accuracy(Zoo$type, predict(tree_full, Zoo, type="class"))

#' Get a confusion table with more statistics (using caret)
library(caret)
confusionMatrix(data = pred, reference = Zoo$type)

#' ## Make Predictions for New Data
#'
#' Make up my own animal: A lion with feathered wings

my_animal <- data.frame(hair = TRUE, feathers = TRUE, eggs = FALSE,
  milk = TRUE, airborne = TRUE, aquatic = FALSE, predator = TRUE,
  toothed = TRUE, backbone = TRUE, breathes = TRUE, venomous = FALSE,
  fins = FALSE, legs = 4, tail = TRUE, domestic = FALSE,
  catsize = FALSE, type = NA)

#' Fix columns to be factors like in the training set.

for(i in c(1:12, 14:16)) my_animal[[i]] <- factor(my_animal[[i]],
  levels = c(TRUE, FALSE))

my_animal

#' Make a prediction using the default tree
predict(tree_default , my_animal, type = "class")

#' # Model Evaluation
#' ## Pure R Implementation
#' ### Holdout Sample
#'
#' Use a simple split into 2/3 training and 1/3 testing data. Find the size
#' of the training set.

n_train <- as.integer(nrow(Zoo)*.66)
n_train

#' Randomly choose the rows of the training examples.
train_id <- sample(1:nrow(Zoo), n_train)
head(train_id)

#' Split the data
train <- Zoo[train_id,]
test <- Zoo[-train_id, colnames(Zoo) != "type"]
test_type <- Zoo[-train_id, "type"]

tree <- rpart(type ~., data=train,control=rpart.control(minsplit=2))

#' Training error
accuracy(train$type, predict(tree, train, type="class"))

#' Generalization error
accuracy(test_type, predict(tree, test, type="class"))

#' ### 10-Fold Cross Validation

index <- 1:nrow(Zoo)
index <- sample(index) ### shuffle index
fold <- rep(1:10, each=nrow(Zoo)/10)[1:nrow(Zoo)]

folds <- split(index, fold) ### create list with indices for each fold

#' Do each fold
accs <- vector(mode="numeric")
for(i in 1:length(folds)) {
    tree <- rpart(type ~., data=Zoo[-folds[[i]],], control=rpart.control(minsplit=2))
    accs[i] <- accuracy(Zoo[folds[[i]],]$type, predict(tree, Zoo[folds[[i]],], type="class"))
}
accs

#' Report the average
mean(accs)

#' ## Caret: For Easier Model Building and Evaluation
#' see http://cran.r-project.org/web/packages/caret/vignettes/caret.pdf
#'
#' Enable multi-core
library(doParallel)
registerDoParallel()

#' ### k-fold Cross Validation
#' caret packages training and testing into a single function called `train()`.
#' It internally splits the data into training and testing sets and thus will
#' provide you with generalization error estimates. `trainControl` is used
#' to choose how testing is performed.
#'
#' Train also tries to tune extra parameters by trying different values.
#' For rpart, train tries to tune the cp parameter (tree complexity)
#' using accuracy to chose the best model. I set minsplit to 2 since we have
#' not much data.
#' __Note:__ Parameters used for tuning (in this case `cp`) need to be set using
#' a data.frame in the argument `tuneGrid`! Setting it in control will be ignored.
library(caret)
fit <- train(type ~ ., data = Zoo , method = "rpart",
	control=rpart.control(minsplit=2),
	trControl = trainControl(method = "cv", number = 10),
	tuneLength=5)
fit
#' __Note:__ Train has built 10 trees. Accuracy and kappa for each tree/test fold
#' can be obtained.
fit$resample

#' A model using the best tuning parameters
#' and using all the data is available as `fit$finalModel`.

rpart.plot(fit$finalModel, extra = 2, under = TRUE,  varlen=0, faclen=0)
#' __Note:__ For many models, caret converts factors into dummy coding, i.e.,
#' a single 0-1 variable for each factor level. This is why you see split nodes
#' like `milkTRUE>=0.5`.
#'
#' caret also computes variable importance. By default it uses competing splits
#' (splits which would be runners up, but do not get chosen by the tree)
#' for rpart models (see `? varImp`). Toothed is comes out to be the
#' runner up a lot, but never gets chosen!
varImp(fit)

#' Here is the variable importance without competing splits.
varImp(fit, compete = FALSE)
dotPlot(varImp(fit, compete=FALSE))

#' __Note:__ Not all models provide a variable importance function. In this case caret might calculate varImp by itself and ignore the model (see `? varImp`)!
#'
#' ### Repeated Bootstrap Sampling
#' An alternative to CV is repeated bootstrap sampling. It will give you
#' very similar estimates.
fit <- train(type ~ ., data = Zoo, method = "rpart",
	control=rpart.control(minsplit=2),
	trControl = trainControl(method = "boot", number = 10),
	tuneLength=5)
fit

#' ### Holdout Sample
#'
#' Partition data 66%/34%. __Note:__ CV and repeated bootstrap sampling
#' is typically preferred.
inTrain <- createDataPartition(y=Zoo$type, p = .66, list=FALSE)
training <- Zoo[ inTrain,]
testing <- Zoo[-inTrain,]

#' Find best model (trying more values for tuning using `tuneLength`).
fit <- train(type ~ ., data = training, method = "rpart",
	control=rpart.control(minsplit=2),
	trControl = trainControl(method = "cv", number = 10),
	tuneLength=20)
fit

plot(fit)

#' Use the best model on the test data
fit$finalModel
pred <- predict(fit, newdata = testing)
head(pred)

#' Confusion matrix (incl. confidence interval) on test data
confusionMatrix(data = pred, testing$type)

#'
#' __Some notes__
#'
#' * Many classification algorithms and `train` in caret do not deal well
#'   with missing values.
#'   If your classification model can deal with missing values (e.g., `rpart`) then use `na.action = na.pass` when you call `train` and `predict`.
#'   Otherwise, you need to remove observations with missing values with
#'   `na.omit` or use imputation to replace the missing values before you train the model. Make sure that
#'   you still have enough observations left.
#' * Make sure that nominal variables (this includes logical variables)
#'   are coded as factors.
#' * The class variable for train in caret cannot have level names that are
#'   keywords in R (e.g., `TRUE` and `FALSE`). Rename them to, for example,
#'    "yes" and "no."
#' * Make sure that nominal variables (factors) have examples for all possible
#'   values. Some methods might have problems with variable values
#'   without examples. You can drop empty levels using `droplevels` or `factor`.
#' * Sampling in train might create a sample that does not
#'   contain examples for all values in a nominal (factor) variable. You will get
#'   an error message. This most
#'   likely happens for variables which have one very rare value. You may have to
#'   remove the variable.
#'
#' ## Model Comparison
library(caret)

#' Create fixed sampling scheme (10-folds) so we compare the different models
#' using exactly the same folds.
train <- createFolds(Zoo$type,k=10)


#' Build models
rpartFit <- train(type ~ .,  data = Zoo, method = "rpart",
	tuneLength = 10,
	trControl = trainControl(
		method = "cv", indexOut = train))

#' __Note:__ for kNN you might want to scale the data first. Logicals will
#' be used as 0-1 variables in euclidean distance calculation.
knnFit <- train(type ~ .,  data = Zoo, method = "knn",
	tuneLength = 10,
	trControl = trainControl(
		method = "cv", indexOut = train))

#' Compare accuracy
resamps <- resamples(list(
		CART = rpartFit,
		kNearestNeighbors = knnFit
		))
summary(resamps)

#' Plot the accuracy of the two models models for each resampling. If the
#' models are the same then all points will fall on the diagonal.
xyplot(resamps)
#'
#' Find out if one models is statistically better than the other (is
#' the difference in accuracy is not zero).
difs <- diff(resamps)
difs
summary(difs)
#' p-values tells you the probability of seeing an even more extreme value (difference between accuracy) given that the null hypothesis (difference = 0) is true. For a better classifier p-value should be less than .05 or 0.01. `diff` automatically applies Bonferoni correction for multiple testing. In this case, the classifiers do not perform statistically differently.
#'
#' # Feature Selection

#' Decision trees implicitly select features for splitting, but we can also
#' select features manually.
library(FSelector)
#' see: http://en.wikibooks.org/wiki/Data_Mining_Algorithms_In_R/Dimensionality_Reduction/Feature_Selection#The_Feature_Ranking_Approach
#'
#' ## Univariate Feature Importance Score
#' These scores measure how related
#' each feature is to the class variable.
#' For discrete features (as in our case), the chi-square statistic can be used
#' to derive a score.
weights <- chi.squared(type ~ ., data=Zoo)
weights

#' plot importance (ordered)
str(weights)
o <- order(weights$attr_importance)
dotchart(weights$attr_importance[o], labels = rownames(weights)[o],
  xlab = "Importance")

#' Get the 5 best features
subset <- cutoff.k(weights, 5)
subset

#' Use only the best 5 features to build a model
f <- as.simple.formula(subset, "type")
f

m <- rpart(f, data=Zoo)
rpart.plot(m, extra = 2, under = TRUE,  varlen=0, faclen=0)

#' There are many alternative ways to calculate univariate importance
#' scores (see package FSelector). Some of them (also) work for continuous
#' features.
oneR(type ~ ., data=Zoo)
gain.ratio(type ~ ., data=Zoo)
information.gain(type ~ ., data=Zoo)
# linear.correlation for continuous attributes

#' ## Feature Subset Selection
#' Often features are related and calculating importance for each feature
#' independently is not optimal. We can use greedy search heuristics. For
#' example `cfs` uses correlation/entropy with best first search.
cfs(type ~ ., data=Zoo)

#' A consistency measure can also be used with best first search.
consistency(type ~ ., data=Zoo)

#' Black-box feature selection uses an evaluator function (the black box)
#' to calculate a score to be maximized.
#' First, we define an evaluation function that builds a model given a subset
#' of features and calculates a quality score. We use here the
#' average for 5 bootstrap samples, no tuning (to be faster), and the
#' average accuracy as the score.
evaluator <- function(subset) {
  m <- train(as.simple.formula(subset, "type"), data = Zoo, method = "rpart",
    trControl = trainControl(method = "boot", number = 5), tuneLength = 0)
  results <- m$resample$Accuracy
  print(subset)
  print(mean(results))
  mean(results)
}

#' Start with all features (not the class variable)
features <- names(Zoo)[1:16]

#' There are several (greedy) search strategies available. These run
#' for a while!
#subset <- backward.search(features, evaluator)
#subset <- forward.search(features, evaluator)
#subset <- best.first.search(features, evaluator)
#subset <- hill.climbing.search(features, evaluator)
#subset

#'
#' # Using Dummy Variables for Factors
#'
#' Nominal features (factors) are often encoded as a series of 0-1 dummy variables.
#' For example, let us try to predict if an animal is a predator given the type.
#' First we use the original encoding of type as a factor with several values.

tree_predator <- rpart(predator ~ type, Zoo)
rpart.plot(tree_predator, extra = 2, under = TRUE, varlen=0, faclen=0)

#' __Note:__ Some splits use multiple values. Building the tree will become
#' very slow if a factor has many values.
#'
#' Recode type as a set of 0-1 dummy variables using `class2ind`. See also
#' `? dummyVars` in package `caret`.
library(caret)
Zoo_dummy <- as.data.frame(class2ind(Zoo$type))
Zoo_dummy$predator <- Zoo$predator
head(Zoo_dummy)

tree_predator <- rpart(predator ~ ., Zoo_dummy)
rpart.plot(tree_predator, extra = 2, under = TRUE, varlen=0, faclen=0)

#' Since we have 0-1 variables, insect >= 0.5 yes means that the insect dummy
#' variable has a value of 1 (and not 0) and therefore it is an insect.
#'
#' Using `caret` on the orginal factor encoding automatically translates factors
#' (here type) into 0-1 dummy variables. The reason is that some models cannot
#' directly use factors.
fit <- train(predator ~ type, Zoo, method = "rpart")
rpart.plot(fit$finalModel, extra = 2, under = TRUE, varlen=0, faclen=0)


