# Phase 7 — Streamlit dashboard

Scripts for this phase live under `scripts/`. Execution evidence (logs and captures) is under `user_output/07/` when available.

**Time:** 15–20 minutes.
**Prerequisites:** **Phase 5 fully done** — Hive analytics + export + the five CSVs on disk (Step 7 of `05-run-hive.md`).

## What we're building

An interactive dashboard that reads the Hive-exported CSVs and renders the 5 business insights with Plotly charts. Runs locally inside the VM; access from Firefox at `http://localhost:8501`.

**Charts:**
1. Top-10 pickup zones by hour (slider control)
2. Revenue by borough × payment method
3. Congestion trend – min/mile by hour + slowest PU→DO pairs
4. Airport profile (JFK/LGA/EWR) – top destinations
5. Card vs cash share by borough

The dashboard reads **local CSV files only** — not HDFS/Hive live. Hadoop can be stopped **after** the CSVs exist on disk.

---

## Step 0 — Confirm data exists (do this first)

On the VM:

```bash
ls -lh ~/bits-first-sem-big-data/dashboard/data/
wc -l ~/bits-first-sem-big-data/dashboard/data/*.csv
head -3 ~/bits-first-sem-big-data/dashboard/data/q2_revenue_by_borough.csv
```

**Healthy signs:**

| File | Rough size | Rough line count |
|------|------------|------------------|
| `q1_hotspots.csv` | ~150 KB+ | thousands |
| `q2_revenue_by_borough.csv` | ~1 KB+ | ~32 |
| `q3_congestion.csv` | ~15 KB+ | 500 |
| `q4_airports.csv` | ~25 KB+ | hundreds |
| `q5_payment_share.csv` | ~250 B+ | 8 |

If the folder is missing, files are **0 bytes**, or `wc -l` is **0** → the UI will show titles/sliders but **no KPIs and empty charts**. Fix Phase 5 before Streamlit (below).

**Quick HDFS check** (needs NameNode/DataNode running):

```bash
hdfs dfs -ls -R /results/hive
for q in q1_hotspots q2_revenue_by_borough q3_congestion q4_airports q5_payment_share; do
  echo "=== $q ==="
  hdfs dfs -cat /results/hive/$q/* 2>/dev/null | head -2
done
```

If HDFS paths are empty, re-run Pig (Phase 3), then `02_analytics.sql` and `03_export.sql` (Phase 5).

---

## Step 1 — Pull CSVs from HDFS (if Step 0 failed)

**HDFS must be up** for getmerge (`start-dfs.sh` at minimum):

```bash
$HADOOP_HOME/sbin/start-dfs.sh
jps   # expect NameNode + DataNode
```

Then:

```bash
mkdir -p ~/bits-first-sem-big-data/dashboard/data
for q in q1_hotspots q2_revenue_by_borough q3_congestion q4_airports q5_payment_share; do
  hdfs dfs -getmerge /results/hive/$q ~/bits-first-sem-big-data/dashboard/data/${q}.csv
done
ls -lh ~/bits-first-sem-big-data/dashboard/data/
```

Repeat **Step 0** until sizes and line counts look right.

---

## Step 2 — Free RAM (optional, after CSVs are on disk)

```bash
stop-hbase.sh          # if running
$HADOOP_HOME/sbin/stop-yarn.sh
$HADOOP_HOME/sbin/stop-dfs.sh
jps                    # only "Jps" should remain
```

Do **not** skip Step 0/1 and stop Hadoop first — you cannot getmerge without HDFS.

---

## Step 3 — Pull latest code

```bash
```

---

## Step 4 — Install Streamlit + Plotly

```bash
pip3 install --user -r ~/bits-first-sem-big-data/dashboard/requirements.txt
```

Verify:

```bash
python3 -c "import streamlit, plotly, pandas; print(streamlit.__version__, plotly.__version__, pandas.__version__)"
```

Expected: three version strings.

The `streamlit` binary lands in `~/.local/bin`. Make sure it's on `$PATH`:

```bash
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
source ~/.bashrc
which streamlit
```

---

## Step 5 — Launch the app

```bash
cd ~/bits-first-sem-big-data/my-work/dashboard
streamlit run app.py --server.headless true --server.port 8501
```

You'll see:

```
  You can now view your Streamlit app in your browser.

  Local URL: http://localhost:8501
  Network URL: http://x.x.x.x:8501
```

Open **`http://localhost:8501`** in the **VM's Firefox** (same machine where the CSVs live).

The **sidebar** lists each CSV path and byte size — use it to confirm the app sees real files.

---

|---|---|
| `07-dashboard-home.png` | Top of the app: title + KPI row |
| `07-dashboard-q1.png` | Q1 demand hotspots at hour = 18 |
| `07-dashboard-q1-morning.png` | Same but hour = 8 (compare) |
| `07-dashboard-q2.png` | Q2 revenue by borough × payment |
| `07-dashboard-q3.png` | Q3 congestion line + top-slow pairs table |
| `07-dashboard-q4-jfk.png` | Q4 with airport = JFK |
| `07-dashboard-q4-lga.png` | Q4 with airport = LGA |
| `07-dashboard-q5.png` | Q5 payment share bars |

---

## Step 7 — Stop the app

`Ctrl+C` in the terminal running Streamlit.

---