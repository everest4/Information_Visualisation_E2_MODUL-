# =============================================================================
#  Information Visualization -- Lecture 2: design, colour and chart choice (R)
#  Modul University Vienna, Fall 2026 -- Daniel Dan, PhD
#
#  HOW TO RUN (RStudio):
#   1. Double-click "Lecture 2.Rproj": RStudio opens in the right folder.
#      (Posit Cloud: open the project "Information Visualization"; the files
#       are already in the right place.)
#   2. Open this file from the Files pane (bottom right).
#   3. Put the cursor on a line and press Ctrl+Enter (Mac: Cmd+Enter) to run
#      it; the chart appears in the Plots pane. "Source" runs the whole file.
#  New packages this week (colorspace, png): open setup/install_R_packages.R
#  and click "Source" once. It only installs what is missing.
#
#  Figures are written to fig/r/.
#  Data (see data/README.md):
#   data/milan_air_2021.csv      Comune di Milano open data (CC BY 4.0)
#   data/bologna_airbnb_2022.csv Comune di Bologna / Inside Airbnb (CC BY 4.0)
#
#  Lines between "## >> name" and "## << name" are shown on the slides.
# =============================================================================

# ---- house style (same palette and look as the Python script) ---------------
font_family <- local({
  ok <- capabilities("cairo") &&                  # custom fonts need cairo
        requireNamespace("systemfonts", quietly = TRUE) &&
        "Source Sans 3" %in% systemfonts::system_fonts()$family
  if (ok) "Source Sans 3" else ""          # fall back to the default sans font
})

theme_modul <- function(base_size = 11) {
  ggplot2::theme_minimal(base_size = base_size, base_family = font_family) +
    ggplot2::theme(
      panel.grid.minor   = ggplot2::element_blank(),
      panel.grid.major   = ggplot2::element_line(colour = "grey90", linewidth = 0.3),
      axis.title         = ggplot2::element_text(colour = "grey30"),
      axis.text          = ggplot2::element_text(colour = "grey35"),
      plot.title         = ggplot2::element_text(face = "bold", colour = "grey10"),
      plot.subtitle      = ggplot2::element_text(colour = "grey35"),
      plot.title.position = "plot",
      plot.caption       = ggplot2::element_text(colour = "grey50", size = base_size * 0.7,
                                                 hjust = 0),
      plot.caption.position = "plot",
      legend.position    = "top",
      legend.justification = "left",
      strip.text         = ggplot2::element_text(face = "bold", hjust = 0, colour = "grey20")
    )
}

dir.create("fig/r", recursive = TRUE, showWarnings = FALSE)
save_fig <- function(plot, name, width = 4.2, height = 3) {
  # vector PDF for slides/reports, 300-dpi PNG for the web/Moodle
  pdf_dev <- if (capabilities("cairo")) grDevices::cairo_pdf else grDevices::pdf
  ggplot2::ggsave(file.path("fig/r", paste0(name, ".pdf")), plot,
                  width = width, height = height, device = pdf_dev)
  ggplot2::ggsave(file.path("fig/r", paste0(name, ".png")), plot,
                  width = width, height = height, dpi = 300, bg = "white")
}
src_mi <- "Source: Comune di Milano open data, 2021 (CC BY 4.0). Working days only."
src_bo <- "Source: Comune di Bologna open data / Inside Airbnb, 2022 (CC BY 4.0)"

## >> load
library(tidyverse)
library(scales)
air <- read_csv("data/milan_air_2021.csv")
bnb <- read_csv(
  "data/bologna_airbnb_2022.csv")
pm10 <- air |> filter(pollutant == "PM10")
## << load

# =============================================================================
# 1. Gestalt and hierarchy: direct labels, one highlight
# =============================================================================
## >> monthly
monthly <- pm10 |>
  mutate(month = month(date)) |>
  group_by(station, month) |>
  summarise(pm10 = mean(value),
            days = n(), .groups = "drop")
st_col <- c(Marche = "#E69F00",  # Okabe-Ito
  Pascal = "#56B4E9", Senato = "#009E73",
  Verziere = "#0072B2")
## << monthly

## >> direct_labels
library(ggrepel)
last <- filter(monthly, month == 12)
p_lab <- ggplot(monthly, aes(month, pm10,
                          colour = station)) +
  geom_line(linewidth = 0.9) +
  # proximity: the name sits next to its line
  geom_text_repel(data = last,
    aes(label = station), hjust = 0,
    direction = "y", xlim = c(12.4, NA)) +
  scale_colour_manual(values = st_col,
                      guide = "none") +
  scale_x_continuous(breaks = 1:12,
                     labels = month.abb) +
  expand_limits(x = 14, y = 0) +
  labs(x = NULL,
       y = "PM10, monthly mean (µg/m³)")
## << direct_labels
p_lab$layers[[2]]$aes_params$family <- font_family
p_lab$layers[[2]]$aes_params$size <- 3.2
p_lab <- p_lab + labs(caption = src_mi) + theme_modul()
save_fig(p_lab, "direct_labels", 4.4, 3)

## >> highlight
focus <- "Senato"
p_hi <- ggplot(monthly, aes(month, pm10,
                          group = station)) +
  geom_line(colour = "grey80",
            linewidth = 0.7) +
  geom_line(data = filter(monthly,
                          station == focus),
            colour = "#CC071E",
            linewidth = 1.4) +
  scale_x_continuous(breaks = 1:12,
                     labels = month.abb) +
  expand_limits(y = 0) +
  labs(title = "Senato: highest most months",
       x = NULL, y = "PM10 (µg/m³)")
## << highlight
p_hi <- p_hi +
  annotate("text", x = 12.3, y = 61.4, label = "Senato", hjust = 0,
           colour = "#CC071E", fontface = "bold", size = 3.3, family = font_family) +
  annotate("text", x = 12.3, y = 44, label = "3 other\nstations", hjust = 0,
           colour = "grey55", size = 3, lineheight = 0.9, family = font_family) +
  expand_limits(x = 13.5) +
  labs(title = "Via Senato has the highest PM10 in most months", caption = src_mi) +
  theme_modul()
save_fig(p_hi, "highlight", 4.4, 3)

# =============================================================================
# 2. Colour scales: sequential and diverging (calendar heatmap, one station)
# =============================================================================
## >> calendar_grid
senato <- pm10 |>
  filter(station == "Senato") |>
  # every working day of 2021, NA = no value
  right_join(tibble(date = seq(
    ymd("2021-01-04"), ymd("2021-12-31"),
    by = "day")), by = "date") |>
  filter(wday(date, week_start = 1) <= 5) |>
  mutate(week = isoweek(date),
         day = wday(date, label = TRUE,
                    week_start = 1))
## << calendar_grid

## >> sequential
p_seq <- ggplot(senato,
                aes(week, fct_rev(day),
                    fill = value)) +
  geom_tile(colour = "white") +
  scale_fill_viridis_c(
    option = "magma", direction = -1,
    name = "PM10 (µg/m³)",
    na.value = "grey85") +
  labs(x = "Week of 2021", y = NULL)
## << sequential
cal_theme <- theme_modul(10) + theme(panel.grid = element_blank(),
                                     legend.key.height = unit(3, "mm"),
                                     legend.key.width = unit(12, "mm"),
                                     legend.title = element_text(size = 8, colour = "grey30"))
p_seq <- p_seq + scale_x_continuous(breaks = seq(1, 52, 4), expand = c(0, 0)) +
  labs(title = "Sequential: how high is PM10 each working day?",
       caption = paste(src_mi, "Grey gaps = no value.")) + cal_theme
save_fig(p_seq, "calendar_seq", 7.2, 2.5)

## >> diverging
p_div <- p_seq +
  scale_fill_gradient2(
    low = "#2166AC", mid = "white",
    high = "#B2182B", midpoint = 50,
    name = "PM10 (µg/m³)",
    na.value = "grey85") +
  labs(subtitle =
    "White = EU daily limit (50 µg/m³)")
## << diverging
p_div <- p_div + labs(title = "Diverging: is PM10 above or below the EU daily limit?")
save_fig(p_div, "calendar_div", 7.2, 2.7)

n_above <- senato |> summarise(n = sum(value > 50, na.rm = TRUE), days = sum(!is.na(value)),
                               slots = n())
message("Senato: ", n_above$n, " of ", n_above$days, " measured working days above 50 ug/m3 (",
        n_above$slots, " working days in the grid)")

# =============================================================================
# 3. Choosing the chart: Bologna Airbnb prices by neighbourhood
# =============================================================================
## >> pie_numbers
# What the flawed pie chart shows:
# each mean as a share of the sum of means
bnb |>
  group_by(neighbourhood) |>
  summarise(mean = mean(price_eur)) |>
  mutate(share = mean / sum(mean))
## << pie_numbers

## >> price_summary
price_sum <- bnb |>
  group_by(neighbourhood) |>
  summarise(n = n(),
            q1 = quantile(price_eur, 0.25),
            med = median(price_eur),
            q3 = quantile(price_eur, 0.75))
price_sum
## << price_summary

## >> dot_median
p_dot <- ggplot(price_sum, aes(med,
         reorder(neighbourhood, med))) +
  geom_linerange(aes(xmin = q1, xmax = q3),
                 linewidth = 2.2,
                 colour = "grey80") +
  geom_point(size = 3, colour = "#354B7D") +
  geom_text(aes(x = q3,
                label = paste0("n = ", n)),
            hjust = -0.2, size = 3) +
  scale_x_continuous(labels = label_dollar(
    prefix = "€"), limits = c(0, 175)) +
  labs(x = "Price per night: median and IQR",
       y = NULL)
## << dot_median
p_dot <- ggplot(price_sum, aes(med, reorder(neighbourhood, med))) +
  geom_linerange(aes(xmin = q1, xmax = q3), linewidth = 2.2, colour = "grey80") +
  geom_point(size = 3, colour = "#354B7D") +
  geom_text(aes(x = q3, label = paste0("n = ", n)), hjust = -0.2, size = 2.9,
            colour = "grey40", family = font_family) +
  scale_x_continuous(labels = label_dollar(prefix = "€"), limits = c(0, 175),
                     expand = c(0, 0)) +
  labs(title = "Typical prices differ by up to €36 a night",
       subtitle = "Dot = median, bar = middle 50% of listings",
       x = "Price per night (€)", y = NULL, caption = src_bo) +
  theme_modul() + theme(panel.grid.major.y = element_blank())
save_fig(p_dot, "dot_median", 4.6, 2.9)

## >> histogram
# Bin width changes the story: try 3 values
p_h <- bnb |>
  filter(price_eur <= 400) |>
  ggplot(aes(price_eur)) +
  geom_histogram(binwidth = 10,
                 boundary = 0,
                 fill = "#354B7D",
                 colour = "white") +
  labs(x = "Price per night (€), <= 400",
       y = "Listings")
## << histogram
bw_panel <- function(bw) {
  bnb |> filter(price_eur <= 400) |>
    ggplot(aes(price_eur)) +
    geom_histogram(binwidth = bw, boundary = 0, fill = "#354B7D",
                   colour = if (bw < 5) NA else "white", linewidth = 0.2) +
    labs(title = paste0("binwidth = ", bw, " €"), x = "Price per night (€)", y = "Listings") +
    theme_modul(9)
}
library(patchwork)
share_le_400 <- round(100 * mean(bnb$price_eur <= 400))
p_bins <- (bw_panel(2) | bw_panel(10) | bw_panel(50)) +
  plot_annotation(caption = paste(src_bo, paste0("- listings up to €400 (", share_le_400, "% of all)")),
                  theme = theme_modul(9))
save_fig(p_bins, "histogram_bins", 7.2, 2.4)

## >> boxplot
p_box <- ggplot(bnb, aes(price_eur,
    reorder(neighbourhood, price_eur,
            FUN = median))) +
  geom_jitter(height = 0.25, size = 0.3,
              alpha = 0.15) +
  geom_boxplot(fill = NA, outlier.shape = NA,
               colour = "#CC071E") +
  scale_x_log10(labels = label_dollar(
    prefix = "€")) +
  labs(x = "Price per night (€, log scale)",
       y = NULL)
## << boxplot
p_box <- p_box + labs(caption = src_bo) + theme_modul() +
  theme(panel.grid.major.y = element_blank())
save_fig(p_box, "boxplot", 4.6, 3)

# =============================================================================
# 4. Small multiples: same scale, one panel per station, a reference line
# =============================================================================
## >> facets
p_fac <- ggplot(pm10, aes(date, value)) +
  geom_line(linewidth = 0.3,
            colour = "grey40") +
  geom_hline(yintercept = 50,
             colour = "#CC071E") +
  facet_wrap(~ station, ncol = 2) +
  labs(x = NULL,
       y = "PM10, daily (µg/m³)")
## << facets
p_fac <- p_fac +
  scale_x_date(date_breaks = "3 months", date_labels = "%b") +
  labs(title = "Exceedances cluster in winter at all four stations",
       subtitle = "Red line: EU daily limit, 50 µg/m³ (max. 35 days a year)",
       caption = src_mi) +
  theme_modul(10)
save_fig(p_fac, "facets", 5.6, 3.3)

## >> palette_check
# Does the palette survive colour blindness?
library(colorspace)
pal <- c("#E69F00", "#56B4E9", "#009E73",
         "#0072B2", "#D55E00", "#CC79A7")
swatchplot(pal, cvd = TRUE)
## << palette_check

## >> cvd_chart
# A whole chart (any PNG file):
source("cvd_tools.R")
cvd_check("fig/r/calendar_div.png")
# -> writes fig/r/calendar_div_cvd.png
## << cvd_chart

message("Done: figures written to fig/r/")
