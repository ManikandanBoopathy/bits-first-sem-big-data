# Project Plan

## Topic

NYC Yellow Taxi Trip Analytics on a Hadoop pseudo-cluster.

## Dataset

- Source: NYC Taxi & Limousine Commission — public monthly Parquet files
- Window used: **January, February, March 2024**
- Volume: 9,554,778 raw rows / ~150 MB Parquet / ~985 MB CSV after conversion
- Zone lookup: 265 rows (`taxi_zone_lookup.csv`, 12 KB)

## Stack

| Layer | Tool | Purpose |
|---|---|---|
| Storage | HDFS (Hadoop 3.2.1) | Distributed storage on a single-node pseudo-cluster |
| Ingestion | `curl` + pyarrow (Parquet → CSV) + `hdfs dfs -put` | Partitioned HDFS layout `/raw/trips/year=YYYY/month=MM/` |
| ETL | Apache Pig 0.17 | Row-level cleansing, derived features, zone JOIN |
| Native MapReduce | Hadoop Streaming (Python) | `trips-per-zone-per-hour` aggregation |
| Analytics | Apache Hive 3.1.3 | Five business queries (hotspots, revenue, congestion, airports, payment) |
| Serving | Apache HBase 2.4.18 | Random-access zone dimension |
| Presentation | Streamlit + Plotly | Interactive dashboard on port 8501 |

## RAM budget (4 GB VM)

Services do not run concurrently — Hive and HBase together exceed the 4 GB budget. Streamlit runs against exported CSVs on the local FS, so Hadoop is stopped for the presentation layer.

## Pipeline phases and ownership

| # | Phase | Owner | HDFS output |
|---|---|---|---|
| 0.5 | Environment verification + config fixes | Dhruv | — |
| 1 | Install Pig / Hive / HBase | Dhruv | — |
| 2 | Download + HDFS ingestion | Sai Krishna Mohan | `/raw/trips/…`, `/raw/zone_lookup/` |
| 3 | Pig ETL (cleanse + enrich) | Ramya | `/clean/trips`, `/clean/trips_enriched` |
| 4 | Native Hadoop Streaming MR | Sai Krishna Mohan | `/results/trips_per_zone_hour` |
| 5 | Hive analytics (5 queries) | Sri Lalithya | `/results/hive/q1..q5` |
| 6 | HBase (NoSQL zone lookup) | Manikandan | HBase tables `zone_lookup`, `trip_by_zone` |
| 7 | Streamlit dashboard | Vishwa | (local FS) `dashboard/data/*.csv` |
| 8 | Report + presentation | Dhruv (compile) · Manikandan (deck) | `report/` |

Detailed method notes for each phase are under `phases/`. Full team roster is in `TEAM-ASSIGNMENTS.md`.
