# BITS ZG522 · Big Data Systems · Assignment 1

**Domain:** Transportation — NYC Yellow Taxi Trip Analytics
**Group Assignment · 6 members · 20 marks**

## Team

| Role | Name | Registration No. |
|---|---|---|
| Group Leader | Dhruv Kumar | 2026NS03024 |
| Presentation Coordinator | Manikandan B | 2026NS03009 |
| Member | Parepalli Venkata Sai Krishna Mohan | 2026NS03066 |
| Member | Ramya K | 2026NS03046 |
| Member | Varada Sri Lalithya | 2026NS03089 |
| Member | Vishwa Vajendra M | 2026NS03076 |

## Overview

An end-to-end Big Data pipeline built on a single-node Hadoop 3.2.1 pseudo-cluster (Ubuntu 22.04, 4 GB RAM VM). The pipeline ingests three months of NYC TLC Yellow Taxi trip data (~9.5 M rows / ~985 MB CSV), cleans and enriches via Apache Pig, aggregates with a native Hadoop Streaming MapReduce job, executes five analytical queries in Apache Hive, exposes a zone dimension via Apache HBase for random-access lookup, and renders the results as an interactive Streamlit dashboard.

## Repository layout

```
.
├── README.md
├── PLAN.md                          master plan and phase split
├── TEAM-ASSIGNMENTS.md              roster and ownership
├── .gitignore
│
├── phases/                          method notes per pipeline phase
│   └── 00-env-verification-and-config-fix.md
│
├── scripts/
│   ├── hadoop-conf/                 core / hdfs / mapred / yarn XML + bashrc
│   ├── ingest/                      download + parquet→csv
│   ├── pig/                         Pig Latin ETL scripts
│   ├── mapreduce/                   Hadoop Streaming mapper / reducer
│   ├── hive/                        DDL + analytics + export SQL
│   └── hbase/                       HBase shell + zone loader
│
├── report/                          Part A theory, presentation, viva Q&A
├── dashboard/                       Streamlit app
├── diagrams/                        architecture diagram
├── reference/                       dataset schema, zone lookup CSV, samples
└── user_output/                     per-phase terminal transcripts + screenshots
```

## Environment

| Component | Version |
|---|---|
| Host | VirtualBox 7.0.8 |
| VM OS | Ubuntu 22.04.5 (amd64 / arm64) |
| VM resources | 4 GB RAM, 60 GB disk, 3–4 vCPU |
| Java | OpenJDK 8 |
| Hadoop | 3.2.1 (pseudo-distributed) |
| Pig | 0.17.0 |
| Hive | 3.1.3 |
| HBase | 2.4.18 (standalone) |
| Python | 3.10 |
| Streamlit | 1.30+ |

## Data source

NYC TLC Yellow Taxi Trip Records — https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page. Public, monthly Parquet files. Three months used for this assignment: Jan / Feb / Mar 2024.
