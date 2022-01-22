#!/bin/bash

set -ex

node_type="$1"

formatted_marker="$HDFS_DATA_ROOT"/."${node_type}"-formatted

if [[ ! -f "$formatted_marker" ]]; then
    yes | hadoop "${node_type}" -format && touch "$formatted_marker"
fi

hdfs "${node_type}" "${@:2}"
