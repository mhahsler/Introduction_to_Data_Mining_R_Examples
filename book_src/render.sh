#!/usr/bin/env Rscript

params <- commandArgs(trailingOnly=TRUE)

pkgs <- "bookdown"
pkgs_install <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
if(length(pkgs_install)) install.packages(pkgs_install)


if (length(params) == 0) {
	bookdown::render_book("index.Rmd", output_format = "bookdown::bs4_book")
} else { 
	bookdown::preview_chapter(params, output_format = "bookdown::bs4_book")
}

warnings()


# bookdown::render_book("index.Rmd", "bookdown::pdf_book")