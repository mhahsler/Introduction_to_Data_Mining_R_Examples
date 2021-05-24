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

library(tidyverse)

library(arules)
library(arulesViz)

#' # Load the iris dataset
data(iris)
summary(iris)

#' Convert the data to transactions. Note that the features are numeric and need to be discretized.
#' The conversion automatically applies frequency-based discretization with 3 classes to each numeric
#' feature (with a warning).
iris_trans <- transactions(iris)
inspect(head(iris_trans))

#' # Mine Association Rules
rules <- apriori(iris_trans, parameter = list(support = 0.1, confidence = 0.8))
rules

#' # Interactive inspect with sorting, filtering and paging
inspectDT(rules)

#' # Scatter plot 
#' 
#' Plot rules as a scatter plot using an interactive html widget. To avoid overplotting,
#' jitter is added automatically. Set `jitter = 0` to disable jitter. Hovering over rules shows 
#' rule information.
#' _Note:_ plotly/javascript does not do well with too many points, so plot
#' selects the top 1000 rules with a warning if more rules are supplied.
plot(rules, engine = "html")

#' # Matrix
#' 
#' Plot rules as a matrix using an interactive html widget. 
plot(rules, method = "matrix", engine = "html") 

#' # Graph
#'  
#' Plot rules as a graph using an interactive html widget.
#' _Note:_  the used javascript library does not do well with too many graph nodes, so plot selects the top 100 rules only (with a warning).
plot(rules, method = "graph", engine = "html")

#' # Interactive Rule Explorer
#'
#' You can specify a rule set or a dataset. To explore rules that can be mined from iris, use:
#' `ruleExplorer(iris)`
#'
#' The rule explorer creates an interactive Shiny application that can be used locally or 
#' deployed on a server for sharing. A deployed version of the ruleExplorer is available 
#' [here](https://mhahsler-apps.shinyapps.io/ruleExplorer_demo/) (using [shinyapps.io](https://www.shinyapps.io/)).