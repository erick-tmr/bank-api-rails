#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Wait for DB services
sh ./config/docker/wait-for-services.sh

bundle exec rails s -b 0.0.0.0
