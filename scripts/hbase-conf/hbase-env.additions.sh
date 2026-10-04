# Additions to $HBASE_HOME/conf/hbase-env.sh for HBase 2.4.18 on Hadoop 3.2.1.
# Append these lines near the top of hbase-env.sh (or replace the commented-out
# defaults with them). JAVA_HOME must match the actual installed architecture:
# java-8-openjdk-amd64 on Intel VMs, java-8-openjdk-arm64 on Apple-Silicon / ARM.

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HBASE_MANAGES_ZK=true

# HBase 2.4 + Hadoop 3.x compatibility: skip HBase's classpath auto-lookup,
# which passes Java system property names containing dots that bash rejects
# with "HADOOP_ORG.APACHE.HADOOP.HBASE.UTIL.GETJAVAPROPERTY_USER: invalid
# variable name" and prevents HMaster from starting.
export HBASE_DISABLE_HADOOP_CLASSPATH_LOOKUP="true"
