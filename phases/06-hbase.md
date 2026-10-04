# Phase 6 — HBase serving layer

Scripts for this phase live under `scripts/`. Execution evidence (logs and captures) is under `user_output/06/` when available.

**Time:** 15–20 minutes.
**Prerequisites:** HBase installed (Phase 1). **Hive stopped** (memory).

## What we're doing

Show HBase as a **random-access NoSQL wide-column store**, complementing Hive's scan-based analytics.

- **Table 1 – `zone_lookup`**: 265 NYC taxi zones, keyed by `LocationID`. Demonstrates fast `get`-by-key that a Hive table can't match at low latency.
- **Table 2 – `trip_by_zone`** (optional bonus): rollup metrics per zone+hour keyed as `<pu_loc_id>_<hour>` (e.g. `132_18` = JFK at 6 PM).

---

## Step 1 — Free RAM first

```bash
jps
```

If Hive is still around (from prior `hive` session leaving the JVM up), open a new terminal and don't run `hive`. Only Hadoop should be running.

Also make sure Hadoop is up:

```bash
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh
jps
```

---

## Step 2 — Start HBase

```bash
start-hbase.sh
sleep 15                # give master time to come up
jps
```

Expected additions:

```
HMaster
HRegionServer
HQuorumPeer
```

Verify with the shell:

```bash
echo "status" | hbase shell 2>/dev/null | tail -5
```

Expected: `1 active master, 0 backup masters, 1 servers, 0 dead, ...`.

---

## Step 3 — Create tables

```bash
cd ~/bits-first-sem-big-data/scripts/hbase
hbase shell create_tables.hbase 2>&1 | tee ~/hbase_create.log
```

Expected end:

```
TABLE
trip_by_zone
zone_lookup
2 row(s) in ... seconds

=> ["trip_by_zone", "zone_lookup"]
```

---

## Step 4 — Load zones into `zone_lookup`

### 4a. Start the Thrift gateway (needed by happybase)

```bash
hbase-daemon.sh start thrift
```

Check it's listening:

```bash
netstat -tln | grep 9090     # or: ss -tln | grep 9090
```

Should show `LISTEN … 0.0.0.0:9090`.

### 4b. Install happybase

```bash
pip3 install --user happybase
```

### 4c. Run the loader

```bash
python3 load_zones.py /home/hdoop/staging/taxi_zone_lookup.csv
```

Expected:

```
Inserted 265 zones into HBase table `zone_lookup`.

GET zone_lookup, '132':
  info:borough = Queens
  info:zone_name = JFK Airport
  info:service_zone = Airports
```

---

## Step 5 — Show off HBase reads 

### 5a. Point get — the fast case

```bash
hbase shell <<'EOF'
get 'zone_lookup', '132'
get 'zone_lookup', '138'
get 'zone_lookup', '1'
EOF
```

### 5b. Scan with a filter

```bash
hbase shell <<'EOF'
scan 'zone_lookup', { COLUMNS => 'info:borough', FILTER => "SingleColumnValueFilter('info','borough',=,'binary:EWR')" }
EOF
```

### 5c. Table count

```bash
echo "count 'zone_lookup'" | hbase shell 2>/dev/null | tail -3
```

Expected: `265 row(s)`.

---

## Step 6 — Load top-hour stats into `trip_by_zone` (optional but recommended)

This demonstrates how you'd store precomputed analytics keyed for real-time serving.

```bash
cat > /tmp/load_trip_by_zone.py <<'PY'
import csv, happybase, sys

conn  = happybase.Connection("127.0.0.1", 9090)
table = conn.table("trip_by_zone")

# The exported Hive q1_hotspots.csv has: pickup_hour, pu_borough, pu_zone, trips
with open("/home/hdoop/bits-first-sem-big-data/dashboard/data/q1_hotspots.csv") as f:
    r = csv.reader(f)
    n = 0
    with table.batch(batch_size=200) as b:
        for row in r:
            if len(row) < 4: continue
            hour, borough, zone, trips = row
            key = f"{zone.replace(' ','_')}_{int(hour):02d}".encode()
            b.put(key, {
                b"stats:trips":   trips.encode(),
                b"stats:borough": borough.encode(),
                b"stats:zone":    zone.encode(),
            })
            n += 1
    print(f"Wrote {n} rows to trip_by_zone")
conn.close()
PY

python3 /tmp/load_trip_by_zone.py
```

Then in HBase shell:

```bash
hbase shell <<'EOF'
scan 'trip_by_zone', {LIMIT => 5}
EOF
```

---

## Step 7 — Stop the Thrift gateway (optional, tidy)

```bash
hbase-daemon.sh stop thrift
```

Keep HBase itself running only if the next demo needs it; otherwise `stop-hbase.sh`.

---
