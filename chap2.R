#' ---
#' title: "R Code for Chapter 2 of Introduction to Data Mining: Sampling, PCA, distances, correlation and density"
#' author: "Michael Hahsler"
#' output:
#'  html_document:
#'    toc: true
#' ---

#' This code covers chapter 2 of _"Introduction to Data Mining"_
#' by Pang-Ning Tan, Michael Steinbach and Vipin Kumar.
#' __See [table of contents](https://github.com/mhahsler/Introduction_to_Data_Mining_R_Examples#readme) for code examples for other chapters.__
#'
#' ![CC](https://i.creativecommons.org/l/by/4.0/88x31.png)
#' This work is licensed under the
#' [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/). For questions please contact
#' [Michael Hahsler](http://michael.hahsler.net).
#'


#' # Preparation
#' Load the iris data set (set of records as a data.frame)
data(iris)
head(iris)


#' # Data Quality
#' Inspect data (plot for data.frames actually uses pairs plot). Possibly
#' you can see noise and ouliers.
plot(iris, col=iris$Species)

#' Get summary statistics for each column (outliers, missing values)
summary(iris)

#' Are there duplicate entries?
i <- duplicated(iris)
i
#' Which object is a duplicate?
which(i)
iris[i,]

#' See also `? unique` and `? complete.cases`: Often you will do something
#' like:
clean.data <- unique(iris[complete.cases(iris),])
summary(clean.data)
#' Note that one case (non-unique) is gone. All cases with missing
#' values will also have been removed.
#'
#' # Aggregation
#' Aggregate by species (using mean or median)
aggregate(. ~ Species, data = iris, FUN = mean)
aggregate(. ~ Species, data = iris, FUN = median)

#' Uses the formula interface `. ~ Species` means all
#'  (`.`) depending on feature `Species`.
#'
#' # Sampling
#' ## Random sampling

id <- sample(1:nrow(iris), 20)
id
s <- iris[id,]
plot(s, col=s$Species)

#' ## Stratified sampling
#'
#' You need to install the package sampling with:
#' install.packages("sampling")

library(sampling)
id2 <- strata(iris, stratanames="Species", size=c(5,5,5), method="srswor")
id2
s2 <- iris[id2$ID_unit,]
plot(s2, col=s2$Species)

#' # Features
#' ## Dimensionality reduction (Principal Components Analysis - PCA)

#' Look at data first
library(scatterplot3d)
scatterplot3d(iris[,1:3], color=as.integer(iris$Species))

#' Interactive 3d plots (needs package rgl)
#library(rgl)
#data(iris)
#plot3d(as.matrix(iris[,1:3]), col=as.integer(iris$Species), size=5)

#' Interactive 3d plots (needs package plotly)
#library(plotly)
#data(iris)
#plot_ly(iris, x = ~Sepal.Length, y = ~Petal.Length, z = ~Sepal.Width,
#  size = ~Petal.Width, color = ~Species, type="scatter3d",
# mode="markers")

#' Calculate the principal components
pc <- prcomp(as.matrix(iris[,1:4]))

#' How important is each principal component?
plot(pc)

#' Inspect the raw object (display *str*ucture)
str(pc)
plot(pc$x, col=iris$Species) # plot the first 2 principal components

#' Plot the projected data and add the original dimensions as arrows
biplot(pc, col = c("grey", "red"))

#' ## Feature selection
#'
#' We will talk about feature selection when we discuss classification models.
#'
#' ## Discretrize features

plot(iris$Petal.Width, 1:150, ylab="index")
#' A histogram is a better visualization for the distribution of a single
#' variable.
hist(iris$Petal.Width)

#' Equal interval width
cut(iris$Sepal.Width, breaks=3)

#' Other methods (equal frequency, k-means clustering, etc.)
library(arules)
discretize(iris$Petal.Width, method="interval", categories=3)
discretize(iris$Petal.Width, method="frequency", categories=3)
discretize(iris$Petal.Width, method="cluster", categories=3)

hist(iris$Petal.Width,
  main = "Discretization: interval", sub = "Blue lines are boundaries")
abline(v=discretize(iris$Petal.Width, method="interval",
  categories=3,onlycuts=TRUE), col="blue")

hist(iris$Petal.Width,
  main = "Discretization: frequency", sub = "Blue lines are boundaries")
abline(v=discretize(iris$Petal.Width, method="frequency",
  categories=3,onlycuts=TRUE), col="blue")

hist(iris$Petal.Width,
  main = "Discretization: cluster", sub = "Blue lines are boundaries")
abline(v=discretize(iris$Petal.Width, method="cluster",
  categories=3,onlycuts=TRUE), col="blue")

#' ## Standardize data (Z-score)
#'
#' Standardize the scale of features to make them comparable. For each
#' column the mean is subtracted (centering) and it is divided by the
#' standard deviation (scaling). Now most values should be in [-3,3].
iris.scaled <- scale(iris[1:4])
head(iris.scaled)
summary(iris.scaled)

#' # Proximities: Similarities and distances
#'
#' __Note:__ R actually only uses dissimilarities/distances.
#'
#' ## Minkovsky distances
iris.scaled[1:5,]

#' Calculate distances matrices between the first 5 flowers (use only the 4 numeric columns).
dist(iris.scaled[1:5,], method="euclidean")
dist(iris.scaled[1:5,], method="manhattan")
dist(iris.scaled[1:5,], method="maximum")

#' __Note:__ Don't forget to scale the data if the ranges are very different!
#'
#' ## Distances for binary data (Jaccard and Hamming)
b <- rbind(
  c(0,0,0,1,1,1,1,0,0,1),
  c(0,0,1,1,1,0,0,1,0,0)
  )
b

#' ### Jaccard index
#'
#' Jaccard index is a similarity measure so R reports 1-Jaccard
dist(b, method="binary")
#' ### Hamming distance
#'
#' Hamming distance is the number of mis-matches (equivalent to
#' Manhattan distance on 0-1 data and also the squared Euclidean distance).
dist(b, method="manhattan")

dist(b, method = "euclidean")^2

#' ## Distances for mixed data

#' ### Gower's distance
#'
#' Works with mixed data
data <- data.frame(
  height= c(      160,    185,    170),
  weight= c(       52,     90,     75),
  sex=    c( "female", "male", "male")
)
data

library(proxy)
d_Gower <- dist(data, method="Gower")
d_Gower
#' __Note:__ Gower's distance automatically scales, so no need to scale
#' the data first.

#'
#' ### Using Euclidean distance with mixed data
#'
#' Sometimes methods (e.g., k-means) only can use Euclidean distance. In this
#' case, nominal features can be converted into 0-1 dummy variables. Euclidean
#' distance on these will result in a usable distance measure.
#'
#' Create dummy variables
library(caret)
data_dummy <- predict(dummyVars(~., data), data)
data_dummy

#' Since sex has now two columns, we need to weight them by 1/2 after scaling.
weight <- matrix(c(1,1,1/2,1/2), ncol = 4, nrow = nrow(data_dummy), byrow = TRUE)
data_dummy_scaled <- scale(data_dummy) * weight

d_dummy <- dist(data_dummy_scaled)
d_dummy

#' Distance is (mostly) consistent with Gower's distance (other than that
#' Gower's distance is scaled between 0 and 1).
plot(d_dummy, d_Gower, xlab = "Euclidean w/dummy", ylab = "Gower")

#' ## Additional proximity measures available in package proxy
library(proxy)
names(pr_DB$get_entries())


#' # Relationship between features

#' ## Correlation (for ratio/interval scaled features)

#' Pearson correlation between features (columns)
cor(iris[,1:4])

plot(iris$Petal.Length, iris$Petal.Width)
cor(iris$Petal.Length, iris$Petal.Width)
cor.test(iris$Petal.Length, iris$Petal.Width)

plot(iris$Sepal.Length, iris$Sepal.Width)
cor(iris$Sepal.Length, iris$Sepal.Width)
cor.test(iris$Sepal.Length, iris$Sepal.Width)

#' Correlation between objects (transpose matrix first)
cc <- cor(t(iris[,1:4]))
dim(cc)
cc[1:10,1:10]

library("seriation") # for pimage
pimage(cc, main = "Correlation between objects")

#' Convert correlations into a dissimilarities
d <- as.dist(1-abs(cc))
pimage(d, main = "Dissimilaries between objects")

#' ## Rank correlation (for ordinal features)
#' convert to ordinal variables with cut (see ? cut) into
#' ordered factors with three levels
iris_ord <- data.frame(
  cut(iris[,1], 3, labels=c("short", "medium", "long"), ordered=T),
  cut(iris[,2], 3, labels=c("short", "medium", "long"), ordered=T),
  cut(iris[,3], 3, labels=c("short", "medium", "long"), ordered=T),
  cut(iris[,4], 3, labels=c("short", "medium", "long"), ordered=T),
  iris[,5])
colnames(iris_ord) <- colnames(iris)
summary(iris_ord)
head(iris_ord$Sepal.Length)

#' Kendall's tau rank correlation coefficient
cor(sapply(iris_ord[,1:4], xtfrm), method="kendall")
#' Spearman's rho
cor(sapply(iris_ord[,1:4], xtfrm), method="spearman")
#' __Note:__ unfortunately we have to transform the ordered factors
#' into numbers representing the order with xtfrm first.
#'
#' Compare to the Pearson correlation on the original data
cor(iris[,1:4])

#' ## Relationship between nominal and ordinal features
#' Is sepal length and species related? Use cross tabulation
tbl <- table(Sepal.Length=iris_ord$Sepal.Length, iris_ord$Species)
tbl

#' Test of Independence: Pearson's chi-squared test is performed with the null hypothesis that the joint distribution of the cell counts in a 2-dimensional contingency table is the product of the row and column marginals. (h0 is independence)
chisq.test(tbl)

#' Using xtabs instead
x <- xtabs(~Sepal.Length + Species, data=iris_ord)
x
summary(x)

#' Groupwise averages
aggregate(Sepal.Length ~ Species, data=iris, FUN = mean)
aggregate(Sepal.Width ~ Species, data=iris, FUN = mean)

#' # Density estimation
#'
#' Just plotting the data is not very helpful
plot(iris$Petal.Length, jitter(rep(1, nrow(iris))), ylab ="", yaxt = "n")

#' Histograms work better
hist(iris$Petal.Length)
rug(jitter(iris$Petal.Length, factor = 10))
#' We add jitter to the rug to prevent overplotting

#'
#' We can also add a kernel density estimate KDE (red line)
hist(iris$Petal.Length, freq=FALSE)
rug(jitter(iris$Petal.Length, factor = 10))
lines(density(iris$Petal.Length), col="red", lwd = 2)

#' Plot 2d kernel density estimate
library(MASS)
dens <- kde2d(iris$Sepal.Length, iris$Sepal.Width, n=100)

image(dens,
	xlab="Sepal.Length", ylab="Sepal.Width")
contour(dens, add=TRUE)
points(jitter(iris$Sepal.Length, 2), jitter(iris$Sepal.Width, 2),
  cex=.7, pch="+")

#' Use a 3d plot instead
persp(dens, xlab="Sepal.Length", ylab="Sepal.Width", zlab="density",
  shade=.5)

