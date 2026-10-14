# =============================================================================
#  Information Visualization -- R track: install the packages for the course
#
#  HOW TO RUN (in RStudio):
#   1. Open the lecture's .Rproj file, e.g. "Lecture 2.Rproj" (double-click it).
#      RStudio opens. (Posit Cloud: open the project "Information Visualization".)
#   2. In the Files pane (bottom right) open the folder "setup", then click
#      this file to open it.
#   3. Click the "Source" button (top right of this editor pane).
#   4. Wait until the Console (bottom left) prints "ALL GOOD". This can take
#      5 to 15 minutes the first time. Red text scrolling by is normal.
#  Safe to run more than once: packages you already have are skipped.
# =============================================================================
if (identical(getOption("repos")[["CRAN"]], "@CRAN@") || is.null(getOption("repos")))
  options(repos = c(CRAN = "https://cloud.r-project.org"))

pkgs <- c("tidyverse", "ggrepel", "scales", "patchwork", "hexbin",
          "colorspace", "png",                   # Lecture 2 (colour checks)
          "systemfonts", "ragg",                 # fonts + good PNG output
          "plotly", "shiny",                     # Lecture 4 (interactivity)
          "sf", "leaflet")                       # Lecture 5 (maps)

if (getRversion() < "4.1.0")
  stop("Your R is too old (", getRversion(), "). Install the latest R from ",
       "https://cran.r-project.org and run this file again.")

missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing)) {
  message("Installing ", length(missing), " package(s): ",
          paste(missing, collapse = ", "))
  install.packages(missing)
}

still_missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(still_missing)) {
  message("\nThese packages could not be installed: ",
          paste(still_missing, collapse = ", "),
          "\nTake a screenshot of the Console and bring it to the exercise session.")
} else {
  message("\nALL GOOD: R ", getRversion(), " and all ", length(pkgs),
          " packages are installed.",
          "\nNext: open setup/check_setup.R and click Source.")
}
