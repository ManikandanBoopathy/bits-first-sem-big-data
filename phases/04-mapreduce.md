# Phase 4 — Hadoop Streaming MapReduce

Scripts for this phase live under `scripts/`. Execution evidence (logs and captures) is under `user_output/04/` when available.

**Time:** 5–10 minutes.
**Prerequisites:** `/clean/trips` populated by Phase 3.

## Why this phase exists

Pig and Hive both compile to MapReduce internally — so technically every previous MR job you saw in the YARN UI *is* MapReduce. But the assignment specifically calls out demonstrating **understanding of MapReduce workflow**. Writing a mapper + reducer by hand makes that concrete: it forces us to specify exactly what the map phase emits, what the shuffle phase groups by, and what the reduce phase aggregates.

**Job we run:** *Trips-per-zone-per-hour.*
- Mapper reads each cleaned trip and emits `(PULocationID, hour_of_day) → 1`
- Shuffle groups all identical keys together
- Reducer sums the 1s per key → total trips at that zone during that hour

This is the taxi-industry equivalent of WordCount but with a real business question ("when is each zone busy?").

---

## Step 1 — Pull scripts

```bash
```

Files:
- `scripts/mapreduce/mapper.py`
- `scripts/mapreduce/reducer.py`
- `scripts/mapreduce/run.sh`

Make executable:

```bash
chmod +x scripts/mapreduce/*.py scripts/mapreduce/run.sh
```

---

## Step 2 — Dry-run locally (fast sanity check, no cluster)

Run the mapper + reducer on a small local sample to prove they work before submitting to YARN:

```bash
cd ~/bits-first-sem-big-data/scripts/mapreduce
hdfs dfs -cat /clean/trips/part-* 2>/dev/null | head -100 \
    | python3 mapper.py \
    | sort \
    | python3 reducer.py \
    | head -20
```

Expected: tab-separated rows like

```
132	09	4
132	10	7
132	11	6
138	14	3
...
```

If this works, the cluster run will too.

---

## Step 3 — Submit the streaming job

```bash
cd ~/bits-first-sem-big-data/scripts/mapreduce
./run.sh 2>&1 | tee ~/mr_run.log
```

Watch for:

```
→ Submitting streaming job...
  jar    : /home/hdoop/hadoop-3.2.1/share/hadoop/tools/lib/hadoop-streaming-3.2.1.jar
  mapper : .../mapper.py
  reducer: .../reducer.py
  input  : /clean/trips
  output : /results/trips_per_zone_hour

packageJobJar: [...] [...] /tmp/streamjob....jar
...
map 0% reduce 0%
map 21% reduce 0%
...
map 100% reduce 100%
Job job_1234567890_0007 completed successfully
```

At the end you'll see:

```
→ First 10 lines of output:
1	00	312
1	01	145
1	02	87
...
→ Line count in output:
6360
✅ Streaming job done.
```

The **6360** count = 265 zones × 24 hours (with some sparse combos missing).

---

`http://localhost:8088` → the `TripsPerZonePerHour` app 
`http://localhost:19888/jobhistory`

- Important counters to capture: `Launched map tasks`, `Launched reduce tasks`, `Map input records`, `Reduce output records`, and our custom `Custom.Rows OK` / `Custom.Rows BAD` (from `mapper.py`'s `reporter:counter:` lines).

- `04-yarn-mr-app-list.png`
- `04-yarn-mr-counters.png`

---

## Step 5 — Read a few rows from HDFS

```bash
hdfs dfs -cat /results/trips_per_zone_hour/part-* | sort -t $'\t' -k3 -nr | head -20
```

---