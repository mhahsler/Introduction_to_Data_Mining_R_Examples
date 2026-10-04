# clean workspace and detach packages.

rm(list = setdiff(ls(), "all_pkgs"))

attached <- grep("^package:", search(), value = TRUE)
for (pkg in setdiff(attached, c(
  "package:base", "package:methods", "package:stats",
  "package:graphics", "package:grDevices", "package:utils",
  "package:datasets"
))) {
  detach(pkg, character.only = TRUE, unload = TRUE)
}