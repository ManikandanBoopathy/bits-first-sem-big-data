# Phase 3 — Pig ETL (clean and enrich)

Scripts for this phase live under `scripts/`. Execution evidence (logs and captures) is under `user_output/03/` when available.

**Time:** 15–25 minutes (two MR jobs).
**Prerequisites:** Data in `/raw/` (Phase 2 complete). Hadoop up.

## What we're doing

Two Pig Latin scripts, run one after the other:

| Script | Role | HDFS output |
|---|---|---|
| `01_clean_trips.pig` | Read ~11M raw CSV rows, drop bad data, project to same 19 cols | `/clean/trips/` |
| `02_enrich_trips.pig` | Add derived columns (hour/day/duration/tip%) + JOIN zone lookup for pickup borough/zone | `/clean/trips_enriched/` |

---

## Step 1 — Pull scripts

```bash
cd ~/bits-first-sem-big-data
```

Scripts live at:
- `scripts/pig/01_clean_trips.pig`
- `scripts/pig/02_enrich_trips.pig`

---

## Step 2 — Confirm Pig can talk to HDFS + start Job History Server

```bash
pig -x mapreduce -e "ls /raw"
```

Expected: lists `hdfs://127.0.0.1:9000/raw/trips` and `.../raw/zone_lookup`.

If you get `Could not resolve LzoCodec`, ignore — Pig warns but continues.

**Also start the MR Job History Server** if `jps` doesn't already show it. Pig fetches job counters from this daemon (port 10020) after every job; if it's down, the job still succeeds but the log will fill with `Retrying connect to server: 0.0.0.0/0.0.0.0:10020` and the "Successfully read N records" stat will show `0` (misleading placeholder — the job is fine, just the counter reader failed):

```bash
jps | grep -q JobHistoryServer || mapred --daemon start historyserver
jps
```

---

## Step 3 — Run `01_clean_trips.pig`

```bash
cd ~/bits-first-sem-big-data/scripts/pig
# Clear any prior clean output (Pig refuses to overwrite)
hdfs dfs -rm -r -f /clean

pig -x mapreduce -f 01_clean_trips.pig 2>&1 | tee ~/pig_01.log
```

You'll see output like:

```
Pig Stack Trace ... (nothing scary at start)
Connecting to cluster
...
JobId  Alias   Feature   Records ...
job_1234567890_0001   raw,clean   HASH_JOIN   ...
Successfully stored 8,900,000+ records in: "hdfs://127.0.0.1:9000/clean/trips"
```

Runtime: **8–12 minutes** on the 4 GB VM.

### Verify

```bash
hdfs dfs -du -h /clean
hdfs dfs -ls /clean/_counts/raw     /clean/_counts/clean
hdfs dfs -cat /clean/_counts/raw/part-*     ; echo
hdfs dfs -cat /clean/_counts/clean/part-*   ; echo
```

Expected:
- `/clean/trips` has 2–3 part files, total ~700 MB.
- `_counts/raw` shows total raw rows (~11.1 M for Jan–Mar 2026).
- `_counts/clean` shows survivors (typically ~90 % → ~8.4 M).

```bash
raw=$(hdfs dfs -cat /clean/_counts/raw/part-*   | tr -d ,)
cln=$(hdfs dfs -cat /clean/_counts/clean/part-* | tr -d ,)
awk -v r=$raw -v c=$cln 'BEGIN { printf "Rows kept: %d / %d  (%.2f%%)\n", c, r, c*100.0/r }'
```

---

## Step 4 — Run `02_enrich_trips.pig`

```bash
pig -x mapreduce -f 02_enrich_trips.pig 2>&1 | tee ~/pig_02.log
```

Runtime: **6–10 minutes**. Multiple MR jobs will run (a chain: parse → JOIN with zone lookup → project → store).

### Verify

```bash
hdfs dfs -du -h /clean/trips_enriched
hdfs dfs -cat /clean/trips_enriched/part-* | head -3
```

Expected head row (18 comma-separated fields):

```
2,2026-01-01 00:54:04.000000,16,1,1,2026,5.55,1,0.97,239,Manhattan,Upper East Side South,238,1,7.2,3.66,15.86,50.83
1,2026-01-01 00:34:04.000000,0,1,1,2026,5.72,0,0.9,163,Manhattan,Union Sq,162,2,7.9,0.0,13.65,0.0
...
```

Fields (in order): `vendor_id, pickup_dt, pickup_hour, pickup_day, pickup_month, pickup_year, duration_min, passenger_count, trip_distance, pu_loc_id, pu_borough, pu_zone, do_loc_id, payment_type, fare_amount, tip_amount, total_amount, tip_pct`.

---

## Step 5 — Capture YARN evidence

Open `http://localhost:8088` (Firefox in the VM).

- **All Applications** → you should see 4–6 SUCCEEDED entries for `PigLatin:01_clean_trips.pig` and `PigLatin:02_enrich_trips.pig`.
  - `03-yarn-pig-app.png` — the app list
  - `03-yarn-pig-counters.png` — one job's counters showing `Launched map tasks` / `Launched reduce tasks`

---
