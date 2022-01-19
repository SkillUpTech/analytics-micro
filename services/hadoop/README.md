# Hadoop Images

This directory contains Docker contexts for the following services:

- HDFS
    - The hadoop filesystem.
    - Used as the backend for Hive.
    - Accessed by the Snakebite client in Luigi MapReduce tasks.
    - Stores tracking logs.
- Pipeline
    - The skt-analytics-pipeline repo + dependencies.
    - Hive (SQL-like client for HDFS).
    - MYSQL Client.
- Spark
    - MapReduce job backend.
