#' ---
#' title: "Additional R Code for Chapter 4 of Introduction to Data Mining: Classification: Deep Learning with Keras"
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

#' Show fewer digits
options(digits=3)

#' # Install keras and tensorflow

#' R> install.packages("keras")
#'
#' R> library(keras)
#'
#' R> install_tensorflow()
#'
#' R> install_keras()
#'

library(keras)
library(tidyverse)

#' # Load and prepare the data set
data(Zoo, package = "mlbench")
Zoo <- as_tibble(Zoo)
Zoo

Zoo_predictors <- Zoo %>% select(-type)
Zoo_class <- Zoo %>% pull(type)

#' Create a matrix and normalize the data (using kera's `normalize()` function). If you have nominal variables
#' (factor), then you need to use kera's `to_categorical()` function to create one-hot encoding.
Zoo_predictors <- Zoo_predictors %>% as.matrix() %>% normalize()
head(Zoo_predictors)

#' One-hot encode the class variable
#'
#' __Note:__ needs an integer with the first class being 0 and not 1
Zoo_class <- to_categorical(as.integer(Zoo_class) - 1L)
head(Zoo_class)

#' # Construct the model structure
model <- keras_model_sequential()

model %>%
  layer_dense(units = 16, activation = 'relu', input_shape = c(ncol(Zoo_predictors)),
    kernel_regularizer=regularizer_l2(l = 0.001)) %>%
  layer_dropout(.1) %>%
  layer_dense(units = 8, activation = 'relu',
    kernel_regularizer=regularizer_l2(l = 0.001)) %>%
  layer_dense(units = ncol(Zoo_class), activation = 'softmax')
model
#' See `? layer_dense` to learn more about creating the model structure
#'
#' Compile the model
model %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = 'adam',
  metrics = 'accuracy'
)

#' _Note:_ Choices are the activation function, number of layers, number of units per layer and the optimizer.
#' A dropout layer and L2 regularizer is used for the dense layer weights to reduce overfitting.
#' The output is a
#' categorical class value, therefore the output layer uses the softmax activation function,
#' the loss is categorical crossentropy, and the metric is accuracy.
#'

#' # Fit the model
#'
#' Uses 20% of the data for validation

train <- sample(c(TRUE, FALSE), size = nrow(Zoo), prob = c(0.8, 0.2), replace = TRUE)

history <- model %>% fit(
  Zoo_predictors[train,],
  Zoo_class[train,],
  validation_data = list(Zoo_predictors[!train, ], Zoo_class[!train, ]),
  epochs = 200,
  batch_size = 2^3
)

history

#' `val_acc` is the accuracy on the test (validation) set.

plot(history)
#'
#' # Make predictions on the test set
#'
#' __Note:__ classes starts with index 0 not 1
#'
classes <- model %>% predict_classes(Zoo_predictors[!train,], batch_size = 2^7)

library(caret)
confusionMatrix(
  data = factor(classes+1L, levels = 1:length(levels(Zoo$type)), labels = levels(Zoo$type)),
  ref = Zoo$type[!train]
  )

