# =============================================================================
#  Exercise E2: Redesign sprint  (Python track)
#  Information Visualization, Modul University Vienna, Fall 2026
#
#  Deliverable B: redesign ONE flawed chart (below) with appropriate colour
#  scales and encodings, and explain every change with a design principle.
#
#  Easiest: open E2_starter.ipynb in JupyterLab (Start_JupyterLab_...) and run
#  the cells with Shift+Enter. Or, in a terminal:  python E2_starter.py
#  Step 1 draws the flawed chart. Step 2 is yours: replace every TODO.
#  Step 3 checks your redesign for colour blindness and greyscale.
# =============================================================================
# %%
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from cvd_tools import cvd_check          # colour-blindness check

air = pd.read_csv("data/milan_air_2021.csv", parse_dates=["date"])

# %% Step 1: the flawed chart
## >> e2_flawed
# Run it as it is: do not fix it here
no2 = (air[air["pollutant"] == "NO2"]
       .assign(month=lambda d:
               d["date"].dt.strftime("%b"))
       .groupby(["station_id", "month"])
       ["value"].mean()
       .unstack())        # columns sorted A-Z

fig, ax = plt.subplots(figsize=(8, 3.6))
sns.heatmap(no2, cmap="jet", annot=True,
            fmt=".2f", linewidths=1, ax=ax,
            annot_kws={"size": 7,
                       "color": "black"})
ax.set(title="Air Quality Data",
       xlabel="month", ylabel="stazione_id")
fig.savefig("flawed_chart.png", dpi=200,
            bbox_inches="tight")
plt.show()
## << e2_flawed

# %% Step 2: your redesign
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
no2_named = (air[air["pollutant"] == "NO2"]
             .assign(month=lambda d: d["date"].dt.month)      # 1..12: calendar order
             .groupby(["station", "month"], as_index=False)
             .agg(no2=("value", "mean"), days=("value", "size")))

fig, ax = plt.subplots(figsize=(8, 4.5))
sns.scatterplot(no2_named, x="month", y="no2", ax=ax)          # TODO: your chart form
# TODO: a colour scale that fits the data, e.g. cmap="viridis" / "Blues",
#       palette="colorblind" (Okabe-Ito-like), or a list of hex colours
ax.set_xticks(range(1, 13), ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                             "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
ax.set_title("TODO: one sentence that states the finding", loc="left",
             fontweight="bold")
ax.set(xlabel="", ylabel="TODO: variable (unit)")
fig.text(0.01, -0.02, "Source: Comune di Milano open data (CC BY 4.0). "
         "TODO: what else must the reader know?", fontsize=8, color="grey")
fig.savefig("redesign.png", dpi=300, bbox_inches="tight", facecolor="white")
plt.show()

# %% Step 3: check it
cvd_check("redesign.png")       # look at redesign_cvd.png
cvd_check("flawed_chart.png")   # compare: what happens to the rainbow?

# Before you submit (Deliverable B checklist):
#  [ ] the title states the message; units, source and "working days only" shown
#  [ ] months in calendar order; stations named, ordered by something meaningful
#  [ ] colour scale type matches the data (sequential / diverging / categorical)
#  [ ] readable in redesign_cvd.png (deuteranopia, protanopia, greyscale)
#  [ ] text has enough contrast; no false precision (how many decimals?)
#  [ ] every change explained with a principle in DeliverableB_Template.docx
