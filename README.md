# BITS ZG522 · Big Data Systems · Assignment 1

**Domain:** Transportation — NYC Yellow Taxi trip analytics  
**Dataset:** TLC Yellow Taxi, January–March **2026** (~11.1M raw rows → 7.8M after Pig cleansing)

## Team

| Role | Name | Registration No. |
|---|---|---|
| Group Leader | Dhruv Kumar | 2026NS03024 |
| Presentation Coordinator | Manikandan B | 2026NS03009 |
| Member | Parepalli Venkata Sai Krishna Mohan | 2026NS03066 |
| Member | Ramya K | 2026NS03046 |
| Member | Varada Sri Lalithya | 2026NS03089 |
| Member | Vishwa Vajendra M | 2026NS03076 |

## What this repository contains

End-to-end Hadoop pipeline on a single-node pseudo-cluster (Ubuntu 22.04, 4 GB RAM): HDFS ingestion, Pig ETL, Hadoop Streaming MapReduce, Hive analytics (five business queries), HBase zone serving, and a Streamlit dashboard.

| Path | Purpose |
|---|---|
| [`phases/`](phases/) | Phase 0–7 execution notes (what we ran, in order) |
| [`scripts/`](scripts/) | Configs, ingest, Pig, MapReduce, Hive SQL, HBase |
| [`user_output/`](user_output/) | Logs and run evidence per phase |
| [`report/`](report/) | Written report (Word + theory source) |
| [`dashboard/`](dashboard/) | Streamlit app + exported Hive CSVs |
| [`reference/`](reference/) | Schema, zone lookup, sample rows |
| [`diagrams/`](diagrams/) | Architecture diagram |

## How to read it

1. Skim [`PLAN.md`](PLAN.md) for stack and HDFS layout.  
2. Follow [`phases/00-…`](phases/) through [`phases/07-…`](phases/) in order.  
3. Cross-check commands against [`scripts/`](scripts/).  
4. Validate results in [`user_output/`](user_output/) and [`report/Assignment-1-Report-2026.docx`](report/Assignment-1-Report-2026.docx).

Large raw Parquet/CSV files are **not** stored in git; only scripts, small samples, and run artifacts are versioned.

## Environment (reference VM)

| Component | Version |
|---|---|
| Hadoop | 3.2.1 (pseudo-distributed) |
| Pig | 0.17.0 |
| Hive | 3.1.3 |
| HBase | 2.4.18 (standalone) |
| Python | 3.10+ |
| Streamlit | 1.30+ |

Data: [NYC TLC trip record data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page).
