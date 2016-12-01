#' ---
#' title: "R Code for Chapter 6 of Introduction to Data Mining: Association Rule Mining"
#' author: "Michael Hahsler"
#' output:
#'  html_document:
#'    toc: true
#' ---

#' This code covers chapter 6 of _"Introduction to Data Mining"_
#' by Pang-Ning Tan, Michael Steinbach and Vipin Kumar.
#' __See [table of contents](https://github.com/mhahsler/Introduction_to_Data_Mining_R_Examples#readme) for code examples for other chapters.__
#'
#' ![CC](https://i.creativecommons.org/l/by/4.0/88x31.png)
#' This work is licensed under the
#' [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/). For questions please contact
#' [Michael Hahsler](http://michael.hahsler.net).
#'

#' Install arules and arulesViz
# install.packages("arules")
# install.packages("arulesViz")

#' Load the data set
data(Zoo, package="mlbench")
head(Zoo)

library(arules)
#' For information about the package try:
#' `help(package="arules")`
#' and
#' `vignette("arules")` (also available at http://cran.r-project.org/web/packages/arules/vignettes/arules.pdf)
#'

#' __Note:__ arules (and many other R packages) used S4 object-oriented programming style (= formal class definitions)
#'
#' Some important differences of S4 objects are:
#'
#' * coercion (casting): `as(from, "class_name")`
#' * help: `class? class_name`
#'
#'
#' # Transactions
#' ## Create transactions
#'
#' The data in the data.frame need to be converted into a set of transactions where each row represents a transaction and each column is translated into items.
#' For the Zoo data set this means that we consider animals as transactions
#' and the different traits (features) will become items that each animal has. For
#' example the animal _antelope_ has the item _hair_ in its transaction.
try(trans <- as(Zoo, "transactions"))
#' ```
#' ## Error in asMethod(object) :
#' ##          column(s) 13 not logical or a factor. Use as.factor or categorize first.
#' ```
#'
#' Conversion fails because all variables need to be a factors or logical! Note that the `try()` is not necessary and I just use it so that the error does not stop the translation of this document.
#'
#' What is column 13?
colnames(Zoo)[13]
legs <- Zoo[["legs"]]
summary(legs)
hist(legs)
table(legs)

#' Possible solution: Make legs into has/does not have legs
has_legs <- legs>0
has_legs
table(has_legs)
Zoo[["legs"]] <- has_legs

#' __Alternatives:__
#'
#' * use each unique value as an item:
#'  `Zoo[["legs"]] <- as.factor(legs)`
#' * use discretize for continuous data (see `? discretize` and
#' [discretization in the code for Chapter 2](chap2.html#discretrize-features)):
#'  `Zoo[["legs"]] <- discretize(legs, categories = 2, method="interval")`
#'
#'  Convert data into a set of transactions
trans <- as(Zoo, "transactions")
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
itemFrequencyPlot(trans,topN=20)
plot(sort(itemFrequency(trans, type="absolute"), decreasing=TRUE),
  xlab = "Items", ylab="Support Count", type="l")


#' __Alternative encoding:__ Also create items for FALSE (use factor)
sapply(Zoo, class)
Zoo2 <- Zoo
for(i in 1:ncol(Zoo2)) Zoo2[[i]] <- as.factor(Zoo2[[i]])
sapply(Zoo2, class)
summary(Zoo2)

trans2 <- as(Zoo2, "transactions")
trans2

itemFrequencyPlot(trans2, topN=20)

# Select transactions that contain a certain item
trans_insects <- trans2[trans %in% "type=insect"]
trans_insects
inspect(trans_insects)

#' ## Vertical layout (Transaction ID Lists)
#'
#' The default layout for transactions is horizontal layout (i.e. each transaction is a row).
#' The vertical layout represents transaction data as a list of transaction IDs for each item (= transaction ID lists).
vertical <- as(trans, "tidLists")
as(vertical, "matrix")[1:10,1:5]

#' # Frequent Itemsets
#' ## Mine Frequent Itemsets
#'
#' For this dataset we have already a huge number of possible itemsets
2^ncol(trans)

#' Find frequent itemsets (target="frequent") with the default settings.
is <- apriori(trans, parameter=list(target="frequent"))
is
#' Default minimum support is .1 (10\%).
#' __Note:__ We use here a very small data set. For larger datasets
#' the default minimum support might be to low and you may run out of memory. You probably want to start out with a higher minimum support like
#' .5 (50\%) and then work your way down.

5/nrow(trans)

#' In order to find itemsets that effect 5 animals I need to go down to a
#' support of about 5\%.
is <- apriori(trans, parameter=list(target="frequent", support=0.05))
is

#' Sort by support
is <- sort(is, by="support")
inspect(head(is, n=10))

#' Look at frequent itemsets with many items (set breaks manually since
#' Automatically chosen breaks look bad)
barplot(table(size(is)), xlab="itemset size", ylab="count")
inspect(is[size(is)>8])

#' ## Concise Representation of Itemsets
#'
#' Find maximal frequent itemsets (no superset if frequent)
is_max <- is[is.maximal(is)]
inspect(head(sort(is_max, by="support")))
#' Find closed frequent itemsets (no superset if frequent)
is_closed <- is[is.closed(is)]
inspect(head(sort(is_closed, by="support")))

barplot(c(
  frequent=length(is),
  closed=length(is_closed),
  maximal=length(is_max)
  ), ylab="count", xlab="itemsets")
#'
#'
#' # Association Rules
#' ## Mine Association Rules

rules <- apriori(trans, parameter=list(support=0.05, confidence=.9))
length(rules)

inspect(head(rules))
quality(head(rules))

#' Look at rules with highest lift
rules <- sort(rules, by="lift")
inspect(head(rules, n=10))

#' Create rules using the alternative encoding (with "FALSE" item)
r <- apriori(trans2)
r
print(object.size(r), unit="Mb")

inspect(r[1:10])
inspect(sort(r, by="lift")[1:10])

#' ## Additional Interest Measures
interestMeasure(rules[1:10], measure=c("phi", "gini"),
  trans=trans)

#' Add measures to the rules
quality(rules) <- cbind(quality(rules),
  interestMeasure(rules, measure=c("phi", "gini"),
    trans=trans))

#' Find rules which score high for Phi correlation
inspect(head(rules, by="phi"))

#' ## Mine using Templates
#'
#' Sometimes it is beneficial to specify what items should be where in the rule. For apriori we can use the parameter appearance to specify this (see `? apriori`).
type <- grep("type=", itemLabels(trans), value = TRUE)
type

rules_type <- apriori(trans,
  appearance= list(rhs=type, default="lhs"))

inspect(head(sort(rules_type, by="lift")))

#' Saving rules as a CSV-file to be opened with Excel or other tools.
#'
#' `write(rules, file="rules.csv", quote=TRUE)`
#'
#' # Association rule visualization
library(arulesViz)

#' Default scatterplot
plot(rules)

#' Add some jitter (randomly move points) to show how many rules have the
#' same confidence and support value.
plot(rules, control=list(jitter=.5))

plot(rules, shading="order", control=list(jitter=.5))
#plot(rules, interactive=TRUE)

#' Grouped plot
plot(rules, method="grouped")
#plot(rules, method="grouped", interactive=TRUE)

#' As a graph
plot(sample(rules, 100), method="graph", control=list(type="items"))
plot(sort(rules, by="phi")[1:100], method="graph", control=list(type="items"))

#' ## More interactive visualization
#'
#' Interactive visualizations using datatable and plotly can be found [here.](chap6_interactive.html) __Note:__ the page might load slowly because it makes
#' heavy use of client side computation.
#'

