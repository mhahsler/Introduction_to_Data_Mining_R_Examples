#!/usr/bin/env Rscript

params <- commandArgs(trailingOnly=TRUE)

pkgs <- "bookdown"
pkgs_install <- pkgs[!(pkgs %in% installed.packages()[,"Package"])]
if(length(pkgs_install)) install.packages(pkgs_install)


bookdown::render_book("index.Rmd", "bookdown::pdf_book")

warnings()


