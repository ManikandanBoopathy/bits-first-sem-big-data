# Team Assignments — 6 Members

**Assignment:** BITS CC ZG522 · Big Data Systems · Assignment 1
**Domain:** Transportation · **Dataset:** NYC TLC Yellow Taxi Trips

## Roster

| Role | Name | Registration No. |
|---|---|---|
| **Group Leader** | Dhruv Kumar | 2026NS03024 |
| **Presentation Coordinator** | Manikandan B | 2026NS03009 |
| Member | Parepalli Venkata Sai Krishna Mohan | 2026NS03066 |
| Member | Ramya K | 2026NS03046 |
| Member | Varada Sri Lalithya | 2026NS03089 |
| Member | Vishwa Vajendra M | 2026NS03076 |

## Ownership matrix

| Member | Theory (Part A) | VM execution | Extra |
|---|---|---|---|
| **Dhruv (Leader)** | §1 Introduction (domain, background, business problem) | Phase 0.5 — Env verification + Hadoop config fixes | Overall coordination · Final report compile · Demo lead |
| **Manikandan (Presenter)** | §2 Big Data Need Analysis (5 Vs, why RDBMS fails) | Phase 6 — HBase table creation, zone lookup load, scan/get demos | Presentation deck · Viva rehearsal driver |
| Sai Krishna Mohan | §3 Dataset Description | Phase 2 — Data download + HDFS ingest · Phase 4 — Native Hadoop Streaming MR | Data lineage story |
| Ramya | §4 Architecture (diagram walkthrough) | Phase 3 — Pig ETL (clean + enrich) | Pig→MR compilation explanation |
| Sri Lalithya | §5.a Tech selection — Hadoop / HDFS / MR / Pig | Phase 5 — Hive DDL, analytical HQL, EXPLAIN plans, result export | Why Hive over RDBMS pitch |
| Vishwa | §5.b Tech selection — Hive / HBase / Streamlit | Phase 7 — Streamlit dashboard | Dashboard demo in viva |

## Contribution principles

- Every member owns **one theory section** + **one execution phase**. Roughly equal workload.
- Every member captures screenshots for their own phase and pushes their own outputs under `user_output/<phase>/`.
- The phase owner writes the reproducible step-by-step guide first; the other members reproduce it on their own VMs.
- Faculty may cold-call any member on any phase in viva — every member should have read every guide.

## Phase-to-owner lookup

| Phase | Owner | Guide |
|---|---|---|
| 0.5 Env fix | Dhruv | `user-tasks/00-env-verification-and-config-fix.md` |
| 1 Install Pig/Hive/HBase | Dhruv + Ramya + Sri Lalithya + Vishwa | `user-tasks/01-install-pig-hive-hbase.md` |
| 2 Download + ingest | Sai Krishna Mohan | `user-tasks/02-download-and-ingest.md` |
| 3 Pig ETL | Ramya | `user-tasks/03-run-pig-etl.md` |
| 4 Native MR | Sai Krishna Mohan | `user-tasks/04-run-mapreduce.md` |
| 5 Hive analytics | Sri Lalithya | `user-tasks/05-run-hive.md` |
| 6 HBase demo | Manikandan | `user-tasks/06-run-hbase.md` |
| 7 Streamlit dashboard | Vishwa | `user-tasks/07-dashboard.md` |
| 8 Report + presentation | Dhruv (compile) · Manikandan (deck) | `my-work/report/` |
