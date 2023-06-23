#!/usr/bin/env bash
# example usage:
#   openshift-logging/search.sh Healthcheck passed | jq .
#
# example usage with container name (must be exact match):
#   container=vector openshift-logging/search.sh Healthcheck passed | jq .
#
# example usage with formatted output:
#   openshift-logging/search.sh Healthcheck passed \
#     | jq -r '.hits.hits[]._source | ."@timestamp" + " " + .kubernetes.pod_name + " " + .message'
#
# example usage with @timestamp query:
#   query='{
#     "range": {
#       "@timestamp": {
#         "boost": 2,
#         "gte": "2023-06-22T12:30:00",
#         "lte": "2023-06-22T14:30:00"
#       }
#     }
#   }' openshift-logging/search.sh
#
set -xeuo pipefail

dir=$(dirname "$0")
namespace=openshift-logging
pod=$(oc get pods -n $namespace -l es-node-master=true -o name | head -n1 | cut -d/ -f2)

container=${container:-}

oc cp -n $namespace "$dir/elasticsearch.sh" "$pod:/tmp/elasticsearch.sh" --container elasticsearch

query=${query:-}
if [[ $query != "" ]]; then
  echo "$query" > elasticsearch-query.json
  trap 'rm -f elasticsearch-query.json' EXIT
  oc cp -n $namespace elasticsearch-query.json "$pod:/tmp/elasticsearch-query.json" --container elasticsearch
fi

oc exec -n $namespace "$pod" --container elasticsearch -- \
  bash -c 'source /tmp/elasticsearch.sh; container='"$container"' es-search "'"$*"'"'
