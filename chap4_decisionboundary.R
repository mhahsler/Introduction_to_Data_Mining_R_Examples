#' ---
#' title: "Additional R Code for Chapter 4 of Introduction to Data Mining: Classification: Comparing Decision Boundaries of Different Classifiers"
#' author: "Michael Hahsler"
#' output:
#'  html_document:
#'    toc: true
#' ---

#' This code covers chapter 4 of _"Introduction to Data Mining"_
#' by Pang-Ning Tan, Michael Steinbach and Vipin Kumar.
#'
#' ![CC](https://i.creativecommons.org/l/by/4.0/88x31.png)
#' This work is licensed under the
#' [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/). For questions please contact
#' [Michael Hahsler](http://michael.hahsler.net).
#'

#' # Decision Boundaries
#' Classifiers create decision boundaries to discriminate between classes.
#' Different classifiers are able to create different shapes of decision
#' boundaries (e.g., some are strictly linear) and thus some classifiers
#' may perform better for certain datasets. This page visualizes the decision
#' boundaries found by several popular classification methods.
#'
#' The following plot adds the decision boundary by evaluating the classifier
#' at evenly spaced grid points. Note that low resolution
#' (to make evaluation faster) will make
#' the decision boundary look like it has small steps even if it is a
#' (straight) line.

library(scales)
library(tidyverse)
library(ggplot2)

decisionplot <- function(model, x, cl = NULL, predict_type = "class",
  resolution = 100) {

  if(!is.null(cl)) cl <- x[ , cl] else cl <- 1
  k <- length(unique(cl))

  # make grid
  r <- sapply(x[, 1:2], range, na.rm = TRUE)
  xs <- seq(r[1,1], r[2,1], length.out = resolution)
  ys <- seq(r[1,2], r[2,2], length.out = resolution)
  g <- cbind(rep(xs, each = resolution), rep(ys, time = resolution))
  colnames(g) <- colnames(r)
  g <- as_tibble(g)

  ### guess how to get class labels from predict
  ### (unfortunately not very consistent between models)
  p <- predict(model, g, type = predict_type)
  if(is.list(p)) p <- p$class
  p <- as.factor(p)

  g <- g %>% add_column(p)

  ggplot(g, mapping = aes_string(
    x = colnames(g)[1],
    y = colnames(g)[2])) +
    geom_tile(mapping = aes(fill = p)) +
    geom_point(data = x, mapping =  aes_string(
      x = colnames(x)[1],
      y = colnames(x)[2],
      shape = colnames(x)[3]), alpha = .5)
}

#' # Iris Dataset
#'
#' For easier visualization, we use on two dimensions of the Iris dataset.

set.seed(1000)
data(iris)
iris <- as_tibble(iris)

# Three classes (MASS also has a select function)
x <- iris %>% dplyr::select(Sepal.Length, Sepal.Width, Species)
x

ggplot(x, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) + geom_point()

#' ## K-Nearest Neighbors Classifier

library(caret)
model <- x %>% knn3(Species ~ ., data = ., k = 1)
decisionplot(model, x, cl = "Species") + labs(title = "kNN (1 neighbor)")

model <- x %>% knn3(Species ~ ., data = ., k = 10)
decisionplot(model, x, cl = "Species") + labs(title = "kNN (10 neighbor)")

#' ## Naive Bayes Classifier

library(e1071)
model <- x %>% naiveBayes(Species ~ ., data = .)
decisionplot(model, x, cl = "Species") + labs(title = "naive Bayes")

#' ## Linear Discriminant Analysis

library(MASS)
model <- x %>% lda(Species ~ ., data = .)
decisionplot(model, x, cl = "Species") + labs(title = "LDA")

#' ## Multinomial Logistic Regression (implemented in nnet)
#'
#' Multinomial logistic regression is an extension of logistic regression to problems with more than two classes.
#'
library(nnet)
model <- x %>% multinom(Species ~., data = .)
decisionplot(model, x, cl = "Species") + labs(titel = "Multinomial Logistic Regression")


#' ## Decision Trees

library("rpart")
model <- x %>% rpart(Species ~ ., data = .)
decisionplot(model, x, cl = "Species") + labs(title = "CART")

model <- x %>% rpart(Species ~ ., data = .,
  control = rpart.control(cp = 0.001, minsplit = 1))
decisionplot(model, x, cl = "Species") + labs(title = "CART (overfitting)")

library(C50)
model <- x %>% C5.0(Species ~ ., data = .)
decisionplot(model, x, cl = "Species") + labs(title = "C5.0")

library(randomForest)
model <- x %>% randomForest(Species ~ ., data = .)
decisionplot(model, x, cl = "Species") + labs(title = "Random Forest")

#' ## SVM

library(e1071)
model <- x %>% svm(Species ~ ., data = ., kernel = "linear")
decisionplot(model, x, cl = "Species") + labs(title = "SVM (linear kernel)")

model <- x %>% svm(Species ~ ., data = ., kernel = "radial")
decisionplot(model, x, cl = "Species") + labs(title = "SVM (radial kernel)")

model <- x %>% svm(Species ~ ., data = ., kernel = "polynomial")
decisionplot(model, x, cl = "Species") + labs(title = "SVM (polynomial kernel)")

model <- x %>% svm(Species ~ ., data = ., kernel = "sigmoid")
decisionplot(model, x, cl = "Species") + labs(title = "SVM (sigmoid kernel)")

#' ## Single Layer Feed-forward Neural Networks

library(nnet)
model <-x %>% nnet(Species ~ ., data = ., size = 1, maxit = 1000, trace = FALSE)
decisionplot(model, x, cl = "Species") + labs(title = "NN (1 neuron)")

model <-x %>% nnet(Species ~ ., data = ., size = 2, maxit = 1000, trace = FALSE)
decisionplot(model, x, cl = "Species") + labs(title = "NN (2 neurons)")

model <-x %>% nnet(Species ~ ., data = ., size = 4, maxit = 1000, trace = FALSE)
decisionplot(model, x, cl = "Species") + labs(title = "NN (4 neurons)")

model <-x %>% nnet(Species ~ ., data = ., size = 10, maxit = 1000, trace = FALSE)
decisionplot(model, x, cl = "Species") + labs(title = "NN (10 neurons)")

#' ## Deep Learning with keras

library(keras)

#' redefine predict so it works with decision plot
predict.keras.engine.training.Model <- function(object, newdata, ...)
  cl <- predict_classes(object, as.matrix(newdata))

#' Choices are the activation function, number of layers, number of units per layer and the optimizer.
#' A L2 regularizer is used for the dense layer weights to reduce overfitting. The output is a
#' categorical class value, therefore the output layer uses the softmax activation function,
#' the loss is categorical crossentropy, and the metric is accuracy.

model <- keras_model_sequential() %>%
  layer_dense(units = 10, activation = 'relu', input_shape = c(2),
    kernel_regularizer=regularizer_l2(l=0.01)) %>%
  layer_dense(units = 4, activation = 'softmax') %>%
  compile(loss = 'categorical_crossentropy', optimizer = 'adam', metrics = 'accuracy')

history <- model %>% fit(
  as.matrix(x[,1:2]),
  x %>% pull(3) %>% as.integer %>% to_categorical(),
  epochs = 100,
  batch_size = 10
)

history

decisionplot(model, x, cl = "Species") + labs(title = "keras (relu activation)")


model <- keras_model_sequential() %>%
  layer_dense(units = 10, activation = 'tanh', input_shape = c(2),
    kernel_regularizer = regularizer_l2(l = 0.01)) %>%
  layer_dense(units = 4, activation = 'softmax') %>%
  compile(loss = 'categorical_crossentropy', optimizer = 'adam', metrics = 'accuracy')

history <- model %>% fit(
  as.matrix(x[,1:2]),
  x %>% pull(3) %>% as.integer %>% to_categorical(),
  epochs = 100,
  batch_size = 10
)

history

decisionplot(model, x, cl = "Species") + labs(title = "keras (tanh activation)")

#' # Circle Dataset
#'
#' This set is not linearly separable!
set.seed(1000)

library(mlbench)
x <- mlbench.circle(500)
#x <- mlbench.cassini(500)
#x <- mlbench.spirals(500, sd = .1)
#x <- mlbench.smiley(500)
x <- cbind(as.data.frame(x$x), factor(x$classes))
colnames(x) <- c("x", "y", "class")
x <- as_tibble(x)
x

ggplot(x, aes(x = x, y = y, color = class)) + geom_point()

#' ## K-Nearest Neighbors Classifier

library(caret)
model <- x %>% knn3(class ~ ., data = ., k = 1)
decisionplot(model, x, cl = "class") + labs(title = "kNN (1 neighbor)")

model <- x %>% knn3(class ~ ., data = ., k = 10)
decisionplot(model, x, cl = "class") + labs(title = "kNN (10 neighbor)")

#' ## Naive Bayes Classifier

library(e1071)
model <- x %>% naiveBayes(class ~ ., data = .)
decisionplot(model, x, cl = "class") + labs(title = "naive Bayes")

#' ## Linear Discriminant Analysis

library(MASS)
model <- x %>% lda(class ~ ., data = .)
decisionplot(model, x, cl = "class") + labs(title = "LDA")

#' ## Multinomial Logistic Regression (implemented in nnet)
#'
#' Multinomial logistic regression is an extension of logistic regression to problems with more than two classes.
#'
library(nnet)
model <- x %>% multinom(class ~., data = .)
decisionplot(model, x, cl = "class") + labs(titel = "Multinomial Logistic Regression")


#' ## Decision Trees

library("rpart")
model <- x %>% rpart(class ~ ., data = .)
decisionplot(model, x, cl = "class") + labs(title = "CART")

model <- x %>% rpart(class ~ ., data = .,
  control = rpart.control(cp = 0.001, minsplit = 1))
decisionplot(model, x, cl = "class") + labs(title = "CART (overfitting)")

library(C50)
model <- x %>% C5.0(class ~ ., data = .)
decisionplot(model, x, cl = "class") + labs(title = "C5.0")

library(randomForest)
model <- x %>% randomForest(class ~ ., data = .)
decisionplot(model, x, cl = "class") + labs(title = "Random Forest")

#' ## SVM

library(e1071)
model <- x %>% svm(class ~ ., data = ., kernel = "linear")
decisionplot(model, x, cl = "class") + labs(title = "SVM (linear kernel)")

model <- x %>% svm(class ~ ., data = ., kernel = "radial")
decisionplot(model, x, cl = "class") + labs(title = "SVM (radial kernel)")

model <- x %>% svm(class ~ ., data = ., kernel = "polynomial")
decisionplot(model, x, cl = "class") + labs(title = "SVM (polynomial kernel)")

model <- x %>% svm(class ~ ., data = ., kernel = "sigmoid")
decisionplot(model, x, cl = "class") + labs(title = "SVM (sigmoid kernel)")

#' ## Single Layer Feed-forward Neural Networks

library(nnet)
model <-x %>% nnet(class ~ ., data = ., size = 1, maxit = 1000, trace = FALSE)
decisionplot(model, x, cl = "class") + labs(title = "NN (1 neuron)")

model <-x %>% nnet(class ~ ., data = ., size = 2, maxit = 1000, trace = FALSE)
decisionplot(model, x, cl = "class") + labs(title = "NN (2 neurons)")

model <-x %>% nnet(class ~ ., data = ., size = 4, maxit = 1000, trace = FALSE)
decisionplot(model, x, cl = "class") + labs(title = "NN (4 neurons)")

model <-x %>% nnet(class ~ ., data = ., size = 10, maxit = 1000, trace = FALSE)
decisionplot(model, x, cl = "class") + labs(title = "NN (10 neurons)")

#' ## Deep Learning with keras

library(keras)

#' redefine predict so it works with decision plot
predict.keras.engine.training.Model <- function(object, newdata, ...)
  cl <- predict_classes(object, as.matrix(newdata))

#' Choices are the activation function, number of layers, number of units per layer and the optimizer.
#' A L2 regularizer is used for the dense layer weights to reduce overfitting. The output is a
#' categorical class value, therefore the output layer uses the softmax activation function,
#' the loss is categorical crossentropy, and the metric is accuracy.

model <- keras_model_sequential() %>%
  layer_dense(units = 10, activation = 'relu', input_shape = c(2),
    kernel_regularizer=regularizer_l2(l = 0.0001)) %>%
  layer_dense(units = 3, activation = 'softmax') %>%
  compile(loss = 'categorical_crossentropy', optimizer = 'adam', metrics = 'accuracy')

history <- model %>% fit(
  as.matrix(x[,1:2]),
  x %>% pull(3) %>% as.integer %>% to_categorical(),
  epochs = 100,
  batch_size = 10
)

history

decisionplot(model, x, cl = "class") + labs(title = "keras (relu activation)")


model <- keras_model_sequential() %>%
  layer_dense(units = 10, activation = 'tanh', input_shape = c(2),
    kernel_regularizer = regularizer_l2(l = 0.0001)) %>%
  layer_dense(units = 3, activation = 'softmax') %>%
  compile(loss = 'categorical_crossentropy', optimizer = 'adam', metrics = 'accuracy')

history <- model %>% fit(
  as.matrix(x[,1:2]),
  x %>% pull(3) %>% as.integer %>% to_categorical(),
  epochs = 100,
  batch_size = 10
)

history

decisionplot(model, x, cl = "class") + labs(title = "keras (tanh activation)")

