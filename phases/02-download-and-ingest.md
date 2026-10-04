# Phase 2 — Download data and HDFS ingestion

Scripts for this phase live under `scripts/`. Execution evidence (logs and captures) is under `user_output/02/` when available.

**Time:** 20–30 minutes (mostly network-bound).
**Prerequisites:** Hadoop up (`jps` shows NN, DN, SNN, RM, NM).

## What we're doing

1. Downloading 3 months of NYC TLC Yellow Taxi data (Jan/Feb/Mar 2026) and the taxi zone lookup.
2. Converting each monthly Parquet to a headerless CSV.
3. Uploading everything into HDFS with a `year=/month=` partition layout that Hive will pick up in Phase 5.

Expected sizes on completion:
- Local staging: **~1.35 GB** (Parquet + CSV)
- HDFS `/raw`: **~1.17 GB** (CSV only, 19 columns)

**Schema note:** 2026 TLC Parquet includes an extra `cbd_congestion_fee` column. `parquet_to_csv.py` drops it so later Pig / MapReduce steps still see **19 fields per row**.

---

## Step 1 — Pull scripts from the shared repo

```bash
cd ~
# OR
```

The scripts we'll use live at:

- `scripts/ingest/download_and_ingest.sh`
- `scripts/ingest/parquet_to_csv.py`

Make the shell script executable:

```bash
chmod +x ~/bits-first-sem-big-data/scripts/ingest/download_and_ingest.sh
```

---

## Step 2 — Confirm Hadoop is healthy

```bash
jps
hdfs dfs -ls /
```

Expected `jps`:

```
NameNode
DataNode
SecondaryNameNode
ResourceManager
NodeManager
Jps
```

If anything missing, `$HADOOP_HOME/sbin/start-dfs.sh && $HADOOP_HOME/sbin/start-yarn.sh`.

---

## Step 3 — Install pyarrow (one-time)

```bash
pip3 install --user pyarrow pandas
python3 -c "import pyarrow; print(pyarrow.__version__)"
```

Expected: version string (e.g. `21.0.0`). If `pip3` missing:

```bash
sudo apt install -y python3-pip
```

---

## Step 4 — Run the ingest script

If you previously ingested **2024** data on this VM, remove stale paths first (otherwise Hive/Pig may still see old partitions under `/raw/trips`):

```bash
hdfs dfs -rm -r /raw/trips/year=2024 2>/dev/null || true
rm -f ~/staging/yellow_tripdata_2024-*.{parquet,csv}
```

```bash
cd ~/bits-first-sem-big-data
./scripts/ingest/download_and_ingest.sh
```

The script:
1. Downloads `taxi_zone_lookup.csv` (~12 KB)
2. Downloads three monthly parquet files (~48 MB each)
3. Converts each parquet to headerless CSV (~305 MB each)
4. `hdfs dfs -put` everything to `/raw/...`

Watch for progress lines like:

```
→ Downloading yellow_tripdata_2026-01.parquet...
→ Converting … → CSV...
    200,000 / 3,724,889 rows  (  5.4%)
    400,000 / 3,724,889 rows  ( 10.7%)
    ...
```

Total runtime: **10–20 minutes** on a home broadband connection.

---

## Step 5 — Verify HDFS state

```bash
hdfs dfs -ls -R /raw | head -20
```

Expected:

```
drwxr-xr-x   - hdoop supergroup  0 ... /raw/trips
drwxr-xr-x   - hdoop supergroup  0 ... /raw/trips/year=2026
drwxr-xr-x   - hdoop supergroup  0 ... /raw/trips/year=2026/month=01
-rw-r--r--   1 hdoop supergroup  ~392MB ... /raw/trips/year=2026/month=01/yellow_tripdata_2026-01.csv
drwxr-xr-x   - hdoop supergroup  0 ... /raw/trips/year=2026/month=02
-rw-r--r--   1 hdoop supergroup  ~358MB ... /raw/trips/year=2026/month=02/yellow_tripdata_2026-02.csv
drwxr-xr-x   - hdoop supergroup  0 ... /raw/trips/year=2026/month=03
-rw-r--r--   1 hdoop supergroup  ~416MB ... /raw/trips/year=2026/month=03/yellow_tripdata_2026-03.csv
drwxr-xr-x   - hdoop supergroup  0 ... /raw/zone_lookup
-rw-r--r--   1 hdoop supergroup  ~12KB ... /raw/zone_lookup/taxi_zone_lookup.csv
```

```bash
hdfs dfs -du -h /raw
```

Expected (approx):

```
392.0 M  392.0 M  /raw/trips/year=2026/month=01
358.0 M  358.0 M  /raw/trips/year=2026/month=02
416.0 M  416.0 M  /raw/trips/year=2026/month=03
 12.1 K   12.1 K  /raw/zone_lookup
```

Note **replication = 1** (single-node cluster) → stored size == logical size.

---

## Step 6 — Inspect a row from HDFS (proof the data is real)

```bash
hdfs dfs -cat /raw/trips/year=2026/month=01/yellow_tripdata_2026-01.csv | head -3
```

Expected: three CSV lines with 19 comma-separated fields each, e.g.

```
2,2026-01-01 00:54:04.000000,2026-01-01 00:59:37.000000,1,0.97,1,"N",239,238,1,7.2,1,0.5,3.66,0,1,15.86,2.5,0
1,2026-01-01 00:34:04.000000,2026-01-01 00:39:47.000000,0,0.9,1,"N",163,162,2,7.9,4.25,0.5,0,0,1,13.65,2.5,0
1,2026-01-01 00:57:06.000000,2026-01-01 01:05:59.000000,0,1.4,1,"N",43,237,1,10.7,4.25,0.5,2.5,0,1,18.95,2.5,0
```

---

## Step 7 — HDFS block report

```bash
hdfs fsck /raw -files -blocks | tail -25
```

Expected: `Status: HEALTHY`, `Total blocks (validated): N`, average block size ≈ 128 MB.

---

Open `http://localhost:9870` in the VM's Firefox.

---
