# =============================================================================
#  Exercise E2: Redesign sprint  (R track)
#  Information Visualization, Modul University Vienna, Fall 2026
#
#  Deliverable B: redesign ONE flawed chart (below) with appropriate colour
#  scales and encodings, and explain every change with a design principle.
#
#  Open "Lecture 2.Rproj" first (Posit Cloud: the "Information Visualization"
#  project), then this file. Run a line with Ctrl+Enter (Mac: Cmd+Enter).
#  Step 1 draws the flawed chart. Step 2 is yours: replace every TODO.
#  Step 3 checks your redesign for colour blindness and greyscale.
# =============================================================================
library(tidyverse)
source("cvd_tools.R")          # cvd_check(): colour-blindness check

air <- read_csv("data/milan_air_2021.csv", show_col_types = FALSE)

## >> e2_flawed
# ---- Step 1: the flawed chart (run it)
no2 <- air |>
  filter(pollutant == "NO2") |>
  mutate(month = month.abb[month(date)]) |>
  group_by(station_id, month) |>
  summarise(value = mean(value), days = n(),
            .groups = "drop")

jet <- c("#00007F", "blue", "#007FFF",
         "cyan", "#7FFF7F", "yellow",
         "#FF7F00", "red", "#7F0000")
flawed <- ggplot(no2, aes(month,
                          factor(station_id),
                          fill = value)) +
  geom_tile(colour = "white", linewidth = 1) +
  geom_text(aes(label = sprintf("%.2f",
                                value)),
            size = 2.5) +
  scale_fill_gradientn(colours = jet) +
  labs(title = "Air Quality Data",
       x = "month", y = "stazione_id") +
  theme_grey()
flawed
ggsave("flawed_chart.png", flawed, width = 8,
       height = 3.6, dpi = 200)
## << e2_flawed

# ---- Step 2: your redesign ------------------------------------------------------
# Useful facts (check them in data/README.md):
#  * station names: air has a column "station" (Liguria, Marche, Pascal, ...)
#  * NO2 is in ug/m3 (micrograms per cubic metre); the file covers WORKING
#    DAYS only (no weekends, no public holidays) -> say so in the caption
#  * "days" = number of days with a value in each station-month
#
# Decide first (write it down in the template):
#  1. What is the ONE message? -> it becomes the title (a sentence)
#  2. Which chart form fits that message? A heatmap? Lines? Small multiples?
#  3. Which colour scale fits the data: sequential, diverging or categorical?
#     If diverging: what is the meaningful midpoint?

no2_named <- air |>
  filter(pollutant == "NO2") |>
  mutate(month = month(date)) |>                 # 1..12: calendar order
  group_by(station, month) |>
  summarise(no2 = mean(value), days = n(), .groups = "drop")

redesign <- ggplot(no2_named, aes(x = month, y = no2)) +   # TODO: your encoding
  geom_point() +                                           # TODO: your geom(s)
  # TODO: a colour scale that fits the data, e.g. scale_fill_viridis_c(),
  #       scale_fill_distiller(palette = "Blues", direction = 1),
  #       scale_colour_manual(values = c(...)) with Okabe-Ito colours
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  labs(title = "TODO: one sentence that states the finding",
       subtitle = "TODO: what is shown, in plain words",
       x = NULL, y = "TODO: variable (unit)",
       caption = paste("Source: Comune di Milano open data (CC BY 4.0).",
                       "TODO: what else must the reader know?")) +
  theme_minimal(base_size = 11)
redesign
ggsave("redesign.png", redesign, width = 8, height = 4.5, dpi = 300, bg = "white")

# ---- Step 3: check it -------------------------------------------------------------
cvd_check("redesign.png")     # opens nothing: look at redesign_cvd.png
cvd_check("flawed_chart.png") # compare: what happens to the rainbow?

# Before you submit (Deliverable B checklist):
#  [ ] the title states the message; units, source and "working days only" shown
#  [ ] months in calendar order; stations named, ordered by something meaningful
#  [ ] colour scale type matches the data (sequential / diverging / categorical)
#  [ ] readable in redesign_cvd.png (deuteranopia, protanopia, greyscale)
#  [ ] text has enough contrast; no false precision (how many decimals?)
#  [ ] every change explained with a principle in DeliverableB_Template.docx
