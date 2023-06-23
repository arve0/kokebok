#!/usr/bin/env bash
set -eo pipefail

container=calendar query='{
  "range": {
    "@timestamp": {
      "boost": 2,
      "gte": "2023-06-22T12:30:00",
      "lte": "2023-06-22T14:30:00"
    }
  }
}' openshift-logging/search.sh \
  | tee r.json \
  | jq .hits.total


jq '.hits.hits[]._source.message' r.json -r \
  | jq 'select(."service.name" == "calendar-connector") \
  | ."@timestamp" + " " + .message' -r > calendar-connector.log

rm r.json
