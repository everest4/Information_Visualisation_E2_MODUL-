"""
Information Visualization -- setup check (Python track)

The setup scripts run this file automatically. You can also run it yourself:
in JupyterLab open a Terminal (File > New > Terminal) and type
    python setup/check_setup.py
It checks the packages, finds the course data and draws one test chart.
"""
import importlib
import sys
from pathlib import Path

LECTURE_DIR = Path(__file__).resolve().parent.parent
PACKAGES = ["pandas", "numpy", "matplotlib", "seaborn", "plotly", "altair",
            "jupyterlab", "adjustText", "geopandas", "folium", "streamlit"]

print("\nInformation Visualization - checking your Python setup")
print("-" * 56)
print(f"Python {sys.version.split()[0]}  ({sys.executable})")

problems = 0
for name in PACKAGES:
    try:
        mod = importlib.import_module(name)
        print(f"  [OK]      {name:<11} {getattr(mod, '__version__', '')}")
    except Exception as err:            # noqa: BLE001  (show any import error)
        problems += 1
        print(f"  [MISSING] {name:<11} -> {err}")

# any course data set will do: each lecture folder ships its own
COURSE_DATA = ["milan_air_2021.csv", "owid_co2_1950_2024.csv"]
found = [LECTURE_DIR / "data" / f for f in COURSE_DATA
         if (LECTURE_DIR / "data" / f).exists()]
if found:
    data = found[0]
    print(f"  [OK]      course data found: {data.name}")
else:
    problems += 1
    print(f"  [MISSING] course data: no data folder next to {LECTURE_DIR / 'setup'}")

if problems == 0:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import pandas as pd

    d = pd.read_csv(data)
    fig, ax = plt.subplots(figsize=(5, 3))
    if data.name.startswith("milan"):
        d = d[(d["pollutant"] == "PM10") & (d["station"] == "Senato")]
        ax.plot(pd.to_datetime(d["date"]), d["value"], color="#CC071E", lw=1)
        ax.set(title="It works! Milan, PM10 at via Senato (µg/m³)", ylim=(0, None))
    else:
        d = d.query("country == 'Austria'")
        ax.plot(d["year"], d["co2_t_per_capita"], color="#CC071E", lw=2)
        ax.set(title="It works! Austria, CO2 per person (t)", ylim=(0, None))
    out = LECTURE_DIR / "setup" / "setup_test.png"
    fig.savefig(out, dpi=150, bbox_inches="tight")
    print(f"  [OK]      test chart saved: {out}")
    print("-" * 56)
    print("ALL GOOD. Your Python setup is ready for the course.\n")
else:
    print("-" * 56)
    print(f"{problems} problem(s) found. Run the setup script again; if the problem")
    print("stays, bring a screenshot of this window to the exercise session.\n")
    sys.exit(1)
