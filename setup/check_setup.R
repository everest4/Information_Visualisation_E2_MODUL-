# =============================================================================
#  Information Visualization -- R track: check your setup
#
#  Open the lecture's .Rproj file first (e.g. "Lecture 2.Rproj"; on Posit Cloud
#  the project "Information Visualization"), then open this file and click "Source".
#  It checks the packages, finds the course data and draws one test chart
#  in the Plots pane (bottom right).
# =============================================================================
pkgs <- c("tidyverse", "ggrepel", "scales", "patchwork", "hexbin",
          "colorspace", "png")
cat("\nInformation Visualization - checking your R setup\n")
cat(strrep("-", 56), "\n")
cat("R", as.character(getRversion()), "\n")

problems <- 0
for (p in pkgs) {
  if (requireNamespace(p, quietly = TRUE)) {
    cat(sprintf("  [OK]      %-10s %s\n", p, as.character(packageVersion(p))))
  } else {
    problems <- problems + 1
    cat(sprintf("  [MISSING] %-10s -> run setup/install_R_packages.R\n", p))
  }
}

course_data <- c("data/milan_air_2021.csv", "data/owid_co2_1950_2024.csv")
if (!any(file.exists(course_data)) && any(file.exists(file.path("..", course_data)))) {
  setwd("..")   # run from inside setup/: move up to the lecture folder
  cat("  [NOTE]    working directory set to", getwd(), "\n")
}
data_file <- course_data[file.exists(course_data)][1]
if (!is.na(data_file)) {
  cat("  [OK]      course data found:", basename(data_file), "\n")
} else {
  problems <- problems + 1
  cat("  [MISSING] course data not found from the working directory:\n",
      "           ", getwd(), "\n",
      "            Open the lecture's .Rproj file and run this again.\n")
}

if (problems == 0) {
  suppressPackageStartupMessages(library(tidyverse))
  d <- read_csv(data_file, show_col_types = FALSE)
  test <- if (grepl("milan", data_file)) {
    d |> filter(pollutant == "PM10", station == "Senato") |>
      ggplot(aes(date, value)) +
      labs(title = "It works! Milan, PM10 at via Senato")
  } else {
    d |> filter(country == "Austria") |>
      ggplot(aes(year, co2_t_per_capita)) +
      labs(title = "It works! Austria, CO2 per person (t)")
  }
  print(test + geom_line(colour = "#CC071E") + expand_limits(y = 0) +
          labs(x = NULL, y = NULL) + theme_minimal())
  cat(strrep("-", 56), "\n")
  cat("ALL GOOD. Your R setup is ready: look at the Plots pane.\n\n")
} else {
  cat(strrep("-", 56), "\n")
  cat(problems, "problem(s) found (see above).\n\n")
}
