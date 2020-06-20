#' ---
#' title: "R Code for Chapter 5 of Introduction to Data Mining: Association Analysis"
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

#' # Used packages
#'
#' Install the following packages.
#'
#' * [`arules`](https://www.rdocumentation.org/packages/arules/)
#' * [`arulesViz`](https://www.rdocumentation.org/packages/arulesViz/)
#'

library(tidyverse)
library(ggplot2)

library(arules)
library(arulesViz)

#' For information about the `arules` package try:
#' `help(package="arules")`
#' and
#' `vignette("arules")` (also available at [CRAN](http://cran.r-project.org/web/packages/arules/vignettes/arules.pdf))
#'
#' ## S4 object system
#'
#' Standard R objects use the [S3 object system](http://adv-r.had.co.nz/S3.html)
#' which do not use formal class definitions and are usually implemented
#' as a list with a class attribute.
#' `arules` and many other R packages use the
#' [S4 object system](http://adv-r.had.co.nz/S4.html) which is based on
#' formal class definitions (similar to object-oriented programming languages like
#' Java and C++).
#' Some important differences of using S4 objects compared to the usual S3
#' objects are:
#'
#' * coercion (casting): `as(from, "class_name")`
#' * help: `class? class_name`
#'

#' # Used data
data(Zoo, package = "mlbench")
head(Zoo)


#' # Transactions
#' ## Create transactions
#'
#' The data in the data.frame need to be converted into a set of transactions where each row represents a transaction and each column is translated into items.
#' For the Zoo data set this means that we consider animals as transactions
#' and the different traits (features) will become items that each animal has. For
#' example the animal _antelope_ has the item _hair_ in its transaction.
trans <- as(Zoo, "transactions")
#'
#' The conversion gives a warning because only discrete features (`factor` and `logical`) can be
#' directly translated into items. Continuous features need to be discretizes first.
#'
#' What is column 13?
summary(Zoo[13])
ggplot(Zoo, aes(legs)) + geom_histogram()
table(Zoo$legs)

#' Possible solution: Make legs into has/does not have legs
Zoo_has_legs <- Zoo %>% mutate(legs = legs > 0)
ggplot(Zoo_has_legs, aes(legs)) + geom_bar()
table(Zoo_has_legs$legs)

#' __Alternatives:__
#'
#' * use each unique value as an item:
Zoo_unique_leg_values <- Zoo %>% mutate(legs = factor(legs))
head(Zoo_unique_leg_values$legs)

#' * discretize (see [`? discretize`](https://www.rdocumentation.org/packages/arules/topics/discretize) and
#' [discretization in the code for Chapter 2](chap2.html#discretize-features)):
Zoo_discretized_legs <- Zoo %>% mutate(
  legs = discretize(legs, breaks = 2, method="interval")
)
table(Zoo_discretized_legs$legs)
#'
#'  Convert data into a set of transactions
trans <- as(Zoo_has_legs, "transactions")
trans

#' ## Inspect Transactions
summary(trans)

#' Look at created items. They are still called column names since the transactions are actually stored as a large sparse logical matrix (see below).
colnames(trans)
#' Compare with the original features (column names) from Zoo
colnames(Zoo)

#' Look at a (first) few transactions as a matrix. 1 indicates the presence of an item.
as(trans, "matrix")[1:3,]
#' Look at the transactions as sets of items
inspect(trans[1:3])
#' Plot the binary matrix. Dark dots represent 1s.
image(trans)
#' Look at the relative frequency (=support) of items in the data set. Here we look at the 10 most frequent items.
itemFrequencyPlot(trans,topN = 20)

ggplot(
  tibble(
    Support = sort(itemFrequency(trans, type = "absolute"), decreasing = TRUE),
    Item = seq_len(ncol(trans))
  ), aes(x = Item, y = Support)) + geom_line()


#' __Alternative encoding:__ Also create items for FALSE (use factor)
sapply(Zoo_has_legs, class)
Zoo_factors <- Zoo_has_legs %>% mutate_if(is.logical, factor)
sapply(Zoo_factors, class)
summary(Zoo_factors)

trans_factors <- as(Zoo_factors, "transactions")
trans_factors

itemFrequencyPlot(trans_factors, topN = 20)

# Select transactions that contain a certain item
trans_insects <- trans_factors[trans %in% "type=insect"]
trans_insects
inspect(trans_insects)

#' ## Vertical layout (Transaction ID Lists)
#'
#' The default layout for transactions is horizontal layout (i.e. each transaction is a row).
#' The vertical layout represents transaction data as a list of transaction IDs for each item (= transaction ID lists).
vertical <- as(trans, "tidLists")
as(vertical, "matrix")[1:10, 1:5]

#' # Frequent Itemsets
#' ## Mine Frequent Itemsets
#'
#' For this dataset we have already a huge number of possible itemsets
2^ncol(trans)

#' Find frequent itemsets (target="frequent") with the default settings.
its <- apriori(trans, parameter=list(target = "frequent"))
its
#' Default minimum support is .1 (10\%).
#' __Note:__ We use here a very small data set. For larger datasets
#' the default minimum support might be to low and you may run out of memory. You probably want to start out with a higher minimum support like
#' .5 (50\%) and then work your way down.

5/nrow(trans)

#' In order to find itemsets that effect 5 animals I need to go down to a
#' support of about 5\%.
its <- apriori(trans, parameter=list(target = "frequent", support = 0.05))
its

#' Sort by support
its <- sort(its, by = "support")
inspect(head(its, n = 10))

#' Look at frequent itemsets with many items (set breaks manually since
#' Automatically chosen breaks look bad)
ggplot(tibble(`Itemset Size` = factor(size(its))), aes(`Itemset Size`)) + geom_bar()
inspect(its[size(its) > 8])

#' ## Concise Representation of Itemsets
#'
#' Find maximal frequent itemsets (no superset if frequent)
its_max <- its[is.maximal(its)]
its_max
inspect(head(its_max, by = "support"))
#' Find closed frequent itemsets (no superset if frequent)
its_closed <- its[is.closed(its)]
its_closed
inspect(head(its_closed, by = "support"))

counts <- c(
  frequent=length(its),
  closed=length(its_closed),
  maximal=length(its_max)
)

ggplot(as_tibble(counts, rownames = "Itemsets"),
  aes(Itemsets, counts)) + geom_bar(stat = "identity")

#'
#'
#' # Association Rules
#' ## Mine Association Rules
#'
#' We use the APRIORI algorithm (see [`? apriori`](https://www.rdocumentation.org/packages/arules/topics/apriori))

rules <- apriori(trans, parameter = list(support = 0.05, confidence = 0.9))
length(rules)

inspect(head(rules))
quality(head(rules))

#' Look at rules with highest lift
rules <- sort(rules, by = "lift")
inspect(head(rules, n = 10))

#' Create rules using the alternative encoding (with "FALSE" item)
r <- apriori(trans_factors)
r
print(object.size(r), unit = "Mb")

inspect(r[1:10])
inspect(head(r, n = 10, by = "lift"))

#' ## Calculate Additional Interest Measures
interestMeasure(rules[1:10], measure = c("phi", "gini"),
  trans = trans)

#' Add measures to the rules
quality(rules) <- cbind(quality(rules),
  interestMeasure(rules, measure = c("phi", "gini"),
    trans = trans))

#' Find rules which score high for Phi correlation
inspect(head(rules, by = "phi"))

#' ## Mine using Templates
#'
#' Sometimes it is beneficial to specify what items should be where in the rule. For apriori we can use the parameter appearance to specify this (see [`? APappearance`](https://www.rdocumentation.org/packages/arules/topics/APappearance)). In
#' the following we restrict rules to an animal `type` in the RHS and any item in
#' the LHS.
type <- grep("type=", itemLabels(trans), value = TRUE)
type

rules_type <- apriori(trans, appearance= list(rhs = type))

inspect(head(sort(rules_type, by = "lift")))

#' Saving rules as a CSV-file to be opened with Excel or other tools.
#'
#' `write(rules, file = "rules.csv", quote = TRUE)`
#'
#' # Association rule visualization
library(arulesViz)

#' Default scatterplot
plot(rules)

#' Add some jitter (randomly move points) to show how many rules have the
#' same confidence and support value.
plot(rules, control=list(jitter = .5))

plot(rules, shading = "order", control = list(jitter = .5))
#plot(rules, interactive = TRUE)

#' Grouped plot
plot(rules, method = "grouped")
#plot(rules, method = "grouped", engine = "interactive")

#' As a graph
plot(rules, method = "graph")
plot(head(rules, by = "phi", n = 100), method = "graph")

#' ## More interactive visualization
#'
#' Interactive visualizations using datatable and plotly can be found [here.](chap6_interactive.html) __Note:__ the page might load slowly because it makes
#' heavy use of client side computation.
#'

