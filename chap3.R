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

library(tidyverse)
library(ggplot2)

#' # Prepare Zoo Data Set
data(Zoo, package="mlbench")
head(Zoo)

#' Get summary statistics
#'
#' translate all the TRUE/FALSE values into factors (nominal). This is often needed for
#' building models.
Zoo <- Zoo %>%
  modify_if(is.logical, factor, levels = c(TRUE, FALSE)) %>%
  modify_if(is.character, factor)
Zoo %>% summary()

#' # A First Decision Tree
#'
#' Recursive Partitioning (similar to CART) uses the Gini index to make
#' splitting decisions and early stopping (pre-pruning).

library(rpart)

#' ## Create Tree With Default Settings (uses pre-pruning)
tree_default <- Zoo %>% rpart(type ~ ., data = .)
tree_default



#' __Notes:__
#' - `%>%` supplies the data for `rpart`. Since `data` is not the first argument of `rpart`, the syntax `data = .` is used to specify where the data in `Zoo` goes. The call is equivalent to `tree_default <- rpart(type ~ ., data = Zoo)`.
#' - The formula models the `type` variable by all other features represented by `.`. `data = .`
#'   means that the data provided by the pipe (`%>%`) will be passed to rpart as the
#'   argument `data`.
#'
#' - the class variable needs a factor (nominal) or rpart
#'   will create a regression tree instead of a decision tree. Use `as.factor()`
#'   if necessary.
#'
#' Plotting

library(rpart.plot)
rpart.plot(tree_default, extra = 2)

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
tree_full <- Zoo %>% rpart(type ~., data = ., control = rpart.control(minsplit = 2, cp = 0))
rpart.plot(tree_full, extra = 2)
tree_full

#' Training error on tree with pre-pruning
predict(tree_default, Zoo) %>% head ()

pred <- predict(tree_default, Zoo, type="class")
head(pred)

confusion_table <- with(Zoo, table(type, pred))
confusion_table

correct <- confusion_table %>% diag() %>% sum()
correct
error <- confusion_table %>% sum() - correct
error

accuracy <- correct / (correct + error)
accuracy

#' Use a function for accuracy
accuracy <- function(truth, prediction) {
    tbl <- table(truth, prediction)
    sum(diag(tbl))/sum(tbl)
}

accuracy(Zoo %>% pull(type), pred)

#' Training error of the full tree
accuracy(Zoo %>% pull(type), predict(tree_full, Zoo, type="class"))

#' Get a confusion table with more statistics (using caret)
library(caret)
confusionMatrix(data = pred, reference = Zoo %>% pull(type))

#' ## Make Predictions for New Data
#'
#' Make up my own animal: A lion with feathered wings

my_animal <- tibble(hair = TRUE, feathers = TRUE, eggs = FALSE,
  milk = TRUE, airborne = TRUE, aquatic = FALSE, predator = TRUE,
  toothed = TRUE, backbone = TRUE, breathes = TRUE, venomous = FALSE,
  fins = FALSE, legs = 4, tail = TRUE, domestic = FALSE,
  catsize = FALSE, type = NA)

#' Fix columns to be factors like in the training set.
my_animal <- my_animal %>% modify_if(is.logical, factor, levels = c(TRUE, FALSE))
my_animal

#' Make a prediction using the default tree
predict(tree_default , my_animal, type = "class")

#' # Model Evaluation
#' ## Pure R Implementation
#' ### Holdout Sample
#'
#' Use a simple split into 2/3 training and 1/3 testing data. Find the size
#' of the training set.

n_train <- floor(nrow(Zoo) * .66)
n_train

#' Randomly choose the rows of the training examples.
train_id <- sample(seq_len(nrow(Zoo)), n_train)
head(train_id)

#' Split the data
train <- Zoo %>% slice(train_id)
test <- Zoo %>% slice(-train_id) %>% select(-type)
test_type <- Zoo %>% slice(-train_id) %>% pull(type)

tree <- train %>% rpart(type ~., data = ., control = rpart.control(minsplit = 2))

#' Training error (on training data)
accuracy(train$type, predict(tree, train, type="class"))

#' Generalization error (on unseen testing data)
accuracy(test_type, predict(tree, test, type="class"))

#' ### 10-Fold Cross Validation
#'
#' suffle the data and add fold id
k <- 10

Zoo_k <- Zoo %>%
  sample_frac() %>%
  mutate(fold = rep(1:k, each = nrow(Zoo) / k)[1:nrow(Zoo)])

Zoo_k %>% pull(fold)


#' Do each fold
accs <- rep(NA, k)
for(i in seq_len(k)) {
  train <- Zoo_k %>% filter(fold != i)
  test <- Zoo_k %>% filter(fold == i)
  tree <- train %>%
      rpart(type ~., data = ., control = rpart.control(minsplit = 2))
    accs[i] <- accuracy(test %>% pull(type), predict(tree, test, type="class"))
}
accs

#' Report the average
accs %>% mean()

#' ## Caret: For Easier Model Building and Evaluation
#' see http://cran.r-project.org/web/packages/caret/vignettes/caret.pdf
#'
#' Enable multi-core using packages `foreach` and `doParallel`.
library(doParallel)
getDoParWorkers()

registerDoParallel()
getDoParWorkers()

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
fit <- Zoo %>%
  train(type ~ .,
    data = . ,
    method = "rpart",
    control = rpart.control(minsplit = 2),
    trControl = trainControl(method = "cv", number = 10),
    tuneLength = 5)
fit
#' __Note:__ Train has built 10 trees. Accuracy and kappa for each tree/test fold
#' can be obtained.
fit$resample

#' A model using the best tuning parameters
#' and using all the data is available as `fit$finalModel`.

rpart.plot(fit$finalModel, extra = 2)
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
imp <- varImp(fit, compete = FALSE)
imp
ggplot(imp)

#' __Note:__ Not all models provide a variable importance function. In this case caret might calculate varImp by itself and ignore the model (see `? varImp`)!
#'
#' ### Repeated Bootstrap Sampling
#' An alternative to CV is repeated bootstrap sampling. It will give you
#' very similar estimates.
fit <- Zoo %>% train(type ~ .,
  data = .,
  method = "rpart",
  control=rpart.control(minsplit=2),
  trControl = trainControl(method = "boot", number = 10),
  tuneLength = 5)
fit

#' ### Holdout Sample
#'
#' Partition data 66%/34%. __Note:__ CV and repeated bootstrap sampling
#' is typically preferred.
inTrain <- createDataPartition(y = Zoo$type, p = .66, list = FALSE)
training <- Zoo %>% slice(inTrain)
testing <- Zoo %>% slice(-inTrain)

#' Find best model (trying more values for tuning using `tuneLength`).
fit <- training %>% train(type ~ .,
  data = .,
  method = "rpart",
  control = rpart.control(minsplit = 2),
  trControl = trainControl(method = "cv", number = 10),
  tuneLength = 20)
fit

ggplot(fit)

#' Use the best model on the test data
fit$finalModel
pred <- predict(fit, newdata = testing)
head(pred)

#' ## Confusion Matrix and Confidence Interval for Accuracy
#'
#' Caret's `confusionMatrix()` function calculates accuracy, confidence intervals, kappa and many more evaluation metrics. Use test data.
pred <- predict(fit, newdata = testing)
confusionMatrix(data = pred, ref = testing$type)

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
train <- createFolds(Zoo$type, k = 10)

#' Build models
rpartFit <- Zoo %>% train(type ~ .,
  data = .,
  method = "rpart",
  tuneLength = 10,
  trControl = trainControl(method = "cv", indexOut = train)
  )

#' __Note:__ for kNN you might want to scale the data first. Logicals will
#' be used as 0-1 variables in euclidean distance calculation.
knnFit <- Zoo %>% train(type ~ .,
  data = .,
  method = "knn",
	tuneLength = 10,
	trControl = trainControl(method = "cv", indexOut = train)
  )

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
weights <- chi.squared(type ~ ., data = Zoo)
weights

#' plot importance (ordered)
str(weights)

ggplot(as_tibble(weights, rownames = "feature"), aes(x = attr_importance, y = reorder(feature, attr_importance))) +
  geom_bar(stat = "identity")

#' Get the 5 best features
subset <- cutoff.k(weights, 5)
subset

#' Use only the best 5 features to build a model
f <- as.simple.formula(subset, "type")
f

m <- Zoo %>% rpart(f, data = .)
rpart.plot(m, extra = 2)

#' There are many alternative ways to calculate univariate importance
#' scores (see package FSelector). Some of them (also) work for continuous
#' features.
Zoo %>% oneR(type ~ ., data = .)
Zoo %>% gain.ratio(type ~ ., data = .)
Zoo %>% information.gain(type ~ ., data = .)
# linear.correlation for continuous attributes

#' ## Feature Subset Selection
#' Often features are related and calculating importance for each feature
#' independently is not optimal. We can use greedy search heuristics. For
#' example `cfs` uses correlation/entropy with best first search.
Zoo %>% cfs(type ~ ., data = .)

#' A consistency measure can also be used with best first search.
Zoo %>% consistency(type ~ ., data = .)

#' Black-box feature selection uses an evaluator function (the black box)
#' to calculate a score to be maximized.
#' First, we define an evaluation function that builds a model given a subset
#' of features and calculates a quality score. We use here the
#' average for 5 bootstrap samples, no tuning (to be faster), and the
#' average accuracy as the score.
evaluator <- function(subset) {
  model <- Zoo %>% train(as.simple.formula(subset, "type"),
    data = ., method = "rpart",
    trControl = trainControl(method = "boot", number = 5),
    tuneLength = 0)
  results <- model$resample$Accuracy
  print(subset)
  m <- mean(results)
  print(m)
  m
}

#' Start with all features (not the class variable)
features <- Zoo %>% colnames() %>% setdiff("type")

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

tree_predator <- Zoo %>% rpart(predator ~ type, data = .)
rpart.plot(tree_predator, extra = 2)

#' __Note:__ Some splits use multiple values. Building the tree will become
#' very slow if a factor has many values.
#'
#' Recode type as a set of 0-1 dummy variables using `class2ind`. See also
#' `? dummyVars` in package `caret`.
library(caret)
Zoo_dummy <- as_tibble(class2ind(Zoo$type)) %>% mutate_all(as.factor) %>%
  add_column(predator = Zoo$predator)
Zoo_dummy

tree_predator <- Zoo_dummy %>% rpart(predator ~ ., data = .)
rpart.plot(tree_predator, extra = 2, roundint = FALSE)

#' Using `caret` on the orginal factor encoding automatically translates factors
#' (here type) into 0-1 dummy variables (e.g., `typeinsect = 0`).
#' The reason is that some models cannot
#' directly use factors.
fit <- Zoo %>% train(predator ~ type, data = ., method = "rpart")
rpart.plot(fit$finalModel, extra = 2)
