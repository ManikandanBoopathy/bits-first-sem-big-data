# Phase 1 — Install Apache Pig, Hive, and HBase

## Objective

Install three Hadoop-ecosystem components on top of the Hadoop 3.2.1 pseudo-cluster from Phase 0.5. All installations run as user `hdoop` and use pre-built binary tarballs from the Apache archive.

## Versions

| Tool | Version | Home directory | Source |
|---|---|---|---|
| Apache Pig | 0.17.0 | `/home/hdoop/pig-0.17.0` | https://archive.apache.org/dist/pig/pig-0.17.0/pig-0.17.0.tar.gz |
| Apache Hive | 3.1.3 | `/home/hdoop/apache-hive-3.1.3-bin` | https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz |
| Apache HBase | 2.4.18 | `/home/hdoop/hbase-2.4.18` | https://archive.apache.org/dist/hbase/2.4.18/hbase-2.4.18-bin.tar.gz |

All three versions are known-compatible with Hadoop 3.2.1.

## 1. Shell environment

The block in `scripts/hadoop-conf/bashrc-additions.sh` is appended to `~/.bashrc`. It declares `PIG_HOME`, `HIVE_HOME`, `HBASE_HOME`, adds their `bin/` directories to `PATH`, and auto-detects the JDK architecture (`amd64` on Intel, `arm64` on Apple-Silicon / ARM hosts) via `dpkg --print-architecture`.

```bash
source ~/.bashrc
env | grep -E "HADOOP_HOME|PIG_HOME|HIVE_HOME|HBASE_HOME"
```

Expected:

```
HADOOP_HOME=/home/hdoop/hadoop-3.2.1
PIG_HOME=/home/hdoop/pig-0.17.0
HIVE_HOME=/home/hdoop/apache-hive-3.1.3-bin
HBASE_HOME=/home/hdoop/hbase-2.4.18
```

## 2. Apache Pig 0.17.0

```bash
cd ~
wget https://archive.apache.org/dist/pig/pig-0.17.0/pig-0.17.0.tar.gz
tar xzf pig-0.17.0.tar.gz
rm pig-0.17.0.tar.gz
pig -version
```

Expected first line:

```
Apache Pig version 0.17.0 (r1797386)
```

## 3. Apache Hive 3.1.3

### 3a. Download and extract

```bash
cd ~
wget https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
tar xzf apache-hive-3.1.3-bin.tar.gz
rm apache-hive-3.1.3-bin.tar.gz
```

### 3b. Resolve the Guava dependency conflict

Hive 3.1.3 ships `guava-19.0.jar`, which is incompatible with Hadoop 3.2.1's newer Guava. Hive fails to start with `NoSuchMethodError: Preconditions.checkArgument` unless replaced:

```bash
rm  $HIVE_HOME/lib/guava-19.0.jar
cp  $HADOOP_HOME/share/hadoop/hdfs/lib/guava-27.0-jre.jar  $HIVE_HOME/lib/
```

### 3c. HDFS directories for Hive

```bash
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -mkdir -p /tmp
hdfs dfs -chmod -R 1777 /tmp
hdfs dfs -chmod -R 1777 /user/hive/warehouse
```

### 3d. `hive-site.xml`

The canonical Hive configuration is checked in at `scripts/hive-conf/hive-site.xml`. It is copied verbatim into `$HIVE_HOME/conf/hive-site.xml`:

```bash
cp scripts/hive-conf/hive-site.xml $HIVE_HOME/conf/hive-site.xml
```

Key properties:

- `javax.jdo.option.ConnectionURL` — absolute-path Derby database at `/home/hdoop/hive_metastore_db`.
- `hive.metastore.warehouse.dir` — `/user/hive/warehouse`.

Design decision: the file is written as a minimal single-source configuration and **not** derived from `hive-default.xml.template`. The template already declares its own `javax.jdo.option.ConnectionURL` with a relative-path database name (`metastore_db`); because Hadoop XML uses last-property-wins semantics, that template entry would silently override the absolute path added on top, leading Derby to create empty `metastore_db/` directories in whichever cwd `hive` is launched from.

Sanity check that exactly one `ConnectionURL` property exists:

```bash
grep -c ConnectionURL $HIVE_HOME/conf/hive-site.xml   # expected: 2 (one <name>, one <value>)
```

### 3e. Initialize the metastore schema

`schematool` is run from the home directory so that any incidental files (`derby.log`) land there rather than under a project directory:

```bash
cd ~
schematool -dbType derby -initSchema
```

Expected final lines:

```
Metastore connection URL:  jdbc:derby:;databaseName=/home/hdoop/hive_metastore_db;create=true
Initialization script completed
schemaTool completed
```

The `Metastore connection URL` line must show the absolute path `/home/hdoop/hive_metastore_db`. If it shows just `databaseName=metastore_db`, `hive-site.xml` is being overridden and step 3d needs to be redone.

### 3f. Smoke test

```bash
hive -e "SHOW DATABASES;"
```

Expected output:

```
OK
default
Time taken: N.N seconds, Fetched: 1 row(s)
```

## 4. Apache HBase 2.4.18 (standalone mode)

### 4a. Download and extract

```bash
cd ~
wget https://archive.apache.org/dist/hbase/2.4.18/hbase-2.4.18-bin.tar.gz
tar xzf hbase-2.4.18-bin.tar.gz
rm hbase-2.4.18-bin.tar.gz
```

### 4b. Determine the JDK architecture path

```bash
dpkg --print-architecture   # returns amd64 or arm64
```

The `JAVA_HOME` value in `hbase-env.sh` (next step) must reference the matching directory: `java-8-openjdk-amd64` or `java-8-openjdk-arm64`.

### 4c. `hbase-env.sh` additions

The canonical HBase environment additions are checked in at `scripts/hbase-conf/hbase-env.additions.sh`. Append its contents near the top of `$HBASE_HOME/conf/hbase-env.sh`:

- `JAVA_HOME` — absolute path to the OpenJDK 8 root for the VM's architecture.
- `HBASE_MANAGES_ZK=true` — HBase manages its own ZooKeeper instance in standalone mode.
- `HBASE_DISABLE_HADOOP_CLASSPATH_LOOKUP=true` — required workaround for the HBase 2.4 + Hadoop 3.x incompatibility that otherwise emits `HADOOP_ORG.APACHE.HADOOP.HBASE.UTIL.GETJAVAPROPERTY_USER: invalid variable name` and prevents HMaster from starting.

Verify:

```bash
ls -la $JAVA_HOME/jre/bin/java   # java binary exists (OpenJDK 8 keeps java in jre/bin/)
ls -la $JAVA_HOME/bin/javac      # javac exists
```

### 4d. `hbase-site.xml`

The canonical HBase configuration is checked in at `scripts/hbase-conf/hbase-site.xml`. Copy it into `$HBASE_HOME/conf/hbase-site.xml`:

```bash
cp scripts/hbase-conf/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml
```

Properties:

- `hbase.rootdir` — `hdfs://127.0.0.1:9000/hbase` (HBase stores its data inside HDFS)
- `hbase.cluster.distributed` — `false` (standalone mode: HMaster + HRegionServer + ZooKeeper in one JVM)
- `hbase.zookeeper.property.dataDir` — `/home/hdoop/zookeeper`
- `hbase.unsafe.stream.capability.enforce` — `false` (required for HDFS backend)

### 4e. Start HBase

Hive and HBase together exceed the 4 GB memory budget, so HBase is started only when the working session requires it.

```bash
start-hbase.sh
sleep 20
jps
```

Expected additional process (only one, because standalone mode packs everything into a single JVM):

```
HMaster
```

Verify from the shell:

```bash
echo "status" | hbase shell 2>/dev/null | tail -3
```

Expected:

```
1 active master, 0 backup masters, 1 servers, 0 dead, N.N average load
```

The HBase Master UI is available at `http://localhost:16010`.

### 4f. Stop HBase

```bash
stop-hbase.sh
jps    # HMaster gone
```

## Troubleshooting

| Symptom | Cause | Resolution |
|---|---|---|
| `hive` throws `NoSuchMethodError ... Preconditions.checkArgument` | Guava version mismatch not fixed | Redo step 3b |
| `SAXParseException` starting `hive` | Malformed character in `hive-default.xml.template` inherited into `hive-site.xml` | Use `scripts/hive-conf/hive-site.xml` verbatim (does not derive from the template) |
| `schematool` output shows `databaseName=metastore_db` (relative) instead of the absolute path | Duplicate `ConnectionURL` entries — template's relative-path URL overrides the absolute one | Rewrite `hive-site.xml` per step 3d; verify with `grep -c ConnectionURL $HIVE_HOME/conf/hive-site.xml` returning 2 |
| `CREATE TABLE` fails with `Required table missing : "VERSION"` | Metastore schema not initialized against the correct database path | Nuke stray `metastore_db/` directories (`find ~ -maxdepth 6 -name metastore_db -type d`) and re-run `schematool -dbType derby -initSchema` from `~` |
| HMaster missing from `jps` | Log shows `HADOOP_ORG.APACHE.HADOOP.HBASE.UTIL...: invalid variable name` | Add `HBASE_DISABLE_HADOOP_CLASSPATH_LOOKUP=true` in `hbase-env.sh` |
| HMaster missing; log shows `$JAVA_HOME/bin/java: No such file or directory` | `JAVA_HOME` points to `amd64` on an `arm64` VM (or vice versa) | Run `dpkg --print-architecture`; correct the path in both `~/.bashrc` and `$HBASE_HOME/conf/hbase-env.sh` |
| HBase log shows `PleaseHoldException: Master is initializing` | Startup still in progress | Wait ~30 s after `start-hbase.sh` before issuing shell commands |
| `KeeperException$ConnectionLossException` | Embedded ZooKeeper crashed | `stop-hbase.sh && start-hbase.sh` |
| HMaster cannot connect to HDFS | HDFS is down | `start-dfs.sh` first, then `start-hbase.sh` |
