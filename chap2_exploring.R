#' ---
#' title: "R Code for Chapter 2 of Introduction to Data Mining: Data (Exploring Data)"
#' author: "Michael Hahsler"
#' output:
#'  html_document:
#'    toc: true
#' ---

#' This is additional code related to chapter 2 of _"Introduction to Data Mining"_
#' by Pang-Ning Tan, Michael Steinbach and Vipin Kumar.
#' __See [table of contents](https://github.com/mhahsler/Introduction_to_Data_Mining_R_Examples#readme) for code examples for other chapters.__
#'
#' ![CC](https://i.creativecommons.org/l/by/4.0/88x31.png)
#' This work is licensed under the
#' [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/). For questions please contact
#' [Michael Hahsler](http://michael.hahsler.net).
#'


#' Load the iris data set
data(iris)
head(iris)

#' # Basic statistics
#'
#' Get summary statistics
summary(iris)

#' Get mean and standard deviation for sepal length
mean(iris$Sepal.Length)
sd(iris$Sepal.Length)

#' Ignor missing values (Note: this data does not contain any, but this is
#' what you would do)
mean(iris$Sepal.Length, na.rm = TRUE)

#' Robust mean (trim 10% of observations from each end of the distribution)
mean(iris$Sepal.Length, trim = .1)

#' Apply mean, sd and median to columns (MARGIN=2)
apply(iris[1:4], MARGIN=2, mean)
apply(iris[1:4], MARGIN=2, median)
apply(iris[1:4], MARGIN=2, sd)
apply(iris[1:4], MARGIN=2, var)
apply(iris[1:4], MARGIN=2, min)
apply(iris[1:4], MARGIN=2, max)


#' Define your own statistic: E.g., MAD (median absolute deviation)
mad <- function(x) median(abs(x-mean(x)))
apply(iris[1:4], MARGIN=2, mad)

#' # Tabulate data

#' Discretize the data first since there are too many values (cut divides the range by breaks, see package discretization for other methods)
iris_discrete <- data.frame(
	Sepal.Length= cut(iris$Sepal.Length, breaks=3,
		labels=c("small", "medium", "large"), ordered=TRUE),
	Sepal.Width= cut(iris$Sepal.Width, breaks=3,
		labels=c("small", "medium", "large"), ordered=TRUE),
	Petal.Length= cut(iris$Petal.Length, breaks=3,
		labels=c("small", "medium", "large"), ordered=TRUE),
	Petal.Width= cut(iris$Petal.Width, breaks=3,
		labels=c("small", "medium", "large"), ordered=TRUE),
	Species = iris$Species
	)

head(iris_discrete)
summary(iris_discrete)

#' Create some tables
table(iris_discrete$Sepal.Length, iris_discrete$Sepal.Width)
table(iris_discrete$Petal.Length, iris_discrete$Petal.Width)
table(iris_discrete$Petal.Length, iris_discrete$Species)

#table(iris_discrete)

#' Test if the two features are independent given the counts in the
#' contingency table (H0: independence)
#'
#' p-value: the probability of seeing a more extreme value of the test
#' statistic under the assumption that H0 is correct. Low p-values (typically
#' less than .05 or .01) indicate that H0 should be rejected.
tbl <- table(iris_discrete$Sepal.Length, iris_discrete$Sepal.Width)
tbl
chisq.test(tbl)

#' Fisher's exact test is  better for small counts (cells with counts <5)
fisher.test(tbl)

#' Plot the distribution for a discrete variable
table(iris_discrete$Sepal.Length)
barplot(table(iris_discrete$Sepal.Length))

#' # Percentiles
apply(iris[1:4], MARGIN=2, quantile)

#' Interquartile range
quantile(iris$Petal.Length)
quantile(iris$Petal.Length)[4] - quantile(iris$Petal.Length)[2]


#' # Visualizations

#' ### Histogram
#'
#' Show the distribution of a single numeric variable
hist(iris$Petal.Width)
hist(iris$Petal.Width, breaks=20, col="grey")

#' ### Scatter plot
#'
#' Show the relationship between two numeric variables
plot(x=iris$Petal.Length, y=iris$Petal.Width, col=iris$Species)

#' ### Scatter plot matrix
#'
#' Show the relationship between several numeric variables
pairs(iris, col=iris$Species)

#' Alternative scatter plot matrix
library("GGally")
ggpairs(iris,  ggplot2::aes(colour=Species))

#' ### Boxplot
#'

#' Compare the distribution of several continuous variables
boxplot(iris[,1:4])

#' Compare the distribution of a single continuous variables grouped by a nominal variable
boxplot(Sepal.Length ~ Species, data = iris,
  ylab = "Sepal Length", ylim = c(0,8))

#' Group-wise averages
aggregate(Sepal.Length ~ Species, data=iris, FUN = mean)
aggregate(Sepal.Width ~ Species, data=iris, FUN = mean)


#' ### ECDF: Empirical Cumulative Distribution Function
e <- ecdf(iris$Petal.Width)
hist(iris$Petal.Width, breaks=20, freq=FALSE, col="gray")
lines(e, col="red", lwd=2)

#' ### Data matrix visualization
iris_matrix <- as.matrix(iris[,1:4])
image(iris_matrix)

library(seriation) ## for pimage
pimage(iris_matrix, ylab="Object (ordered by species)",
  main="Original values", colorkey=TRUE)

#' values smaller than the average are blue and larger ones are red
iris_scaled <- scale(iris_matrix)
pimage(iris_scaled,
  ylab="Object (ordered by species)",
	main="Standard deviations from the feature mean")

#' use reordering of features and objects
pimage(iris_scaled, order = seriate(iris_scaled),
  main="Standard deviations (reordered)")

#' ### Correlation matrix
#'
#' Calculate and visualize the correlation between features
cm1 <- cor(iris_matrix)
cm1

library(seriation) ## for pimage and hmap
pimage(cm1)
hmap(cm1, margin = c(7,7), cexRow = 1, cexCol = 1)

library(corrplot)
corrplot(cm1, method="ellipse")
corrplot(cm1, method=c("ellipse"), order="FPC")

#' Test if correlation is significantly different from 0
cor.test(iris$Sepal.Length, iris$Sepal.Width)
cor.test(iris$Petal.Length, iris$Petal.Width) #this one is significant

#' Correlation between objects
cm2 <- cor(t(iris_matrix))
pimage(cm2,
	main="Correlation matrix", xlab="Objects", ylab="Objects",
  zlim = c(-1,1),col = bluered(100))

#' ### Parallel coordinates plot
library(MASS)
parcoord(iris[,1:4], col=iris$Species)

#' Reorder with placing correlated features next to each other
library(seriation)
o <- seriate(as.dist(1-cor(iris[,1:4])), method="BBURCG")
get_order(o)
parcoord(iris[,get_order(o)], col=iris$Species)

#' Look at some example maps at http://rgraphgallery.blogspot.com/search/label/map
