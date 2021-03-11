#' ---
#' title: "R Code for Chapter 7 of Introduction to Data Mining: Clustering Analysis"
#' author: "Michael Hahsler"
#' output:
#'  html_document:
#'    toc: true
#' ---

#' This code covers chapter 7 of _"Introduction to Data Mining"_
#' by Pang-Ning Tan, Michael Steinbach and Vipin Kumar.
#' __See [table of contents](https://github.com/mhahsler/Introduction_to_Data_Mining_R_Examples#readme) for code examples for other chapters.__
#'
#' ![CC](https://i.creativecommons.org/l/by/4.0/88x31.png)
#' This work is licensed under the
#' [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/). For questions please contact
#' [Michael Hahsler](http://michael.hahsler.net).
#'


#'# Prepare Data
library(tidyverse)

#' The Ruspini data set, consisting of 75 points in four groups that is popular for illustrating clustering techniques. It is a very simple data set with well separated clusters.
data(ruspini, package = "cluster")

#' The original dataset has the points ordered by group. We can shuffle the data (rows) using `sample_frac` which samples by default 100%.
ruspini <- as_tibble(ruspini) %>% sample_frac()
ruspini

ggplot(ruspini, aes(x = x, y = y)) + geom_point()

#' Scale each column in the data to zero mean and unit standard deviation (z-scores). This prevents one attribute with a large range to dominate the others for the distance calculation.
#' _Note:_ The standard `scale()` function scales whole data.frames so we implement a function for a single vector and apply it to all numeric
#' columns.
scale_numeric <- function(x) x %>% mutate_if(is.numeric, function(y) as.vector(scale(y)))
ruspini_scaled <- ruspini %>% scale_numeric()
ggplot(ruspini_scaled, aes(x = x, y = y)) + geom_point()

#' # Clustering methods
#' ## k-means Clustering
#'
#' k-means implicitly assumes Euclidean distances. We use $k = 10$ clusters and run the algorithm 10 times with random initialized centroids. The best result is returned.
km <- kmeans(ruspini_scaled, centers = 4, nstart = 10)
km

ruspini_clustered <- ruspini_scaled %>% add_column(cluster = factor(km$cluster))
ruspini_clustered

ggplot(ruspini_clustered, aes(x = x, y = y, color = cluster)) + geom_point()

#' Add centroids
centroids <- as_tibble(km$centers, rownames = "cluster")
centroids

ggplot(ruspini_clustered, aes(x = x, y = y, color = cluster)) + geom_point() +
  geom_point(data = centroids, aes(x = x, y = y, color = cluster), shape = 3, size = 5)

#' Alternative plot from package cluster (uses principal components analysis for >2 dimensions)
library(cluster)
clusplot(ruspini_scaled, km$cluster)

#' Inspect the centroids (cluster profiles)
ggplot(pivot_longer(centroids, cols = c(x, y)), aes(x = name, y = value)) +
  geom_bar(stat = "identity") +
  facet_grid(cols = vars(cluster))

#' Find data for a single cluster
#'
#' All you need is to select the rows corresponding to the cluster. The next
#' example plots all data points of cluster 1
cluster1 <- ruspini_clustered %>% filter(cluster == 1)
cluster1
ggplot(cluster1, aes(x = x, y = y)) + geom_point() +
  coord_cartesian(xlim = c(-2, 2), ylim = c(-2, 2))

#' Try 8 clusters
ruspini_clustered_8 <- ruspini_scaled %>%
  add_column(cluster = factor(kmeans(ruspini_scaled, centers = 8)$cluster))
ggplot(ruspini_clustered_8, aes(x = x, y = y, color = cluster)) + geom_point()

#' ## Hierarchical Clustering
#'
#' dist defaults to method="Euclidean"
d <- dist(ruspini_scaled)
#' We cluster using complete link
hc <- hclust(d, method = "complete")

#' Dendrogram
plot(hc)
rect.hclust(hc, k = 4)

#' Use ggplot
library("ggdendro")
ggdendrogram(hc, labels = FALSE, theme_dendro = FALSE)
#' More plotting options for dendrograms, including plotting
#' parts of large dendrograms can be found [here.](https://rpubs.com/gaston/dendrograms)
#'
#' Calculate cluster assignments by cutting the dendrogram into four parts and add the cluster id to the data.
cluster_complete <- ruspini_scaled %>%
  add_column(cluster = factor(cutree(hc, k = 4)))
cluster_complete

ggplot(cluster_complete, aes(x, y, color = cluster)) +
  geom_point()

#' Try 8 clusters
ggplot(ruspini_scaled %>% add_column(cluster = factor(cutree(hc, k = 8))),
  aes(x, y, color = cluster)) + geom_point()

#' Clustering with single link
hc_single <- hclust(d, method = "single")
plot(hc_single)
rect.hclust(hc_single, k = 4)

cluster_single <- ruspini_scaled %>%
  add_column(cluster = factor(cutree(hc_single, k = 4)))
ggplot(cluster_single, aes(x, y, color = cluster)) + geom_point()


#' ## Density-based clustering with DBSCAN

library(dbscan)

#' Parameters: minPts is often chosen as dimensionality of the data +1.
#' Decide on epsilon using the knee in the kNN distance plot
#' (seems to be around eps = .32).
kNNdistplot(ruspini_scaled, k = 3)
abline(h = .32, col = "red")

#' run dbscan
db <- dbscan(ruspini_scaled, eps = .32, minPts = 3)
db
str(db)

ggplot(ruspini_scaled %>% add_column(cluster = factor(db$cluster)),
  aes(x, y, color = cluster)) + geom_point()
#' __Note:__ Cluster 0 represents outliers).
#'
#' Alternative visualization from package dbscan
hullplot(ruspini_scaled, db)

#'
#' Play with eps (neighborhood size) and MinPts (minimum of points needed for core cluster)

#'
#' ## Partitioning Around Medoids (PAM)
#'
#' Also called $k$-medoids. Similar to $k$-means, but uses medoids instead of centroids to represent clusters and works on a distance matrix. _Note:_ A medoid is the data point in the center of a cluster.

library(cluster)

d <- dist(ruspini_scaled)
str(d)

p <- pam(d, k = 4)
p

ruspini_clustered <- ruspini_scaled %>% add_column(cluster = factor(p$cluster))

medoids <- as_tibble(ruspini_scaled[p$medoids, ], rownames = "cluster")
medoids

ggplot(ruspini_clustered, aes(x = x, y = y, color = cluster)) + geom_point() +
  geom_point(data = medoids, aes(x = x, y = y, color = cluster), shape = 3, size = 5)

#'
#' ## Gaussian Mixture Models
library(mclust)

#' Mclust uses Bayesian Information Criterion (BIC) to find the
#' number of clusters (model selection). BIC uses the likelihood and a
#' penalty term to guard against overfitting.
m <- Mclust(ruspini_scaled)
summary(m)
plot(m, what = "classification")

#' Rerun with a fixed number of 4 clusters
m <- Mclust(ruspini_scaled, G=4)
summary(m)
plot(m, what = "classification")

#' ## Spectral clustering
#'
#' Spectral clustering works by embedding the data points of the partitioning problem into the subspace of the k largest eigenvectors of a normalized affinity/kernel matrix. Then uses a simple clustering method like k-means.
library("kernlab")

cluster_spec <- specc(as.matrix(ruspini_scaled), centers = 4)
cluster_spec

ggplot(ruspini_scaled %>% add_column(cluster = factor(cluster_spec)),
  aes(x, y, color = cluster)) + geom_point()

#' ## Fuzzy C-Means Clustering
#'
#' The fuzzy version of the known k-means clustering algorithm. Each data point
#' has a degree of membership to for each cluster.
library("e1071")

cluster_cmeans <- cmeans(as.matrix(ruspini_scaled), centers = 4)
cluster_cmeans

#' Plot membership (shown as small piecharts)
library("scatterpie")
ggplot()  +
  geom_scatterpie(data = cbind(ruspini_scaled, cluster_cmeans$membership),
    aes(x = x, y = y), cols = 3:6, legend_name = "Membership") + coord_equal()



#' # Internal Cluster Validation
#'
#' ## Compare the Clustering Quality
#'
#' Look at the within.cluster.ss and the avg.silwidth

#library(fpc)
#' Note: I do not load fpc since the NAMESPACE overwrites dbscan.

fpc::cluster.stats(d, km$cluster)
#cluster.stats(d, cluster_complete)
#cluster.stats(d, cluster_single)

#' Read `? cluster.stats` for an explanation of all the available indices.

sapply(list(
  km = km$cluster,
  hc_compl = cutree(hc, k = 4),
  hc_single = cutree(hc_single, k = 4)),
       FUN = function(x)
         fpc::cluster.stats(d, x))[c("within.cluster.ss", "avg.silwidth"), ]

#' ## Silhouette plot
library(cluster)
plot(silhouette(km$cluster, d))
#' __Note:__ The silhouette plot does not show correctly in R Studio if you have too many objects (bars are missing). I will work when you open a new plotting device with `windows()`, `x11()` or `quartz()`.
#'

#' ## Find Optimal Number of Clusters for k-means
ggplot(ruspini_scaled, aes(x, y)) + geom_point()

set.seed(1234)
ks <- 2:10

#' ### Within Sum of Squares
#' Use within sum of squares and look for the knee (nstart=5 repeats k-means 5 times and returns the best solution)
WSS <- sapply(ks, FUN = function(k) {
  kmeans(ruspini_scaled, centers = k, nstart = 5)$tot.withinss
  })

ggplot(as_tibble(ks, WSS), aes(ks, WSS)) + geom_line() +
  geom_vline(xintercept = 4, color = "red", linetype = 2)

#' ### Average Silhouette Width
#' Use average silhouette width (look for the max)
ASW <- sapply(ks, FUN=function(k) {
  fpc::cluster.stats(d, kmeans(ruspini_scaled, centers=k, nstart=5)$cluster)$avg.silwidth
  })

best_k <- ks[which.max(ASW)]
best_k

ggplot(as_tibble(ks, ASW), aes(ks, ASW)) + geom_line() +
  geom_vline(xintercept = best_k, color = "red", linetype = 2)

#' ### Dunn Index
#' Use Dunn index (another internal measure given by min. separation/ max. diameter)
DI <- sapply(ks, FUN=function(k) {
  fpc::cluster.stats(d, kmeans(ruspini_scaled, centers=k, nstart=5)$cluster)$dunn
})

best_k <- ks[which.max(DI)]
ggplot(as_tibble(ks, DI), aes(ks, DI)) + geom_line() +
  geom_vline(xintercept = best_k, color = "red", linetype = 2)

#' ### Gap Statistic
#' Compares the change in within-cluster dispersion with that expected
#' from a null model (see `? clusGap`).
#' The default method is to
#' choose the smallest k such that its value Gap(k) is not more
#' than 1 standard error away from the first local maximum.
library(cluster)
k <- clusGap(ruspini_scaled, FUN = kmeans,  nstart = 10, K.max = 10)
k
plot(k)


#' __Note:__ these methods can also be used for hierarchical clustering.
#'
#' There have been many other methods and indices proposed to determine
#' the number of clusters.
#' See, e.g.,  package [NbClust](https://cran.r-project.org/package=NbClust).
#'

#' ## Visualize the Distance Matrix
#'
#' Visualizing the unordered distance matrix does not show much structure.

ggplot(ruspini_scaled, aes(x, y)) + geom_point()
d <- dist(ruspini_scaled)

library(seriation)
pimage(d)

#' Reorder using cluster labels
pimage(d, order=order(km$cluster))

#' Use dissplot which rearranges clusters, adds cluster labels,
#'  and shows average dissimilarity in the lower half of the plot.
dissplot(d, labels = km$cluster, options=list(main="k-means with k=4"))
dissplot(d, labels = db$cluster + 1L, options=list(main="DBSCAN"))
#' Spot the problem data points for DBSCAN (we use +1 so the noise is now cluster #1)
#'
#' Misspecified k
dissplot(d, labels = kmeans(ruspini_scaled, centers = 3)$cluster)
dissplot(d, labels = kmeans(ruspini_scaled, centers = 9)$cluster)


#' # External Cluster Validation
#'
#' External cluster validation uses ground truth information. That is,
#' the user has an idea how the data should be grouped. This could be a know
#' class label not provided to the clustering algorithm.
#'
#' We use an artificial data set with known groups here. First, we need to
#' cluster the new data. We do k-means and hierarchical clustering.

library(mlbench)
shapes <- mlbench.smiley(n = 500, sd1 = 0.1, sd2 = 0.05)
plot(shapes)

#' Prepare data
truth <- as.integer(shapes$class)
shapes <- scale(shapes$x)
colnames(shapes) <- c("x", "y")
shapes <- as_tibble(shapes)

ggplot(shapes, aes(x, y)) + geom_point()

#' Find optimal number of Clusters for k-means
ks <- 2:20

#' Use within sum of squares (look for the knee)
WSS <- sapply(ks, FUN = function(k) {
  kmeans(shapes, centers = k, nstart = 10)$tot.withinss
})

ggplot(as_tibble(ks, WSS), aes(ks, WSS)) + geom_line()
#' looks like 6 clusters
km <- kmeans(shapes, centers = 6, nstart = 10)
ggplot(shapes %>% add_column(cluster = factor(km$cluster)), aes(x, y, color = cluster)) +
  geom_point()

#' Hierarchical clustering: single-link because of the mouth
d <- dist(shapes)
hc <- hclust(d, method = "single")

#' Find optimal number of clusters
ASW <- sapply(ks, FUN = function(k) {
  fpc::cluster.stats(d, cutree(hc, k))$avg.silwidth
})

ggplot(as_tibble(ks, ASW), aes(ks, ASW)) + geom_line()
#' 4 clusters
hc_4 <- cutree(hc, 4)
ggplot(shapes %>% add_column(cluster = factor(hc_4)), aes(x, y, color = cluster)) +
  geom_point()

#' Spectral Clustering
library("kernlab")
spec <- specc(as.matrix(shapes), centers = 4)
ggplot(shapes %>% add_column(cluster = factor(spec)), aes(x, y, color = cluster)) +
  geom_point()

#' Compare with ground truth with the corrected (=adjusted) Rand index (ARI),
#' the variation of information (VI) index, entropy and purity.
#
#' define entropy and purity
entropy <- function(cluster, truth) {
  k <- max(cluster, truth)
  cluster <- factor(cluster, levels = 1:k)
  truth <- factor(truth, levels = 1:k)
  m <- length(cluster)
  mi <- table(cluster)

  cnts <- split(truth, cluster)
  cnts <- sapply(cnts, FUN = function(n) table(n))
  p <- sweep(cnts, 1, rowSums(cnts), "/")
  p[is.nan(p)] <- 0
  e <- -p * log(p, 2)
  sum(rowSums(e, na.rm = TRUE) * mi / m)
}

purity <- function(cluster, truth) {
  k <- max(cluster, truth)
  cluster <- factor(cluster, levels = 1:k)
  truth <- factor(truth, levels = 1:k)
  m <- length(cluster)
  mi <- table(cluster)

  cnts <- split(truth, cluster)
  cnts <- sapply(cnts, FUN = function(n) table(n))
  p <- sweep(cnts, 1, rowSums(cnts), "/")
  p[is.nan(p)] <- 0

  sum(apply(p, 1, max) * mi/m)
}

#' calculate measures (for comparison we also use random "clusterings"
#' with 4 and 6 clusters)
random4 <- sample(1:4, nrow(shapes), replace = TRUE)
random6 <- sample(1:6, nrow(shapes), replace = TRUE)

r <- rbind(
  kmeans = c(
    unlist(fpc::cluster.stats(d, km$cluster, truth, compareonly = TRUE)),
    entropy = entropy(km$cluster, truth),
    purity = purity(km$cluster, truth)
    ),
  hc = c(
    unlist(fpc::cluster.stats(d, hc_4, truth, compareonly = TRUE)),
    entropy = entropy(hc_4, truth),
    purity = purity(hc_4, truth)
    ),
  spec = c(
    unlist(fpc::cluster.stats(d, spec, truth, compareonly = TRUE)),
    entropy = entropy(spec, truth),
    purity = purity(spec, truth)
    ),
  random4 = c(
    unlist(fpc::cluster.stats(d, random4, truth, compareonly = TRUE)),
    entropy = entropy(random4, truth),
    purity = purity(random4, truth)
    ),
  random6 = c(
    unlist(fpc::cluster.stats(d, random6, truth, compareonly = TRUE)),
    entropy = entropy(random6, truth),
    purity = purity(random6, truth)
    )
  )
r

#' Hierarchical clustering found the perfect clustering.
#'
#' Read `? cluster.stats` for an explanation of all the available indices.


#'
#' # Related Topics
#' ## Outlier Removal
#' It is often useful to remove outliers prior to clustering.
#' A density based method to identify outlier is LOF (Local Outlier Factor).
#' It is related to dbscan and compares the density around a point with the
#' densities around its neighbors. The LOF value for a regular data
#' point is 1. The larger the LOF value gets, the more likely the point is and
#' outlier.
library(dbscan)
lof <- lof(ruspini_scaled, k = 3)
lof

ggplot(ruspini_scaled %>% add_column(lof = lof), aes(x, y, color = lof)) +
    geom_point() + scale_color_gradient(low = "gray", high = "red")

#' Find outliers (find the knee)

ggplot(tibble(index = seq_len(length(lof)), lof = sort(lof)), aes(index, lof)) +
  geom_line() +
  geom_hline(yintercept = 1.3, color = "red")

ggplot(ruspini_scaled %>% add_column(outlier = lof >= 1.3), aes(x, y, color = outlier)) +
  geom_point()


#' There are many other outlier removal strategies available. See, e.g., package
#' [outliers](https://cran.r-project.org/package=outliers).
#'
#'
#'
#' ## Clustering Tendency
#' Most clustering algorithms will always produce a clustering, even if the
#' data does not contain a cluster structure. It is typically good to check
#' cluster tendency before attempting to cluster the data.
#'
#' We use again the smiley data.
library(mlbench)
shapes <- mlbench.smiley(n = 500, sd1 = 0.1, sd2 = 0.05)$x
colnames(shapes) <- c("x", "y")
shapes <- as_tibble(shapes)

#' The first step is visual inspection using scatter plots.
ggplot(shapes, aes(x = x, y = y)) + geom_point()

#' Cluster tendency is typically indicated by several separated point clouds. Often an appropriate number of clusters can also be visually obtained by counting the number of point clouds. We see four clusters, but the mouth is not convex/spherical and thus will pose a problems to algorithms like k-means.
#'
#' If the data has more than two features then you can use a pairs plot (scatterplot matrix) or look at a scatterplot of the first two principal components using PCA.

library(seriation)
#' Visual Analysis for Cluster Tendency Assessment (VAT) reorders the
#' objects to show potential clustering tendency as a block structure
#' (dark blocks along the main diagonal). Usually they analyze the distance matrix. We scale the data before using Euclidean distance.
d_shapes <- dist(scale(shapes))
VAT(d_shapes)

#' iVAT uses the largest distances for all possible paths between two objects
#' instead of the direct distances to make the block structure better visible.
iVAT(d_shapes)

#' Both plots show a strong cluster structure with 4 clusters.
#'
#' Compare with random data.
data_random <- tibble(x = runif(500), y = runif(500))
ggplot(data_random, aes(x, y)) + geom_point()

#' No point clouds are visible, just noise.

d_random <- dist(data_random)
VAT(d_random)
iVAT(d_random)
#' There is very little clustering structure visible indicating low clustering tendency and clustering should not be performed on this data. However, k-means can be used to partition the data into $k$ regions of roughly equivalent size. This can be used as a data-driven discretization of the space.
