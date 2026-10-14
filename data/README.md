# Lecture 2 data

Both files are local snapshots, so the code gives the same result in class, at home and on
Posit Cloud. They are the datasets used by Cremonini (2025), *Data Visualization in R and
Python*, Ch. 2-4 and 6, with English column names.

## `milan_air_2021.csv`: air quality in Milan, 2021

| column | meaning |
|---|---|
| `date` | day of the measurement (YYYY-MM-DD) |
| `station_id` | station number used by the City of Milan |
| `station` | station name: Pascal (via Pascal, Citta Studi), Liguria (viale Liguria), Marche (viale Marche), Senato (via Senato), Verziere |
| `pollutant` | C6H6 (benzene), CO_8h (carbon monoxide, 8-hour), NO2, O3, PM10, PM25 (PM2.5), SO2 |
| `value` | the daily value published by the city |
| `unit` | `ug/m3` = micrograms per cubic metre (µg/m³); `mg/m3` for CO |

- **Source:** Comune di Milano, Open Data, *Rilevazione qualità aria 2021* (dataset ds413), and
  *Stazioni monitoraggio inquinanti* for the station names. Licence: CC BY 4.0. The
  measurements come from ARPA Lombardia's monitoring network.
- **Working days only.** The city publishes values for working days only, so weekends and public
  holidays are missing (240 of 365 days). Any count such as "days above the limit" is a count of
  *measured working days*. Say so in your charts.
- **Missing values** were removed. The number of days behind each average differs by station and
  month (column `days` in the examples).
- **Units.** The portal states µg/m³ for every pollutant. CO values (about 0.5 to 2) are
  consistent with mg/m³, the usual unit for CO, so `unit` says `mg/m3` for CO_8h.
- **What "value" is.** The portal does not document the daily statistic for each pollutant.
  For PM10 it is the daily mean, the basis of the EU limit. For NO2 and O3 it may be a daily
  maximum. In Deliverable B, call the NO2 variable "NO2, daily value (µg/m³)" and do not
  compare it with annual limits.
- **Reference values for PM10** (used in the lecture):
  - EU daily limit of 50 µg/m³, to be exceeded on no more than 35 days a year (Directive
    2008/50/EC).
  - From 2030: 45 µg/m³, at most 18 days (Directive (EU) 2024/2881).
  - WHO 2021 guideline: 45 µg/m³ (24-hour) and 15 µg/m³ (annual).

## `bologna_airbnb_2022.csv`: Airbnb listings in Bologna, September 2022

| column | meaning |
|---|---|
| `id` | listing id |
| `neighbourhood` | one of six city districts (quartieri) |
| `room_type` | Entire home/apt, Private room, Hotel room, Shared room |
| `price_eur` | advertised price per night, in euro |
| `minimum_nights`, `number_of_reviews`, `reviews_per_month`, `availability_365`, `last_review` | as published |
| `lat`, `lon` | approximate location (Airbnb blurs the exact position) |

- **Source:** Comune di Bologna, Open Data, *Bologna: rilevazione Airbnb*, adapted from Inside
  Airbnb (insideairbnb.com). Licence: CC BY 4.0. The latest review is dated 14 Sep 2022.
- **Outliers.**
  - 44 listings ask €1,000 or more per night, and 8 ask €9,999 or more. These are typically
    placeholder prices.
  - They move **means** a lot and **medians** hardly at all.
  - One Savena listing at €15,960 lifts Savena's mean from about €77 to €170.

## Rebuilding (instructor)

`python prepare_l2_data.py` rebuilds both files from the original downloads in `data/raw/`.
