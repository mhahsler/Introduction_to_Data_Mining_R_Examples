#' ---
#' title: "R Code for Chapter 2 of Introduction to Data Mining: Exploring Data (with ggplot2)"
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

#' # ggplot2
#'
#' This code uses `tidyverse` for data preparation and `ggplot2` for most visualizations.

library(tidyverse)
library(ggplot2)

#'
#' The gg in `ggplot2` stands for [__grammar of graphics__](https://www.springer.com/statistics/computational/book/978-0-387-24544-7).
#' The idea is that every graph is built from the same basic components:
#'
#' - the data,
#' - a coordinate system, and
#' - visual marks representing the data (geoms).
#'
#' In `ggplot2`, the components are combined using the `+` operator.
#'
#' > `ggplot(data, mapping = aes(x = ..., y = ..., color = ...)) +`
#' > `geom_point() +`
#' > `coord_cartesian()`
#'
#' Each `geom_X` uses a `stat_Y` function to calculate what is visualizes. For example,
#' `geom_bar` uses `stat_count` to create a bar chart by counting how often each value appears in the data (see `? geom_bar`). `geom_point` just uses the stat `"identity"` to display the points using the coordinates as they are.
#'
#' RStudio's [Data Visualization Cheat Sheet](https://github.com/rstudio/cheatsheets/raw/master/data-visualization-2.1.pdf) offers a comprehensive overview of available components. A good introduction
#' can be found in the [Chapter on Data Visualization](https://r4ds.had.co.nz/data-visualisation.html) of the free book [R for Data Science](https://r4ds.had.co.nz).
#'


#' # Basic statistics
#'
#' Load the iris data set
data(iris)
iris <- as_tibble(iris)

iris
#'
#' Get summary statistics
summary(iris)

#' Get mean and standard deviation for sepal length
iris %>% pull(Sepal.Length) %>% mean()
iris %>% pull(Sepal.Length) %>% sd()

#' Ignore missing values (Note: this data does not contain any, but this is
#' what you would do)
iris %>% pull(Sepal.Length) %>% mean(na.rm = TRUE)

#' Robust mean (trim 10% of observations from each end of the distribution)
iris %>% pull(Sepal.Length) %>% mean(trim = .1)

#' Calculate a summary for all numeric columns
iris %>% summarize_if(is.numeric, mean)
iris %>% summarize_if(is.numeric, median)
iris %>% summarize_if(is.numeric, sd)
iris %>% summarize_if(is.numeric, var)
iris %>% summarize_if(is.numeric, min)
iris %>% summarize_if(is.numeric, max)

#' MAD (median absolute deviation)
iris %>% summarize_if(is.numeric, mad)

#' # Tabulate data
#'
#' Count the different species.
iris %>% count(Species)

#' Discretize the data first since there are too many values (cut divides the range by breaks, see package discretization for other methods)
iris_discrete <- iris %>% mutate_if(is.numeric,
  function(x) cut(x, 3, labels = c("short", "medium", "long"), ordered = TRUE))

iris_discrete
summary(iris_discrete)

#' Create some tables (creating tables is a little harder using tidyverse)
iris_discrete %>% select(Sepal.Length, Sepal.Width) %>% table()
iris_discrete %>% select(Petal.Length, Petal.Width) %>% table()
iris_discrete %>% select(Petal.Length, Species) %>% table()
#table(iris_discrete)

#' Test if the two features are independent given the counts in the
#' contingency table (H0: independence)
#'
#' p-value: the probability of seeing a more extreme value of the test
#' statistic under the assumption that H0 is correct. Low p-values (typically
#' less than .05 or .01) indicate that H0 should be rejected.
tbl <- iris_discrete %>% select(Sepal.Length, Sepal.Width) %>% table()
tbl
chisq.test(tbl)

#' Fisher's exact test is  better for small counts (cells with counts <5)
fisher.test(tbl)

#' Plot the distribution for a discrete variable
iris_discrete %>% pull(Sepal.Length) %>% table()
ggplot(iris_discrete, aes(Sepal.Length)) + geom_bar()

#' # Percentiles
iris %>% pull(Petal.Length) %>% quantile()

#' Interquartile range
quart <- iris %>% pull(Petal.Length) %>% quantile()
quart[4] - quart[2]

#' # Visualizations

#' ### Histogram
#'
#' Show the distribution of a single numeric variable
ggplot(iris, aes(Petal.Width)) + geom_histogram(bins = 20)

#' ### Scatter plot
#'
#' Show the relationship between two numeric variables
ggplot(iris, aes(x = Petal.Length, y = Petal.Width, color = Species)) + geom_point()

#' ### Scatter plot matrix
#'
#' Show the relationship between several numeric variables
library("GGally")
ggpairs(iris,  aes(color=Species))

#' ### Boxplot
#'

#' Compare the distribution of several continuous variables
ggplot(iris, aes(Species, Sepal.Length)) + geom_boxplot()

#' Group-wise averages
iris %>% group_by(Species) %>% summarize_if(is.numeric, mean)

#' ### ECDF: Empirical Cumulative Distribution Function
e <- iris %>% pull(Petal.Length) %>% ecdf()
e
ggplot(iris, aes(Petal.Width)) + stat_ecdf()

#' ### Data matrix visualization
ggplot(iris %>% mutate(id = row_number()) %>% pivot_longer(cols = 1:4),
  aes(x = name, y = id, fill = value)) + geom_tile() +
  scale_fill_viridis_c()

#' values smaller than the average are blue and larger ones are red
iris_scaled <- scale(iris %>% select(-Species))

ggplot(as_tibble(iris_scaled) %>% mutate(id = row_number()) %>% pivot_longer(cols = 1:4),
  aes(x = name, y = id, fill = value)) + geom_tile() +
  scale_fill_gradient2()

#' Reorder
library(seriation)
o <- seriate(iris_scaled)
iris_ordered <- permute(iris_scaled, o)
ggplot(as_tibble(iris_ordered) %>% mutate(id = row_number()) %>% pivot_longer(cols = 1:4),
  aes(x = name, y = id, fill = value)) + geom_tile() +
  scale_fill_gradient2()


#' ### Correlation matrix
#'
#' Calculate and visualize the correlation between features
cm1 <- iris %>% select(-Species) %>% as.matrix %>% cor()
cm1

library(ggcorrplot)
ggcorrplot(cm1)

#' use hmap from package seriation
hmap(cm1, margin = c(7,7), cexRow = 1, cexCol = 1)

#' Test if correlation is significantly different from 0
cor.test(iris$Sepal.Length, iris$Sepal.Width)
cor.test(iris$Petal.Length, iris$Petal.Width) #this one is significant

#' Correlation between objects
cm2 <- iris %>% select(-Species) %>% as.matrix() %>% t() %>% cor()

ggcorrplot(cm2)

#' ### Parallel coordinates plot
library(GGally)
ggparcoord(as_tibble(iris), columns = 1:4, groupColumn = 5)

#' Reorder with placing correlated features next to each other
library(seriation)
o <- seriate(as.dist(1-cor(iris[,1:4])), method="BBURCG")
get_order(o)
ggparcoord(as_tibble(iris), columns = get_order(o), groupColumn = 5)

#' Look at https://www.r-graph-gallery.com/ for many example graphs.
