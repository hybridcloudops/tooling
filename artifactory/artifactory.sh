#!/bin/bash

# Requires pythong version >= 3

# use second argument or default to 3555
PORT=${2:-3555}
# serve repository directory
CMD="python3 -m http.server $PORT --directory repository"

function usage() {
  echo "Usage : $0 [start|stop] <port>"
  exit
}

# require at least one argument
if [ $# -lt 1 ]; then
  usage
fi

case "$1" in

"start")
  echo "Starting artifactory..."
  $CMD &
  ;;
"stop")
  echo "Stopping artifactory..."
  pkill -ef "$CMD"
  ;;
*)
  usage
  ;;
esac
