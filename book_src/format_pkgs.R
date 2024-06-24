
if (!exists("all_pkgs"))
  all_pkgs <- character()

format_pkgs <- function(pkgs)
  paste(sapply(sort(pkgs), FUN = function(p) sprintf('_%s_ [@R-%s]', p ,p)), collapse = ', ')

