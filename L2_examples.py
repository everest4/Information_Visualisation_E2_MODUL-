# =============================================================================
#  Information Visualization -- Lecture 2: design, colour and chart choice
#  in Python (pandas + matplotlib + seaborn)
#  Modul University Vienna, Fall 2026 -- Daniel Dan, PhD
#
#  EASIEST WAY TO RUN: double-click Start_JupyterLab_Mac.command (Mac) or
#  Start_JupyterLab_Windows.bat (Windows), open L2_examples.ipynb (the same
#  code as a notebook) and press Shift+Enter to run one cell after the other.
#  Or, in a terminal in the "Lecture 2" folder:   python L2_examples.py
#  Nothing new to install this week: the "infovis" environment from
#  Lecture 1 has everything.
#
#  Figures are written to fig/py/.
#  Data (see data/README.md):
#   data/milan_air_2021.csv      Comune di Milano open data (CC BY 4.0)
#   data/bologna_airbnb_2022.csv Comune di Bologna / Inside Airbnb (CC BY 4.0)
#
#  Lines between "## >> name" and "## << name" are shown on the slides.
# =============================================================================
# %% house style (same palette and look as the R script)
import sys
from pathlib import Path
import matplotlib as mpl

STATION_COLOURS = {"Marche": "#E69F00", "Pascal": "#56B4E9",
                   "Senato": "#009E73", "Verziere": "#0072B2"}
SRC_MI = "Source: Comune di Milano open data, 2021 (CC BY 4.0). Working days only."
SRC_BO = "Source: Comune di Bologna open data / Inside Airbnb, 2022 (CC BY 4.0)"
MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


def style_modul(base_size=11):
    """Minimal, ggplot-like house style. Falls back to DejaVu Sans if
    Source Sans 3 is not installed."""
    mpl.rcParams.update({
        "font.family": "sans-serif",
        "font.sans-serif": ["Source Sans 3", "DejaVu Sans"],
        "font.size": base_size,
        "axes.spines.top": False, "axes.spines.right": False,
        "axes.spines.left": False, "axes.spines.bottom": False,
        "axes.grid": True, "grid.color": "#E5E5E5", "grid.linewidth": 0.6,
        "axes.axisbelow": True,
        "axes.labelcolor": "#4D4D4D", "xtick.color": "#595959",
        "ytick.color": "#595959", "xtick.major.size": 0, "ytick.major.size": 0,
        "axes.titleweight": "bold", "axes.titlelocation": "left",
        "axes.titlesize": base_size,
        "axes.labelsize": base_size * 0.9,
        "xtick.labelsize": base_size * 0.8, "ytick.labelsize": base_size * 0.8,
        "legend.frameon": False,
        "pdf.fonttype": 42,            # embed TrueType: editable text in the PDF
        "savefig.bbox": "tight", "savefig.dpi": 300,
    })


Path("fig/py").mkdir(parents=True, exist_ok=True)
IN_NOTEBOOK = "ipykernel" in sys.modules


def save_fig(fig, name):
    """Vector PDF for slides/reports, 300-dpi PNG for the web/Moodle.
    In a notebook the chart is also shown below the cell."""
    fig.savefig(f"fig/py/{name}.pdf")
    fig.savefig(f"fig/py/{name}.png", facecolor="white")
    if IN_NOTEBOOK:
        from IPython.display import display
        display(fig)
    plt.close(fig)


def caption(fig, text, y=-0.02):
    fig.text(0.01, y, text, fontsize=7, color="#7F7F7F", ha="left", va="top")


style_modul()

## >> load
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
air = pd.read_csv("data/milan_air_2021.csv",
                  parse_dates=["date"])
bnb = pd.read_csv(
    "data/bologna_airbnb_2022.csv")
pm10 = air[air["pollutant"] == "PM10"]
## << load

# %% 1. Gestalt and hierarchy: direct labels, one highlight
## >> monthly
monthly = (pm10
    .assign(month=pm10["date"].dt.month)
    .groupby(["station", "month"],
             as_index=False)
    .agg(pm10=("value", "mean"),
         days=("value", "size")))
## << monthly

## >> direct_labels
from adjustText import adjust_text
fig, ax = plt.subplots(figsize=(4.4, 3))
labels = []
for st, d in monthly.groupby("station"):
    ax.plot(d["month"], d["pm10"], lw=1.8,
            color=STATION_COLOURS[st])
    # proximity: name next to its line
    labels.append(ax.text(
        12.4, d["pm10"].iloc[-1], st,
        color=STATION_COLOURS[st],
        va="center", fontsize=9))
adjust_text(labels, only_move={"text": "y"})
ax.set_xticks(range(1, 13), MONTHS)
ax.set(xlim=(0.6, 14), ylim=(0, None),
       ylabel="PM10, monthly mean (µg/m³)")
## << direct_labels
caption(fig, SRC_MI)
save_fig(fig, "direct_labels")

## >> highlight
focus = "Senato"
fig, ax = plt.subplots(figsize=(4.4, 3))
for st, d in monthly.groupby("station"):
    hit = st == focus
    ax.plot(d["month"], d["pm10"],
            color="#CC071E" if hit
                  else "#CCCCCC",
            lw=2.6 if hit else 1.2,
            zorder=3 if hit else 2)
ax.set_xticks(range(1, 13), MONTHS)
ax.set(ylim=(0, None), ylabel="PM10 (µg/m³)",
       title="Senato: highest most months")
## << highlight
ax.set_title("Via Senato has the highest PM10 in most months")
ax.text(12.3, 61.4, "Senato", color="#CC071E", weight="bold", va="center", fontsize=9)
ax.text(12.3, 44, "3 other\nstations", color="#8C8C8C", va="center", fontsize=8.5)
ax.set_xlim(0.6, 13.6)
caption(fig, SRC_MI)
save_fig(fig, "highlight")

# %% 2. Colour scales: sequential and diverging (calendar heatmap, one station)
## >> calendar_grid
# every working day of 2021, NaN = no value
days = pd.bdate_range("2021-01-04",
                      "2021-12-31")
senato = (pm10[pm10["station"] == "Senato"]
          .set_index("date")["value"]
          .reindex(days))
cal = pd.DataFrame({
    "week": days.isocalendar().week.values,
    "day": days.dayofweek,
    "pm10": senato.values})
grid = cal.pivot(index="day", columns="week",
                 values="pm10")
## << calendar_grid

## >> sequential
fig, ax = plt.subplots(figsize=(7.2, 2.3))
im = ax.pcolormesh(grid.columns, grid.index,
                   grid, cmap="magma_r",
                   edgecolors="white", lw=0.5)
fig.colorbar(im, label="PM10 (µg/m³)")
## << sequential
WEEKDAYS = ["Mon", "Tue", "Wed", "Thu", "Fri"]


def calendar_axes(ax, title):
    ax.set_facecolor("#D9D9D9")             # missing values show as grey
    ax.grid(False)
    ax.set_yticks(range(5), WEEKDAYS)
    ax.invert_yaxis()
    ax.set_xticks(range(1, 53, 4))
    ax.set_xlabel("Week of 2021")
    ax.set_title(title)


calendar_axes(ax, "Sequential: how high is PM10 each working day?")
caption(fig, SRC_MI + " Grey gaps = no value.", y=-0.06)
save_fig(fig, "calendar_seq")

## >> diverging
from matplotlib.colors import TwoSlopeNorm
fig, ax = plt.subplots(figsize=(7.2, 2.3))
im = ax.pcolormesh(grid.columns, grid.index,
    grid, cmap="RdBu_r", edgecolors="white",
    lw=0.5,
    # white = EU daily limit, 50 µg/m³
    norm=TwoSlopeNorm(vcenter=50, vmin=0,
                      vmax=140))
fig.colorbar(im, label="PM10 (µg/m³)")
## << diverging
calendar_axes(ax, "Diverging: is PM10 above or below the EU daily limit (50 µg/m³)?")
caption(fig, SRC_MI + " Grey gaps = no value.", y=-0.06)
save_fig(fig, "calendar_div")
print(f"Senato: {(senato > 50).sum()} of {senato.notna().sum()} measured working days "
      f"above 50 ug/m3 ({len(senato)} working days in the grid)")

# %% 3. Choosing the chart: Bologna Airbnb prices by neighbourhood
## >> pie_numbers
# What the flawed pie chart shows:
# each mean as a share of the sum of means
means = (bnb.groupby("neighbourhood")
         ["price_eur"].mean())
print((means / means.sum()).round(3))
## << pie_numbers

## >> price_summary
g = bnb.groupby("neighbourhood")["price_eur"]
s = pd.DataFrame({"n": g.size(),
                  "q1": g.quantile(0.25),
                  "med": g.median(),
                  "q3": g.quantile(0.75)}
                 ).sort_values("med")
print(s)
## << price_summary

## >> dot_median
fig, ax = plt.subplots(figsize=(4.6, 2.9))
ax.hlines(s.index, s["q1"], s["q3"], lw=6,
          color="#CCCCCC")
ax.plot(s["med"], s.index, "o", ms=8,
        color="#354B7D")
for name, r in s.iterrows():
    ax.text(r["q3"] + 3, name,
            f"n = {r['n']:.0f}",
            va="center", fontsize=8)
ax.set(xlim=(0, 175),
       xlabel="Price per night (€): "
              "median and IQR")
## << dot_median
ax.set_title("Typical prices differ by up to €36 a night")
ax.grid(axis="y", visible=False)
ax.xaxis.set_major_formatter(lambda v, _: f"€{v:.0f}")
ax.set_xlabel("Price per night (€). Dot = median, bar = middle 50% of listings", fontsize=9)
for t in ax.texts:
    t.set_color("#666666")
caption(fig, SRC_BO, y=-0.08)
save_fig(fig, "dot_median")

## >> histogram
# Bin width changes the story: try 3 values
fig, ax = plt.subplots(figsize=(3.5, 2.5))
sns.histplot(bnb[bnb["price_eur"] <= 400],
             x="price_eur", binwidth=10,
             binrange=(0, 400),
             color="#354B7D", ax=ax)
ax.set(xlabel="Price per night (€), <= 400",
       ylabel="Listings")
## << histogram
plt.close(fig)
fig, axs = plt.subplots(1, 3, figsize=(7.2, 2.3))
cheap = bnb[bnb["price_eur"] <= 400]
for ax, bw in zip(axs, [2, 10, 50]):
    sns.histplot(cheap, x="price_eur", binwidth=bw, binrange=(0, 400), color="#354B7D",
                 edgecolor="white", linewidth=0.1, alpha=1, ax=ax)
    ax.set(title=f"binwidth = {bw} €", xlabel="Price per night (€)", ylabel="Listings")
share = round(100 * (bnb["price_eur"] <= 400).mean())
fig.tight_layout()
caption(fig, f"{SRC_BO} - listings up to €400 ({share}% of all)", y=-0.03)
save_fig(fig, "histogram_bins")

## >> boxplot
order = (bnb.groupby("neighbourhood")
         ["price_eur"].median()
         .sort_values(ascending=False).index)
fig, ax = plt.subplots(figsize=(4.6, 3))
sns.stripplot(bnb, x="price_eur",
              y="neighbourhood", order=order,
              size=1, alpha=0.2, jitter=0.25,
              color="black", ax=ax)
sns.boxplot(bnb, x="price_eur",
            y="neighbourhood", order=order,
            fill=False, color="#CC071E",
            showfliers=False, ax=ax)
ax.set(xscale="log", ylabel=None,
       xlabel="Price per night (€, log)")
## << boxplot
ax.xaxis.set_major_formatter(lambda v, _: f"€{v:,.0f}")
ax.grid(axis="y", visible=False)
caption(fig, SRC_BO, y=-0.08)
save_fig(fig, "boxplot")

# %% 4. Small multiples: same scale, one panel per station, a reference line
## >> facets
g = sns.relplot(pm10, x="date", y="value",
                col="station", col_wrap=2,
                kind="line", color="#666666",
                linewidth=0.5, height=1.6,
                aspect=1.7)
g.refline(y=50, color="#CC071E", ls="-")
g.set_titles("{col_name}")
g.set_axis_labels("", "PM10, daily (µg/m³)")
## << facets
import matplotlib.dates as mdates
for ax in g.axes.flat:
    ax.xaxis.set_major_locator(mdates.MonthLocator(bymonth=[1, 4, 7, 10]))
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%b"))
    ax.title.set_fontweight("bold")
g.figure.suptitle("Exceedances cluster in winter at all four stations\n"
                  "Red line: EU daily limit, 50 µg/m³ (max. 35 days a year)",
                  x=0.02, ha="left", y=1.08, fontsize=10)
caption(g.figure, SRC_MI)
g.figure.savefig("fig/py/facets.pdf")
g.figure.savefig("fig/py/facets.png", facecolor="white")
if IN_NOTEBOOK:
    from IPython.display import display
    display(g.figure)
plt.close(g.figure)

## >> palette_check
# Does the palette survive colour blindness?
# helper in cvd_tools.py (this folder)
from cvd_tools import show_palette_cvd
pal = ["#E69F00", "#56B4E9", "#009E73",
       "#0072B2", "#D55E00", "#CC79A7"]
show_palette_cvd(pal)
## << palette_check
save_fig(plt.gcf(), "palette_cvd")

## >> cvd_chart
# A whole chart (any PNG file):
from cvd_tools import cvd_check
cvd_check("fig/py/calendar_div.png")
# -> writes fig/py/calendar_div_cvd.png
## << cvd_chart

print("Done: figures written to fig/py/")
