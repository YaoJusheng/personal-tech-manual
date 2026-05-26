#!/bin/bash

set -x

if [ ! "$1" ] || [ "$1" == "grafana" ]; then
  grafana-server --config /etc/grafana/grafana.ini \
  --homepath /usr/share/grafana \
  --pidfile=/var/run/grafana/grafana-server.pid

else
  # reference: https://www.cnblogs.com/zhoujinyi/p/11934062.html
  prometheus --config.file=/usr/local/prometheus/prometheus.yml \
    --storage.tsdb.path=/usr/local/prometheus/data \
    --web.console.libraries=/usr/local/prometheus/console_libraries \
    --web.console.templates=/usr/local/prometheus/consoles \
    --storage.tsdb.retention.time=14d \
    --alertmanager.notification-queue-capacity=1000 \
    --alertmanager.timeout=30s \
    --log.format=logfmt \
    --log.level=info \
    --web.enable-lifecycle

fi
