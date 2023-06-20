---
title: "An R Companion for Introduction to Data Mining"
tags:
  - R
  - data mining
authors:
  - name: Michael Hahsler
    orcid: 0000-0003-2716-1405
    affiliation: 1
affiliations:
 - name: Southern Methodist University
   index: 1
date: 30 May 2023
bibliography: paper.bib
---

# Summary

An R Companion for Introduction to Data Mining is an open-source learning and 
teaching resource for an introductory course in data mining. It
can be used to accompany the popular
data mining textbook Introduction to Data Mining [@Tan2018] or as a stand-alone resource
to study the basic data mining concepts including data preparation, classification,
clustering, and association analysis. The resource uses complete annotated examples 
to teach how the basic concepts are translated into R code.

The materials have been made publicly available at: <https://mhahsler.github.io/Introduction_to_Data_Mining_R_Examples/book/> and licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 (CC BY-NC-SA 4.0) License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

# Statement of Need

The textbook Introduction to Data Mining has been one of the most popular choices
to learn data mining concepts. Several of the key chapters have been made available for free by the authors [@Tan2018].
One of the authors also provides Python Jupyter notebooks with examples, but
complete R code examples were missing. Given the R community's interest in 
data analysis, data science, and machine learning, and the wide support of R packages for data mining, 
there was clearly a gap that needed to be filled.

During many years of teaching data mining with R, I developed the Companion for Introduction to Data Mining
resource mainly based on the popular tidyverse package collection [@tidyverse2019], caret [@caret2008], and a set of packages
developed with students to better support different data mining tasks (arules [@arules2005], seriation [@seriation2008]
arulesViz [@arulesViz2017], and dbscan [@dbscan2019]).

# Instructional Design

The resources borrow the structure of the textbook to introduce the learner
to 

1. data preparation and exploratory analysis,
2. classification, 
3. association rule mining, and
4. clustering.

The goal is to provide self-contained and annotated code examples that the
learner can copy-and-paste into an R markdown notebook to experiment with 
the provided example data and then modify the code to work on their own data sets.
This learning-by-doing approach has worked very well in preparing students to work
with more complex real-world datasets by relieving them from the dealing with 
too many implementation details while exploring the concepts. 

For instructors, complete presentation slide sets are provided
on the book's GitHub page.
The slides are organized in the same way as the companion book. A direct connection
between the slides and the book is provided by the R symbol on slides where 
example code is available. This direct connection makes it easier for learners and 
instructors to 
switch between the concepts on the slides and the corresponding code in the 
companion.

The companion has been used successfully by several instructors 
to deliver courses in in-person and distance education settings. It 
is also actively maintained by faculty at the department of Computer Science at 
Southern Methodist University. 

# References
