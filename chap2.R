#' ---
#' title: "R Code for Chapter 2 of Introduction to Data Mining: Data (Tidyverse)"
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

#' # Tidyverse
#'
#' Some of the code uses tidyverse tibbles to replace data.frames, the pipe operator `%>%` to chain
#' functions and data transformation functions like `filter()`, `arrange()`, `select()`, and
#' `mutate()` provided by the tidyverse package `dplyr`. A good overview is given in
#' the [RStudio Data Transformation Cheat Sheet](https://github.com/rstudio/cheatsheets/raw/master/data-transformation.pdf) and an introduction can be found in the
#' [Section on Data Wrangling](https://r4ds.had.co.nz/wrangle-intro.html) the free book [R for Data Science](https://r4ds.had.co.nz).
#'

library(tidyverse)
library(ggplot2)
library(GGally) # for ggpairs


#' # Preparation
#' Load the iris data set and convert the data.frame into a tibble.
data(iris)
iris <- as_tibble(iris)
iris


#' # Data Quality
#' Inspect data (produce a scatterplot matrix using `ggpairs` from package `GGally`). Possibly
#' you can see noise and ouliers.
ggpairs(iris, aes(color = Species))

#' Get summary statistics for each column (outliers, missing values)
summary(iris)

#' just the mean
iris %>% summarize_if(is.numeric, mean)

#' Often you will do something
#' like:
clean.data <- iris %>% drop_na() %>% unique()
summary(clean.data)
#' Note that one case (non-unique) is gone. All cases with missing
#' values will also have been dropped.
#'
#' # Aggregation
#' Aggregate by species. First group the data and then summarize each group.
iris %>% group_by(Species) %>% summarize_all(mean)
iris %>% group_by(Species) %>% summarize_all(median)

#'
#' # Sampling
#' ## Random sampling
#'
#' Sample from a vector with replacement.
sample(c("A", "B", "C"), size = 10, replace = TRUE)

#' Sampling rows from a tibble.
set.seed(1000)
s <- iris %>% sample_n(15)
ggpairs(s, aes(color = Species))

#' ## Stratified sampling
#'
#' You need to install the package sampling with:
#' install.packages("sampling")

library(sampling)
id2 <- strata(iris, stratanames="Species", size=c(5,5,5), method="srswor")
id2

s2 <- iris %>% slice(id2$ID_unit)
ggpairs(s2, aes(color = Species))

#' # Features
#' ## Dimensionality reduction (Principal Components Analysis - PCA)
#'
#' Interactive 3d plots (needs package plotly)
library(plotly)
plot_ly(iris, x = ~Sepal.Length, y = ~Petal.Length, z = ~Sepal.Width,
  size = ~Petal.Width, color = ~Species, type="scatter3d",
 mode="markers")

#' Calculate the principal components
pc <- iris %>% select(-Species) %>% as.matrix() %>% prcomp()

#' How important is each principal component?
plot(pc)

#' Inspect the raw object (display *str*ucture)
str(pc)
ggplot(as_tibble(pc$x), aes(x = PC1, y = PC2, color = iris$Species)) + geom_point()

#' Plot the projected data and add the original dimensions as arrows (this can be done with ggplot2, but is currently painful; see https://stackoverflow.com/questions/6578355/plotting-pca-biplot-with-ggplot2).
biplot(pc, col = c("grey", "red"))

#' ## Feature selection
#'
#' We will talk about feature selection when we discuss classification models.
#'
#' ## Discretize features

ggplot(iris, aes(x = Petal.Width, y = 1:150)) + geom_point()

#' A histogram is a better visualization for the distribution of a single
#' variable.
ggplot(iris, aes(Petal.Width)) + geom_histogram()

#' Equal interval width
iris %>% pull(Sepal.Width) %>% cut(breaks=3)

#' Other methods (equal frequency, k-means clustering, etc.)
library(arules)
iris %>% pull(Petal.Width) %>% discretize(method = "interval", breaks = 3)
iris %>% pull(Petal.Width) %>% discretize(method = "frequency", breaks = 3)
iris %>% pull(Petal.Width) %>% discretize(method = "cluster", breaks = 3)

ggplot(iris, aes(Petal.Width)) + geom_histogram() +
  geom_vline(xintercept =
      iris %>% pull(Petal.Width) %>% discretize(method = "interval", breaks = 3, onlycuts = TRUE),
    color = "blue") +
  labs(title = "Discretization: interval", subtitle = "Blue lines are boundaries")

ggplot(iris, aes(Petal.Width)) + geom_histogram() +
  geom_vline(xintercept =
      iris %>% pull(Petal.Width) %>% discretize(method = "frequency", breaks = 3, onlycuts = TRUE),
    color = "blue") +
  labs(title = "Discretization: frequency", subtitle = "Blue lines are boundaries")

ggplot(iris, aes(Petal.Width)) + geom_histogram() +
  geom_vline(xintercept =
      iris %>% pull(Petal.Width) %>% discretize(method = "cluster", breaks = 3, onlycuts = TRUE),
    color = "blue") +
  labs(title = "Discretization: cluster", subtitle = "Blue lines are boundaries")

#' ## Standardize data (Z-score)
#'
#' Standardize the scale of features to make them comparable. For each
#' column the mean is subtracted (centering) and it is divided by the
#' standard deviation (scaling). Now most values should be in [-3,3].
iris.scaled <- iris %>% mutate_if(is.numeric, function(x) as.vector(scale(x)))
iris.scaled
summary(iris.scaled)

#' # Proximities: Similarities and distances
#'
#' __Note:__ R actually only uses dissimilarities/distances.
#'
#' ## Minkovsky distances
iris_sample <- iris.scaled %>% select(-Species) %>% slice(1:5)
iris_sample

#' Calculate distances matrices between the first 5 flowers (use only the 4 numeric columns).
iris_sample %>% dist(method="euclidean")
iris_sample %>% dist(method="manhattan")
iris_sample %>% dist(method="maximum")

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
b %>% dist(method = "binary")
#' ### Hamming distance
#'
#' Hamming distance is the number of mis-matches (equivalent to
#' Manhattan distance on 0-1 data and also the squared Euclidean distance).
b %>% dist(method = "manhattan")

b %>% dist(method = "euclidean") %>% "^"(2)
#' _Note_: `"^"(2)` calculates the square.
#'
#' ## Distances for mixed data
#'
#' ### Gower's distance
#'
#' Works with mixed data
data <- tibble(
  height= c(      160,    185,    170),
  weight= c(       52,     90,     75),
  sex=    c( "female", "male", "male")
)
data

#' __Note:__ Nominal variables need to be factors!

data <- data %>% mutate_if(is.character, factor)
data

library(proxy)
d_Gower <- data %>% dist(method="Gower")
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
data_dummy <- dummyVars(~., data) %>% predict(data)
data_dummy

#' Since sex has now two columns, we need to weight them by 1/2 after scaling.
weight <- matrix(c(1,1,1/2,1/2), ncol = 4, nrow = nrow(data_dummy), byrow = TRUE)
data_dummy_scaled <- scale(data_dummy) * weight

d_dummy <- data_dummy_scaled %>% dist()
d_dummy

#' Distance is (mostly) consistent with Gower's distance (other than that
#' Gower's distance is scaled between 0 and 1).
ggplot(tibble(d_dummy, d_Gower), aes(x = d_dummy, y = d_Gower)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

#' ## Additional proximity measures available in package proxy
library(proxy)
pr_DB$get_entries() %>% names()


#' # Relationship between features

#' ## Correlation (for ratio/interval scaled features)

#' Pearson correlation between features (columns)
cc <- iris %>% select(-Species) %>% cor()

ggplot(iris, aes(Petal.Length, Petal.Width)) + geom_point() +
  geom_smooth(method = "lm")
with(iris, cor(Petal.Length, Petal.Width))
with(iris, cor.test(Petal.Length, Petal.Width))

ggplot(iris, aes(Sepal.Length, Sepal.Width)) + geom_point() +
  geom_smooth(method = "lm")
with(iris, cor(Sepal.Length, Sepal.Width))
with(iris, cor.test(Sepal.Length, Sepal.Width))

#' ## Rank correlation (for ordinal features)
#' convert to ordinal variables with cut (see ? cut) into
#' ordered factors with three levels
iris_ord <- iris %>% mutate_if(is.numeric,
  function(x) cut(x, 3, labels = c("short", "medium", "long"), ordered = TRUE))

iris_ord
summary(iris_ord)
iris_ord %>% pull(Sepal.Length)

#' Kendall's tau rank correlation coefficient
iris_ord %>% select(-Species) %>% sapply(xtfrm) %>% cor(method="kendall")
#' Spearman's rho
iris_ord %>% select(-Species) %>% sapply(xtfrm) %>% cor(method="spearman")
#' __Note:__ unfortunately we have to transform the ordered factors
#' into numbers representing the order with xtfrm first.
#'
#' Compare to the Pearson correlation on the original data
iris %>% select(-Species) %>% cor()

#' ## Relationship between nominal and ordinal features
#' Is sepal length and species related? Use cross tabulation
tbl <- iris_ord %>% select(Sepal.Length, Species) %>% table()
tbl

# this is a little more involved using tidyverse
iris_ord %>%
  select(Species, Sepal.Length) %>%
  pivot_longer(cols = Sepal.Length) %>%
  group_by(Species, value) %>% count() %>% ungroup() %>%
  pivot_wider(names_from = Species, values_from = n)

#' Test of Independence: Pearson's chi-squared test is performed with the null hypothesis that the joint distribution of the cell counts in a 2-dimensional contingency table is the product of the row and column marginals. (h0 is independence)
tbl %>% chisq.test()

#' Using xtabs instead
x <- xtabs(~Sepal.Length + Species, data = iris_ord)
x
summary(x)

#' Group-wise averages
iris %>% group_by(Species) %>% summarize_at(vars(Sepal.Length), mean)
iris %>% group_by(Species) %>% summarize_all(mean)

#' # Density estimation
#'
#' Just plotting the data is not very helpful
ggplot(iris, aes(Petal.Length, 1:150)) + geom_point()

#' Histograms work better
ggplot(iris, aes(Petal.Length)) +
  geom_histogram() +
  geom_rug(alpha = 1/10)

#'
#' Kernel density estimate KDE
ggplot(iris, aes(Petal.Length)) +
  geom_rug(alpha = 1/10) +
  geom_density()

#' Plot 2d kernel density estimate
ggplot(iris, aes(Sepal.Length, Sepal.Width)) +
  geom_jitter() +
  geom_density2d()

ggplot(iris, aes(Sepal.Length, Sepal.Width)) +
  geom_bin2d(bins = 10) +
  geom_jitter(color = "red")

ggplot(iris, aes(Sepal.Length, Sepal.Width)) +
  geom_hex(bins = 10) +
  geom_jitter(color = "red")
