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

#' ## Split into features (X) and class variable (y)
X <- Zoo %>% select(-type) %>% as.matrix
y <- Zoo %>% pull(type)


#' ## Split data in training and test data
ind <- sample(nrow(Zoo), floor(nrow(Zoo)*0.8))

X_train <- X[ind,]
X_test <- X[-ind,]
y_train <- y[ind]
y_test <- y[-ind]

#' ## One-hot encode the class variable
#'
#' __Note:__ needs an integer with the first class being 0 and not 1
y_train <- to_categorical(as.integer(y_train) - 1L)
head(y_train)

#' ## Scale features
#'
#' Scale X_train and then use the same scaling for X_test. These separate steps
#' make sure that the test data does not influence the scaling of the training data.
#' I use here R's scale to convert the data to z-scores. Another
#' popular normalization for deep learning is min-max scaling to the range $[0,1]$. If
#' you have nominal features (factor), then you need to use kera's `to_categorical()`
#' function to create a one-hot encoding.

X_train <- scale(X_train)
X_test <-  scale(X_test, center = attr(X_train, "scaled:center") ,
                         scale = attr(X_train, "scaled:scale"))


#' # Construct the model structure
model <- keras_model_sequential()

model %>%
  layer_dense(units = 16, activation = 'relu', input_shape = c(ncol(X_train)),
    kernel_regularizer=regularizer_l2(l = 0.001)) %>%
  layer_dropout(.1) %>%
  layer_dense(units = 8, activation = 'relu',
    kernel_regularizer=regularizer_l2(l = 0.001)) %>%
  layer_dense(units = ncol(y_train), activation = 'softmax')
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
#' A dropout layer (randomly sets input units to 0 with a frequency of rate at each step during training time) and L2 regularizer (penalty for the dense layer weights) are used to reduce overfitting.
#' The output is a
#' categorical class value, therefore the output layer uses the softmax activation function,
#' the loss is categorical cross-entropy, and the metric is accuracy.
#'

#' # Fit the model on the training data
#'
#' __Note:__ the chart shows training loss and training accuracy.
history <- model %>% fit(
  X_train, y_train,
  epochs = 100,
  batch_size = 2^3
)

history
plot(history)
#'
#' # Make predictions on the test set
pred <- model %>% predict_classes(X_test, batch_size = 2^7)

#' __Note:__ predictions from keras starts with index 0 not 1

library(caret)
confusionMatrix(
  data = factor(pred+1L, levels = 1:length(levels(Zoo$type)), labels = levels(Zoo$type)),
  ref = y_test
)
