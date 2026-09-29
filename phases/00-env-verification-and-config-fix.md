# Phase 0.5 — Environment Verification and Configuration Fixes

## Objective

Correct three latent issues in the Hadoop 3.2.1 pseudo-cluster configuration and re-verify with a fresh WordCount job. All commands are executed as user `hdoop`.

## Issues addressed

1. `hdfs-site.xml` referenced `dfs.data.dir` twice — the first entry incorrectly pointed at the NameNode metadata directory. Split into the correct `dfs.namenode.name.dir` and `dfs.datanode.data.dir` properties.
2. `dfs.replication` was set to 3 on a single-node cluster; corrected to 1.
3. `HADOOP_OPTS` in `~/.bashrc` ended with `lib/nativ` (typo) instead of `lib/native`.

Alongside the fixes, `mapred-site.xml` and `yarn-site.xml` were memory-tuned for the 4 GB VM (small container memory, virtual-memory checks disabled).

## 1. Stop Hadoop daemons

```bash
$HADOOP_HOME/sbin/stop-yarn.sh
$HADOOP_HOME/sbin/stop-dfs.sh
jps
```

## 2. Corrected `hdfs-site.xml`

```xml
<configuration>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>/home/hdoop/dfsdata/namenode</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>/home/hdoop/dfsdata/datanode</value>
  </property>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
  <property>
    <name>dfs.permissions.enabled</name>
    <value>false</value>
  </property>
</configuration>
```

Property changes vs the earlier version:

- `dfs.namenode.name.dir` and `dfs.datanode.data.dir` now carry the correct property names (previously both were labelled `dfs.data.dir`).
- Replication factor set to 1 for the single-node cluster.
- Permission checks disabled to simplify Hive / Pig / HBase writes in the lab environment.

## 3. `mapred-site.xml` — memory-constrained containers

```xml
<configuration>
  <property><name>mapreduce.framework.name</name><value>yarn</value></property>
  <property><name>mapreduce.map.memory.mb</name><value>512</value></property>
  <property><name>mapreduce.reduce.memory.mb</name><value>512</value></property>
  <property><name>mapreduce.map.java.opts</name><value>-Xmx410m</value></property>
  <property><name>mapreduce.reduce.java.opts</name><value>-Xmx410m</value></property>
  <property><name>yarn.app.mapreduce.am.resource.mb</name><value>512</value></property>
  <property><name>yarn.app.mapreduce.am.command-opts</name><value>-Xmx410m</value></property>
  <property>
    <name>mapreduce.application.classpath</name>
    <value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>
  </property>
</configuration>
```

512 MB containers with 410 MB JVM heaps fit inside the 4 GB VM without triggering OOM kills. The explicit MR application classpath property is required by some Hadoop 3.x builds on Ubuntu.

## 4. `yarn-site.xml` — capped node memory, disabled virt-mem checks

```xml
<configuration>
  <property><name>yarn.nodemanager.aux-services</name><value>mapreduce_shuffle</value></property>
  <property><name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name><value>org.apache.hadoop.mapred.ShuffleHandler</value></property>
  <property><name>yarn.resourcemanager.hostname</name><value>127.0.0.1</value></property>
  <property><name>yarn.acl.enable</name><value>0</value></property>
  <property>
    <name>yarn.nodemanager.env-whitelist</name>
    <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
  </property>
  <property><name>yarn.nodemanager.resource.memory-mb</name><value>2048</value></property>
  <property><name>yarn.scheduler.minimum-allocation-mb</name><value>256</value></property>
  <property><name>yarn.scheduler.maximum-allocation-mb</name><value>1536</value></property>
  <property><name>yarn.nodemanager.vmem-check-enabled</name><value>false</value></property>
  <property><name>yarn.nodemanager.pmem-check-enabled</name><value>false</value></property>
</configuration>
```

The env-whitelist previously contained `CLASSPATH_PERPEND_DISTCACHE`; corrected to `CLASSPATH_PREPEND_DISTCACHE`. Virtual-memory checks are disabled to prevent low-RAM YARN kills on the 4 GB VM.

## 5. `.bashrc` — HADOOP_OPTS path

The `HADOOP_OPTS` line previously ended with `lib/nativ`; corrected to `lib/native`:

```bash
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"
```

Reload the shell environment:

```bash
source ~/.bashrc
env | grep HADOOP_OPTS
```

## 6. NameNode re-format

Since the NameNode metadata property changed, existing metadata may reference the old path. A clean format is applied:

```bash
rm -rf /home/hdoop/dfsdata/namenode/*
rm -rf /home/hdoop/dfsdata/datanode/*
rm -rf /home/hdoop/tmpdata/*

hdfs namenode -format -force
```

Expected final line:

```
Storage directory /home/hdoop/dfsdata/namenode has been successfully formatted.
```

## 7. Start daemons

```bash
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh
mapred --daemon start historyserver
jps
```

Expected daemons (seven processes):

```
NameNode
DataNode
SecondaryNameNode
ResourceManager
NodeManager
JobHistoryServer
Jps
```

The Job History Server listens on IPC port 10020 and web UI 19888. Without it, Pig / Hive / MR jobs still succeed but the client cannot fetch job counters — the log fills with `Retrying connect to server: 0.0.0.0/0.0.0.0:10020` retries.

## 8. Base HDFS directory layout

```bash
hdfs dfs -mkdir -p /tmp/hive-warehouse
hdfs dfs -mkdir -p /user/hdoop
hdfs dfs -mkdir -p /raw
hdfs dfs -mkdir -p /clean
hdfs dfs -mkdir -p /results
hdfs dfs -ls /
```

Expected output:

```
Found 5 items
drwxr-xr-x   - hdoop supergroup  0 ... /clean
drwxr-xr-x   - hdoop supergroup  0 ... /raw
drwxr-xr-x   - hdoop supergroup  0 ... /results
drwxr-xr-x   - hdoop supergroup  0 ... /tmp
drwxr-xr-x   - hdoop supergroup  0 ... /user
```

The NameNode Web UI at `http://localhost:9870` (**Utilities → Browse the file system**) shows the same layout.

## 9. WordCount verification

A fresh WordCount job is run to confirm the cluster is operational end-to-end.

```bash
mkdir -p ~/data_source && cd ~/data_source
cat > data.txt <<'EOF'
transportation is the backbone of any economy
big data is transforming transportation
nyc yellow taxis run every day in transportation networks
transportation data helps city planners
EOF

hdfs dfs -mkdir -p /test/wordcount/input
hdfs dfs -put -f data.txt /test/wordcount/input/

cd $HADOOP_HOME/share/hadoop/mapreduce
hadoop jar hadoop-mapreduce-examples-3.2.1.jar wordcount \
    /test/wordcount/input /test/wordcount/output

hdfs dfs -cat /test/wordcount/output/part-r-00000

hdfs dfs -rm -r /test    # cleanup
```

The job counters block (Map input records, Reduce output records, Combine input/output, GC time, CPU time) confirms MR execution on YARN.

## Troubleshooting

| Symptom | Likely cause | Resolution |
|---|---|---|
| `hdfs namenode -format` prompts "reformat? (Y or N)" | Existing metadata directory | Answer `Y` |
| `jps` missing DataNode | Cluster ID mismatch after re-format | `rm -rf /home/hdoop/dfsdata/datanode/*`; then `start-dfs.sh` |
| `jps` missing NameNode | XML parse error in `hdfs-site.xml` | Check `$HADOOP_HOME/logs/hadoop-hdoop-namenode-*.log` |
| WordCount hangs at `map 0% reduce 0%` | Container memory too large for YARN allocation | Confirm `yarn.nodemanager.resource.memory-mb=2048`; verify with `yarn node -list` |
| `Connection refused localhost:9000` | HDFS is down | `start-dfs.sh` and re-check `jps` |
| `WARN util.NativeCodeLoader: Unable to load native-hadoop library` | Cosmetic on Ubuntu 22.04 + JDK 8 | Ignore |
