#!/bin/sh

set -eu

ROOT=`dirname "$0"`
cd "$ROOT"

files="
monitor/monitor
monitor/auto_refresh.sh
monitor/dml_view.sh
monitor/mon.sh
monitor/ha_mon.sh
monitor/orastatus
monitor/sql/0_save_file.sh
monitor/sql/4_session_event.sh
"

for file in $files ; do
  if [ ! -f "$file" ] ; then
    echo "Missing file: $file" >&2
    exit 1
  fi
done

chmod +x $files
echo "Executable permissions applied."
