#' ---
#' title: "R Code for Chapter 5 of Introduction to Data Mining: Association Rule Mining (Additional Interactive Visualization)"
#' author: "Michael Hahsler"
#' output:
#'  html_document:
#'    toc: true
#' ---

#' This code covers chapter 5 of _"Introduction to Data Mining"_
#' by Pang-Ning Tan, Michael Steinbach and Vipin Kumar.
#'
#' ![CC](https://i.creativecommons.org/l/by/4.0/88x31.png)
#' This work is licensed under the
#' [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/). For questions please contact
#' [Michael Hahsler](http://michael.hahsler.net).
#'

library(arules)
library(arulesViz)

#' Load the data set
data(Groceries)
summary(Groceries)
inspect(head(Groceries))

#' Mine Association Rules
rules <- apriori(Groceries, parameter=list(support=0.001, confidence=.8))

#' # Interactive inspect with sorting, filtering and paging
inspectDT(rules)

#' # Plot rules as a scatter plot using an interactive html widget
plot(rules, engine = "html")

#' _Note:_ plotly currently does not do well with too many points, so plot
#' selects the top 1000 rules only (with a warning).
#'
#' # Plot rules as a graph using an interactive html widget

plot(rules, method = "graph", engine = "html")

#' _Note:_  currently does not do well with too many points, so plot
#' selects the top 100 rules only (with a warning).
#'
#' # Interactive Rule Explorer
#'
#' Paste this into your R session:
#'
#' `library("arulesViz")`
#'
#' `data(Groceries)`
#'
#' `ruleExplorer(Groceries, parameter = list(support = 0.001, conf = 0.8))`
