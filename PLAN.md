# Master Plan — BITS ZG522 Assignment 1

## Topic
NYC Yellow Taxi Trip Analytics on a Hadoop pseudo-cluster.

## Dataset
- Source: NYC Taxi & Limousine Commission — public monthly Parquet
- Window: **Jan / Feb / Mar 2024** (~9.5 M rows, ~985 MB CSV once expanded)
- Portal: https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

## Stack (locked)

| Layer | Tool | Notes |
|---|---|---|
| Distributed storage | HDFS (Hadoop 3.2.1) | Single-node pseudo-cluster |
| Ingestion | curl + pyarrow (Parquet → CSV) + `hdfs dfs -put` | Partition layout: `/raw/trips/year=YYYY/month=MM/` |
| ETL | Apache Pig 0.17 | Compiles to MR — cleanse + enrich + zone JOIN |
| Native MR | Hadoop Streaming (Python) | Explicit map/reduce for the viva |
| Analytics | Apache Hive 3.1.3 | 5 business queries on the enriched fact table |
| Serving | Apache HBase 2.4.18 | Random-access zone dimension |
| Presentation | Streamlit + Plotly | Local dashboard on port 8501 |

## RAM budget (4 GB VM)

Services never run concurrently — Hive and HBase share too much memory to co-exist. Streamlit runs after Hadoop can be stopped (its inputs are already exported to local FS).

## Phase timeline

| # | Phase | Owner |
|---|---|---|
| 0.5 | Env verification + config fixes | Dhruv |
| 1 | Install Pig / Hive / HBase | Dhruv, Ramya, Sri Lalithya, Vishwa |
| 2 | Download + HDFS ingest | Sai Krishna Mohan |
| 3 | Pig ETL | Ramya |
| 4 | Native MR (Hadoop Streaming) | Sai Krishna Mohan |
| 5 | Hive analytics | Sri Lalithya |
| 6 | HBase demo | Manikandan |
| 7 | Streamlit dashboard | Vishwa |
| 8 | Report + presentation | Dhruv (compile) + Manikandan (deck) |

Detailed roster with registration numbers: see `TEAM-ASSIGNMENTS.md`.
Detailed step-by-step guides per phase: see `user-tasks/`.
