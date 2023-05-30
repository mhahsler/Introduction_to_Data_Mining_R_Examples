---
title: 'An R Companion for Introduction to Data Mining'
tags:
  - R
  - data mining
authors:
  - name: Michael Hahsler
    orcid: 0000-0003-2716-1405
    affiliation: "1"
affiliations:
 - name: Michael Hahsler, Clinical Associate Professor, Southern Methodist University
   index: 1
date: 30 May 2023
bibliography: paper.bib

# Optional fields if submitting to a AAS journal too, see this blog post:
# https://blog.joss.theoj.org/2018/12/a-new-collaboration-with-aas-publishing
aas-doi: 10.3847/xxxxx <- update this with the DOI from AAS once you know it.
aas-journal: Astrophysical Journal <- The name of the AAS journal.
---

# Summary

An R Companion for Introduction to Data Mining is an open source learning and 
teaching resource for an introductory course in data mining. It
can be used to accompany the popular
data mining textbook Introduction to Data Mining [@] or as a stand-alone resource
to study the basic concepts of data mining including data preparation, classification,
clustering and association analysis. The resource uses complete annotated examples 
to 



R for Data Analysis is a sequential learning system designed to teach anyone how to use R to analyze data. The materials can be used in aggregate to learn how to analyze data programmatically or broken into modules and used to supplement an existing educational program. Each lesson contains a conceptual overview, practical examples, resources for further study, and exercises designed to reinforce understanding.

The materials have been made publicly available at: <https://mhahsler.github.io/Introduction_to_Data_Mining_R_Examples/book/> and licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 (CC BY-NC-SA 4.0) License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

# Statement of Need

In the article titled "An empirical study of the rise of big data in business scholarship", the authors suggest that the amount of data that exists in our current society creates a "constant flow of potential new insights for business, government, education and social initiatives" [@Frizzo-Barker]. This presents an opportunity to educate practitioners in both industry and academia on programmatic data analysis techniques. These practitioners may have historically relied on specialists and/or methodologists to perform analyses, but it is important to ensure that analysis tools are as accessible as the data has become.

There are plenty of resources aimed at teaching specialists how to apply advanced analytics techniques to their chosen discipline; however, there is a notable lack of resources which aim to educate the general public on programmatic data analysis. This phenomenon was observed in an article titled "What is Statistics?" when the authors proclaimed "statistical education has not been sufficiently accessible." [@Brown]. Furthermore, the contents of R for Data Analysis are centered around the idea of the "process of data analysis" broadly applied to any discipline. This differs from other high-quality resources, such as "R for Reproducible Scientific Analysis" [@Zimmerman], which teaches similar topics in the context of the scientific process. 

# Instructional Design

The learner is guided through programming concepts which progress in difficulty while simultaneously applying these concepts to the process of data analysis. The process of data analysis is broken into five steps:

1.  **Gathering Requirements** - Before one embarks on an analysis, it\'s important to make sure the requirements are understood. Requirements include the questions which one's stakeholders are hoping to answer as well as the technical requirements of how the analysis will be performed.

2.  **Data Acquisition** - As one might imagine, data must be acquired before conducting an analysis. This may be done through methods such as manual creation of data sets, importing pre-constructed data, or leveraging APIs.

3.  **Data Preparation** - Most data will not be received in the precise format one needs. The process of data preparation is where features and structure will be added to the data.

4.  **Developing Insights** - Once the data is prepared, one can begin to make sense of the data and develop insights about its meaning.

5.  **Reporting** - Finally, it\'s important to report on the data in such a way that the information is able to be digested by the people who need to see it when they need to see it.

No prior knowledge is required to begin using these materials. The content starts at the very beginning by showing learners how to set up their R environment and the basics of programming in R. By the end of the materials, learners will be able to perform intermediate analytics techniques such as linear regression and automatic report generation. The materials are structured as follows:

-   **Part I (Fundamentals)** will introduce learners to the basics of programming in the context of R.

-   **Part II (Data Acquisition)** will teach learners how to create, import, and access data.

-   **Part III (Data Preparation)** will show learners how to begin preparing data for analysis.

-   **Part IV (Developing Insights)** goes through the process of searching for and extracting insights from data.

-   **Part V (Reporting)** demonstrates how to wrap an analysis up by developing and automating reports.

Each part contains several chapters which cover specific ideas related to the overarching topic. At the end of each of these chapters the learner will find additional resources to use to dive deeper into the ideas. Each part is then concluded with practical exercises for learners to test their skills.

# Statement of Need 

The forces on stars, galaxies, and dark matter under external gravitational
fields lead to the dynamical evolution of structures in the universe. The orbits
of these bodies are therefore key to understanding the formation, history, and
future state of galaxies. The field of "galactic dynamics," which aims to model
the gravitating components of galaxies to study their structure and evolution,
is now well-established, commonly taught, and frequently used in astronomy.
Aside from toy problems and demonstrations, the majority of problems require
efficient numerical tools, many of which require the same base code (e.g., for
performing numerical orbit integration).

``Gala`` is an Astropy-affiliated Python package for galactic dynamics. Python
enables wrapping low-level languages (e.g., C) for speed without losing
flexibility or ease-of-use in the user-interface. The API for ``Gala`` was
designed to provide a class-based and user-friendly interface to fast (C or
Cython-optimized) implementations of common operations such as gravitational
potential and force evaluation, orbit integration, dynamical transformations,
and chaos indicators for nonlinear dynamics. ``Gala`` also relies heavily on and
interfaces well with the implementations of physical units and astronomical
coordinate systems in the ``Astropy`` package [@astropy] (``astropy.units`` and
``astropy.coordinates``).

``Gala`` was designed to be used by both astronomical researchers and by
students in courses on gravitational dynamics or astronomy. It has already been
used in a number of scientific publications [@Pearson:2017] and has also been
used in graduate courses on Galactic dynamics to, e.g., provide interactive
visualizations of textbook material [@Binney:2008]. The combination of speed,
design, and support for Astropy functionality in ``Gala`` will enable exciting
scientific explorations of forthcoming data releases from the *Gaia* mission
[@gaia] by students and experts alike.

# Mathematics

Single dollars ($) are required for inline mathematics e.g. $f(x) = e^{\pi/x}$

Double dollars make self-standing equations:

$$\Theta(x) = \left\{\begin{array}{l}
0\textrm{ if } x < 0\cr
1\textrm{ else}
\end{array}\right.$$


# Citations

Citations to entries in paper.bib should be in
[rMarkdown](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
format.

For a quick reference, the following citation commands can be used:
- `@author:2001`  ->  "Author et al. (2001)"
- `[@author:2001]` -> "(Author et al., 2001)"
- `[@author1:2001; @author2:2001]` -> "(Author1 et al., 2001; Author2 et al., 2002)"

# Figures

Figures can be included like this: ![Example figure.](figure.png)

# Acknowledgements

We acknowledge contributions from Brigitta Sipocz, Syrtis Major, and Semyeong
Oh, and support from Kathryn Johnston during the genesis of this project.

# References
