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

An end-to-end Big Data pipeline built on a single-node Hadoop 3.2.1 pseudo-cluster (Ubuntu 22.04, 4 GB RAM VM). Ingests 3 months of NYC TLC Yellow Taxi trip data (~9.5 M rows / ~985 MB), cleans and enriches via Apache Pig, aggregates with native Hadoop Streaming MapReduce, runs 5 analytical queries in Apache Hive, exposes a zone dimension via Apache HBase for random-access lookup, and renders results as an interactive Streamlit dashboard.

## Repository layout

```
.
├── README.md
├── PLAN.md                             ← master plan and phase split
├── TEAM-ASSIGNMENTS.md                 ← who owns what
├── .gitignore
├── user-tasks/                         ← step-by-step guides per phase
├── my-work/
│   ├── report/                         ← Part A theory + presentation + viva Q&A
│   ├── scripts/
│   │   ├── hadoop-conf/                ← core-, hdfs-, mapred-, yarn-site.xml + bashrc
│   │   ├── ingest/                     ← download + parquet→csv scripts
│   │   ├── pig/                        ← Pig Latin scripts
│   │   ├── mapreduce/                  ← native Hadoop Streaming (Python)
│   │   ├── hive/                       ← DDL + analytics + export SQL
│   │   └── hbase/                      ← HBase shell + zone loader
│   ├── dashboard/                      ← Streamlit app
│   └── diagrams/                       ← architecture diagram
├── reference/                          ← dataset schema, zone lookup CSV, samples
└── user_output/                        ← per-phase terminal transcripts + screenshots
```

## How the team collaborates

Six individual VMs (VirtualBox 7.0.8 + Ubuntu 22.04). Each phase has an owner who executes it first and writes the reproducible step-by-step guide under `user-tasks/`. The other members reproduce the phase on their own VMs for learning and viva readiness. Faculty may cold-call any member on any phase in the viva.

## Phase ownership

| Phase | Owner |
|---|---|
| 0.5 Environment verification + config fixes | Dhruv |
| 1 Install Pig / Hive / HBase | Dhruv + Ramya + Sri Lalithya + Vishwa |
| 2 Data download + HDFS ingestion | Sai Krishna Mohan |
| 3 Pig ETL (cleanse + enrich) | Ramya |
| 4 Native MapReduce (Hadoop Streaming) | Sai Krishna Mohan |
| 5 Hive analytics (5 business queries) | Sri Lalithya |
| 6 HBase (NoSQL zone lookup) | Manikandan |
| 7 Streamlit dashboard | Vishwa |
| Report compile + coordination | Dhruv |
| Presentation deck + viva rehearsal | Manikandan |

See `PLAN.md` and `TEAM-ASSIGNMENTS.md` for detail.
