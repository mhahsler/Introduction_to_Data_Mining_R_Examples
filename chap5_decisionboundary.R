#' ---
#' title: "R Code for Chapter 5 of Introduction to Data Mining: Classification(Comparing Decision Boundaries of Different Classifiers)"
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

decisionplot <- function(model, data, class = NULL, predict_type = "class",
  resolution = 100, showgrid = TRUE, alpha = 0.3, ...) {

  if(!is.null(class)) cl <- data[,class] else cl <- 1
  data <- data[,1:2]
  k <- length(unique(cl))

  plot(data, col = as.integer(cl)+1L, pch = as.integer(cl)+1L, ...)

  # make grid
  r <- sapply(data, range, na.rm = TRUE)
  xs <- seq(r[1,1], r[2,1], length.out = resolution)
  ys <- seq(r[1,2], r[2,2], length.out = resolution)
  g <- cbind(rep(xs, each=resolution), rep(ys, time = resolution))
  colnames(g) <- colnames(r)
  g <- as.data.frame(g)

  ### guess how to get class labels from predict
  ### (unfortunately not very consistent between models)
  p <- predict(model, g, type = predict_type)
  if(is.list(p)) p <- p$class
  p <- as.factor(p)

  if(showgrid) points(g, col = alpha(as.integer(p)+1L, alpha = alpha), pch = ".")

  z <- matrix(as.integer(p), nrow = resolution, byrow = TRUE)
  contour(xs, ys, z, add = TRUE, drawlabels = FALSE,
    lwd = 2, levels = (1:(k-1))+.5)

  invisible(z)
}

#' # Iris Dataset
#'
#' For easier visualization, we use on two dimensions of the Iris dataset.

set.seed(1000)
data(iris)

# Two class case
#x <- iris[1:100, c("Sepal.Length", "Sepal.Width", "Species")]
#x$Species <- factor(x$Species)

# Three classes
x <- iris[1:150, c("Sepal.Length", "Sepal.Width", "Species")]

# Easier to separate
#x <- iris[1:150, c("Petal.Length", "Petal.Width", "Species")]

head(x)
plot(x[,1:2], col = x[,3])

#' ## K-Nearest Neighbors Classifier

library(caret)
model <- knn3(Species ~ ., data=x, k = 1)
decisionplot(model, x, class = "Species", main = "kNN (1 neighbor)")

model <- knn3(Species ~ ., data=x, k = 10)
decisionplot(model, x, class = "Species", main = "kNN (10 neighbors)")

#' ## Naive Bayes Classifier

library(e1071)
model <- naiveBayes(Species ~ ., data=x)
decisionplot(model, x, class = "Species", main = "naive Bayes")

#' ## Linear Discriminant Analysis

library(MASS)
model <- lda(Species ~ ., data=x)
decisionplot(model, x, class = "Species", main = "LDA")

#' ## Multinomial Logistic Regression (implemented in nnet)
#'
#' Multinomial logistic regression is an extension of logistic regression to problems with more than two classes.
#'
library(nnet)
model <- multinom(Species ~., data = x)
decisionplot(model, x, class = "Species", main = "Multinomial Logistic Regression")


#' ## Decision Trees

library("rpart")
model <- rpart(Species ~ ., data=x)
decisionplot(model, x, class = "Species", main = "CART")

model <- rpart(Species ~ ., data=x,
  control = rpart.control(cp = 0.001, minsplit = 1))
decisionplot(model, x, class = "Species", main = "CART (overfitting)")

library(C50)
model <- C5.0(Species ~ ., data=x)
decisionplot(model, x, class = "Species", main = "C5.0")

library(randomForest)
model <- randomForest(Species ~ ., data=x)
decisionplot(model, x, class = "Species", main = "Random Forest")

#' ## SVM

library(e1071)
model <- svm(Species ~ ., data=x, kernel="linear")
decisionplot(model, x, class = "Species", main = "SVM (linear kernel)")

model <- svm(Species ~ ., data=x, kernel = "radial")
decisionplot(model, x, class = "Species", main = "SVM (radial kernel)")

model <- svm(Species ~ ., data=x, kernel = "polynomial")
decisionplot(model, x, class = "Species", main = "SVM (polynomial kernel)")

model <- svm(Species ~ ., data=x, kernel = "sigmoid")
decisionplot(model, x, class = "Species", main = "SVM (sigmoid kernel)")

#' ## Single Layer Feed-forward Neural Networks

library(nnet)
model <- nnet(Species ~ ., data=x, size = 1, maxit = 1000, trace = FALSE)
decisionplot(model, x, class = "Species", main = "NN (1 neuron)")

model <- nnet(Species ~ ., data=x, size = 2, maxit = 1000, trace = FALSE)
decisionplot(model, x, class = "Species", main = "NN (2 neurons)")

model <- nnet(Species ~ ., data=x, size = 4, maxit = 1000, trace = FALSE)
decisionplot(model, x, class = "Species", main = "NN (4 neurons)")

model <- nnet(Species ~ ., data=x, size = 10, maxit = 1000, trace = FALSE)
decisionplot(model, x, class = "Species", main = "NN (10 neurons)")

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
  to_categorical(as.integer(x[,3])),
  epochs = 100,
  batch_size = 10
)

history

decisionplot(model, x, class = "Species", main = "keras (relu activation)")



model <- keras_model_sequential() %>%
  layer_dense(units = 10, activation = 'tanh', input_shape = c(2),
    kernel_regularizer=regularizer_l2(l=0.01)) %>%
  layer_dense(units = 4, activation = 'softmax') %>%
  compile(loss = 'categorical_crossentropy', optimizer = 'adam', metrics = 'accuracy')

history <- model %>% fit(
  as.matrix(x[,1:2]),
  to_categorical(as.integer(x[,3])),
  epochs = 100,
  batch_size = 10
)

history

decisionplot(model, x, class = "Species", main = "keras (tanh activation)")

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

head(x)
plot(x[,1:2], col = x[,3])



#' ## K-Nearest Neighbors Classifier

library(caret)
model <- knn3(class ~ ., data=x, k = 1)
decisionplot(model, x, class = "class", main = "kNN (1 neighbor)")

model <- knn3(class ~ ., data=x, k = 10)
decisionplot(model, x, class = "class", main = "kNN (10 neighbors)")

#' ## Naive Bayes Classifier

library(e1071)
model <- naiveBayes(class ~ ., data=x)
decisionplot(model, x, class = "class", main = "naive Bayes")

#' ## Linear Discriminant Analysis

library(MASS)
model <- lda(class ~ ., data=x)
decisionplot(model, x, class = "class", main = "LDA")

#' ## Logistic Regression

model <- glm(class ~., data = x, family=binomial(link='logit'))
class(model) <- c("lr", class(model))
predict.lr <- function(object, newdata, ...)
  predict.glm(object, newdata, type = "response") > .5

decisionplot(model, x, class = "class", main = "Logistic Regression")


#' ## Decision Trees

library("rpart")
model <- rpart(class ~ ., data=x)
decisionplot(model, x, class = "class", main = "CART")

model <- rpart(class ~ ., data=x,
  control = rpart.control(cp = 0.0001, minsplit = 1))
decisionplot(model, x, class = "class", main = "CART (overfitting)")

library(C50)
model <- C5.0(class ~ ., data=x)
decisionplot(model, x, class = "class", main = "C5.0")

library(randomForest)
model <- randomForest(class ~ ., data=x)
decisionplot(model, x, class = "class", main = "Random Forest")

#' ## SVM

library(e1071)
model <- svm(class ~ ., data=x, kernel="linear")
decisionplot(model, x, class = "class", main = "SVM (linear kernel)")

model <- svm(class ~ ., data=x, kernel = "radial")
decisionplot(model, x, class = "class", main = "SVM (radial kernel)")

model <- svm(class ~ ., data=x, kernel = "polynomial")
decisionplot(model, x, class = "class", main = "SVM (polynomial kernel)")

model <- svm(class ~ ., data=x, kernel = "sigmoid")
decisionplot(model, x, class = "class", main = "SVM (sigmoid kernel)")

#' ## Single Layer Feed-forward Neural Networks

library(nnet)
model <- nnet(class ~ ., data=x, size = 1, maxit = 1000, trace = FALSE)
decisionplot(model, x, class = "class", main = "NN (1 neighbor)")

model <- nnet(class ~ ., data=x, size = 2, maxit = 1000, trace = FALSE)
decisionplot(model, x, class = "class", main = "NN (2 neighbors)")

model <- nnet(class ~ ., data=x, size = 4, maxit = 10000, trace = FALSE)
decisionplot(model, x, class = "class", main = "NN (4 neighbors)")

model <- nnet(class ~ ., data=x, size = 10, maxit = 10000, trace = FALSE)
decisionplot(model, x, class = "class", main = "NN (10 neighbors)")

#' ## Deep Learning with keras

library(keras)

#' redefine predict so it works with decision plot
predict.keras.engine.training.Model <- function(object, newdata, ...)
  cl <- predict_classes(object, as.matrix(newdata))

model <- keras_model_sequential() %>%
  layer_dense(units = 10, activation = 'relu', input_shape = c(2),
    kernel_regularizer=regularizer_l2(l=0.0001)) %>%
  layer_dense(units = 3, activation = 'softmax') %>%
  compile(loss = 'categorical_crossentropy', optimizer = 'adam', metrics = 'accuracy')

history <- model %>% fit(
  as.matrix(x[,1:2]),
  to_categorical(as.integer(x[,3])),
  epochs = 100,
  batch_size = 10
)

history

decisionplot(model, x, class = "class", main = "keras (relu activation)")



model <- keras_model_sequential() %>%
  layer_dense(units = 10, activation = 'tanh', input_shape = c(2),
    kernel_regularizer=regularizer_l2(l=0.0001)) %>%
  layer_dense(units = 3, activation = 'softmax') %>%
  compile(loss = 'categorical_crossentropy', optimizer = 'adam', metrics = 'accuracy')

history <- model %>% fit(
  as.matrix(x[,1:2]),
  to_categorical(as.integer(x[,3])),
  epochs = 100,
  batch_size = 10
)

history

decisionplot(model, x, class = "class", main = "keras (tanh activation)")
