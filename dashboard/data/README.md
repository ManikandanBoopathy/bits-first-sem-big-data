# Dashboard input CSVs (not in git)

Streamlit reads **five** Hive export files from this folder. They are **not** committed (see repo `.gitignore`).

Create them on the VM after Phase 5 (`03_export.sql` + `hdfs dfs -getmerge`), per:

- `user-tasks/05-run-hive.md` — Step 6–7  
- `user-tasks/07-dashboard.md` — Step 2  

Expected files:

| File | Typical size | Typical rows |
|------|-------------:|-------------:|
| `q1_hotspots.csv` | ~150 KB+ | ~5,000+ |
| `q2_revenue_by_borough.csv` | ~1 KB+ | ~32 |
| `q3_congestion.csv` | ~15 KB+ | 500 |
| `q4_airports.csv` | ~25 KB+ | ~500+ |
| `q5_payment_share.csv` | ~200 B+ | 8 |

If every file is **0 bytes** or `wc -l` is **0**, the dashboard will show titles and sliders but **empty charts and zero KPIs**.
