---
title: "An R Companion for Introduction to Data Mining"
tags:
- R
- data mining
date: "30 May 2023"
output: pdf_document
authors:
- name: Michael Hahsler
  orcid: "0000-0003-2716-1405"
  affiliation: 1
bibliography: paper.bib
affiliations:
- name: Southern Methodist University
  index: 1
---

# Summary

An R Companion for Introduction to Data Mining is an open-source learning and 
teaching resource that covers how to implement data mining concepts using R.
It can be used to accompany the popular
data mining textbook Introduction to Data Mining [@Tan2018] or as a stand-alone resource
to study the implementation of the basic data mining concepts 
including data preparation, classification,
clustering, and association analysis. 
The resource uses complete annotated examples 
to demonstrate how data mining concepts are translated into R code.


The materials have been made publicly available at: <https://mhahsler.github.io/Introduction_to_Data_Mining_R_Examples/book/> and licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 (CC BY-NC-SA 4.0) License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

# Statement of Need

The textbook Introduction to Data Mining has been one of the most popular choices
to learn data mining concepts.
Several of the key chapters have been made available for free by the authors [@Tan2018].
One of the authors also provides Python Jupyter notebooks with examples, but
complete R code examples were missing. Given the R community's interest in 
data analysis, data science, and machine learning, and the wide support of R packages for data mining, there was an obvious gap that is filled by this learning resource.
This resource targets advanced undergraduate and graduate student and can be used as a first
introduction to data mining. 

# Learning Objectives and Content

The resource assumes basic knowledge of programming and statistics.
The learning objectives are to
learn how to

* prepare and understand data,
* perform classification,
* perform association analysis, and
* perform cluster analysis

using self-contained and annotated R code examples that work with small datasets
carefully chosen to show the learner important aspects of data mining. 
The learner can copy-and-paste the examples into an R markdown notebook to experiment with 
the code and the provided example data and then modify the code to work on their own data sets.
This learning-by-doing approach has worked very well in preparing students to work
with more complex real-world datasets by relieving them from dealing with 
too many implementation details while exploring the concepts. 

To make using the resource easier, the resources mirrors 
the structure of the textbook. After a short introduction, 
Chapter 2 discusses data types in R, data quality concerns and data preprocessing.
In addition data exploration and visualization examples are given. Chapters 3 and 4
cover classification methods, model selection, model evaluation, different 
types of classifiers, and issues like class imbalance. Chapter 5 introduces
association analysis with a strong emphasis on visualization. Chapter 7 presents 
examples for cluster analysis including popular algorithms, cluster evaluation, and
the effect of outliers.

# Instructional Design

This resource does not replace the Introduction to Data Mining textbook or instruction 
by a teacher, it rather provides supporting material for 
learning to implement data mining concepts.
The learner is expected to have some programming experience and basic 
statistics knowledge. 

The resource can be used for self-study by any interested person
using it to accompany reading the 
Introduction to Data Mining textbook
but its main purpose is to be used as a component
for designing an introductory data mining course for advanced undergraduate or 
graduate students. To support instructors, 
in addition to the documented code examples also
complete presentation slide sets are provided
on the book's GitHub page.
The slides are organized in the same way as the companion book. A direct connection
between the slides and the code examples is provided by the R symbol on slides where 
example code is available. 
The code examples can be assigned to be studied by the students outside of class
or used by the instructor in class.
Designing assignments and assessments is left to the instructor and depend on the 
level of the students.
For example, for undergraduates, it is suggested to ask the students
to apply the data mining techniques to a small clean instructional data set (many are shipped with R), 
while graduate students may be asked to analyze a larger real-world data sets which may require a
significant amount of cleaning and preprocessing.

The companion has been used successfully for many years and by several instructors 
as a key component of a introductory data mining course delivered in-person and 
in a distance education settings. 

# Story of the Project

Since starting to teach data mining with R in Spring 2013 years, I have been developing 
the Companion for Introduction to Data Mining
resource mainly based on caret [@caret2008], and a set of packages
developed with students to better support different data mining tasks (e.g., 
arules [@arules2005], seriation [@seriation2008]
arulesViz [@arulesViz2017], and dbscan [@dbscan2019]).
The resource grew from a collection of short unconnected R scripts to a complete set
of documented code examples that walk the learner step-by-step through 
how to implement data mining methods and how to interpret the results.
It went through an update to incorporate the popular tidyverse package collection [@tidyverse2019]
and a transition from the 1st edition of the  Introduction to Data Mining textbook to the second.
The resource is actively maintained by faculty at the department of Computer Science at 
Southern Methodist University and we will update it with new R tools like 
[@tidymodels2020] over time.


# References
