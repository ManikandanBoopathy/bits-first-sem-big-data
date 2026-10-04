# Execution evidence

Artifacts from running the pipeline on the Hadoop VM (Ubuntu 22.04, 4 GB RAM).

| Folder | Phase | Contents |
|--------|-------|----------|
| `03/` | Pig ETL | `pig_01.log`, `pig_02.log`, YARN/Pig summary captures |
| `04/` | MapReduce | `terminal_output.txt`, job UI captures |
| `05/` | Hive | DDL/analytics/export logs and UI captures |
| `06/` | HBase | `hbase_create.log` |
| `07/` | Dashboard | Streamlit export PDF |

Phases 0–2 apply configuration and install components; validation appears in later-phase row counts and logs.
