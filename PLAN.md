# Project plan

## Topic

NYC Yellow Taxi Trip Analytics — demand, revenue, congestion, airports, and payment behaviour.

## Dataset (this submission)

| Item | Value |
|---|---|
| Source | NYC TLC Yellow Taxi Parquet (public) |
| Months | Jan / Feb / Mar **2026** |
| Raw rows | 11,077,206 |
| Clean rows (after Pig) | 7,799,600 (~29.6% dropped — mostly null `passenger_count` + DQ rules) |
| CSV on HDFS | ~1.17 GB (19 columns; extra 2026 TLC fields stripped at ingest) |
| Zone lookup | 265 zones (`reference/taxi_zone_lookup.csv`) |

## Stack

| Layer | Tool | HDFS / output |
|---|---|---|
| Storage | HDFS | `/raw`, `/clean`, `/results` |
| Ingest | `download_and_ingest.sh` + `parquet_to_csv.py` | `/raw/trips/year=…/month=…/` |
| ETL | Apache Pig | `/clean/trips`, `/clean/trips_enriched` |
| MapReduce | Hadoop Streaming (Python) | `/results/trips_per_zone_hour` |
| Analytics | Hive | `taxi_analytics` DB + `/results/hive/q1…q5` |
| Serving | HBase | `zone_lookup`, `trip_by_zone` |
| UI | Streamlit | `dashboard/data/*.csv` |

## Phases (0–7)

| Phase | Topic | Method note | Evidence |
|---|---|---|---|
| 0 | Hadoop config for 4 GB VM | [`phases/00-environment-and-hadoop-config.md`](phases/00-environment-and-hadoop-config.md) | `scripts/hadoop-conf/` |
| 1 | Pig, Hive, HBase install | [`phases/01-install-pig-hive-hbase.md`](phases/01-install-pig-hive-hbase.md) | — |
| 2 | Download + HDFS ingest | [`phases/02-download-and-ingest.md`](phases/02-download-and-ingest.md) | — |
| 3 | Pig cleanse + enrich | [`phases/03-pig-etl.md`](phases/03-pig-etl.md) | [`user_output/03/`](user_output/03/) |
| 4 | Streaming MR | [`phases/04-mapreduce.md`](phases/04-mapreduce.md) | [`user_output/04/`](user_output/04/) |
| 5 | Hive DDL + 5 queries + export | [`phases/05-hive-analytics.md`](phases/05-hive-analytics.md) | [`user_output/05/`](user_output/05/) |
| 6 | HBase tables | [`phases/06-hbase.md`](phases/06-hbase.md) | [`user_output/06/`](user_output/06/) |
| 7 | Streamlit dashboard | [`phases/07-streamlit-dashboard.md`](phases/07-streamlit-dashboard.md) | [`user_output/07/`](user_output/07/) |

Team phase ownership is listed in [`TEAM-ASSIGNMENTS.md`](TEAM-ASSIGNMENTS.md).

## Business questions (Hive Q1–Q5)

1. Pickup hotspots by hour and zone  
2. Revenue by borough and payment type  
3. Slow PU→DO pairs (congestion signal)  
4. Airport trip profiles (JFK / LGA / EWR)  
5. Card vs cash share by borough  
