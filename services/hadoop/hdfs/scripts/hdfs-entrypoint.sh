#!/bin/bash

set -ex

node_type="$1"

case "$1" in
    namenode|datanode)
        echo "Starting $1."
        hdfs "${node_type}" "${@:2}"
    ;;
    format)
        echo "Formatting namenode." >&2
        yes | hadoop namenode -format
        echo "Done" >&2
    ;;
    *)
        echo "Invalid command: $1" >&2
    ;;
esac
