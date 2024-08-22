# example R options set globally
options(
  htmltools.dir.version = FALSE, 
  formatR.indent = 2,
  width = 60, 
  digits = 4, 
  warnPartialMatchAttr = FALSE, 
  warnPartialMatchDollar = FALSE
)

local({
  r = getOption('repos')
  if (!length(r) || identical(unname(r['CRAN']), '@CRAN@'))
    r['CRAN'] = 'https://cran.rstudio.com' 
  options(repos = r)
})

# example chunk options set globally
knitr::opts_chunk$set(
#  comment = "#>",
  # tidy = TRUE,
  # tidy.opts = list(width.cutoff = 60),
  collapse = TRUE,
  options(width = 60),
  strip.white = TRUE
  )

# this is for tidyverse bug
options(cli.width = 60)
