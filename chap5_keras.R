#' ---
#' title: "R Code for Chapter 5 of Introduction to Data Mining: Deep Learning with Keras"
#' author: "Michael Hahsler"
#' output:
#'  html_document:
#'    toc: true
#' ---

#' This code covers chapter 5 of _"Introduction to Data Mining"_
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

#' # Load and prepare the data set
data(Zoo, package="mlbench")
head(Zoo)

Zoo_predictors <- Zoo[,-ncol(Zoo)]
Zoo_class <- Zoo[, ncol(Zoo)]

#' Create a matrix and normalize the data (using kera's `normalize()` function). If you have nominal variables
#' (factor), then you need to use kera's `to_categorical()` function to create one-hot encoding.
Zoo_predictors <- normalize(as.matrix(Zoo_predictors))
head(Zoo_predictors)

#' One-hot encode the class variable
Zoo_class <- to_categorical(as.integer(Zoo_class))
head(Zoo_class)

#' # Construct the model structure
model <- keras_model_sequential()
model

model %>%
  layer_dense(units = 8, activation = 'relu', input_shape = c(ncol(Zoo_predictors))) %>%
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


#' # Fit the model
#'
#' Uses 20% of the data for validation

train <- sample(c(TRUE, FALSE), size = nrow(Zoo), prob = c(0.8, 0.2), replace = TRUE)

history <- model %>% fit(
  Zoo_predictors[train,],
  Zoo_class[train,],
  validation_data = list(Zoo_predictors[!train,], Zoo_class[!train,]),
  epochs = 200,
  batch_size = 5
)

history
plot(history)
#' `val_acc` is the accuracy on the test (validation) set.
#'
#' # Make predictions on the test set
#'
classes <- model %>% predict_classes(Zoo_predictors[!train,], batch_size = 128)

library(caret)
confusionMatrix(data = factor(classes, levels = 1:length(levels(Zoo$type)), labels = levels(Zoo$type)),
  ref = Zoo$type[!train])

