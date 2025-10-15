#!/usr/bin/env Rscript

params <- commandArgs(trailingOnly=TRUE)

pkgs <- "bookdown"
pkgs_install <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
if(length(pkgs_install)) install.packages(pkgs_install)

# remove old version but save the book file
file.rename("../book/R-Companion-Data-Mining.pdf", "./R-Companion-Data-Mining.pdf")
unlink("../book", recursive=TRUE)


if (length(params) == 0) {
	bookdown::render_book("index.Rmd", output_format = "bookdown::bs4_book")
} else { 
	bookdown::preview_chapter(params, output_format = "bookdown::bs4_book")
}

file.rename("./R-Companion-Data-Mining.pdf", "../book/R-Companion-Data-Mining.pdf")

warnings()

