# Pipeline phases (0–7)

Run in order on the Hadoop VM. Each file lists prerequisites, commands, and expected HDFS paths.

| File | Phase |
|---|---|
| [00-environment-and-hadoop-config.md](00-environment-and-hadoop-config.md) | Environment + Hadoop configuration |
| [01-install-pig-hive-hbase.md](01-install-pig-hive-hbase.md) | Install Pig, Hive, HBase |
| [02-download-and-ingest.md](02-download-and-ingest.md) | Download TLC data + HDFS ingest |
| [03-pig-etl.md](03-pig-etl.md) | Pig cleanse and enrich |
| [04-mapreduce.md](04-mapreduce.md) | Hadoop Streaming aggregation |
| [05-hive-analytics.md](05-hive-analytics.md) | Hive DDL and five queries |
| [06-hbase.md](06-hbase.md) | HBase serving layer |
| [07-streamlit-dashboard.md](07-streamlit-dashboard.md) | Streamlit dashboard |

Corresponding logs and captures: [`../user_output/`](../user_output/).
