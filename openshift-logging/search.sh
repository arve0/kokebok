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
set -xeuo pipefail

dir=$(dirname "$0")
namespace=openshift-logging
pod=$(oc get pods -n $namespace -l es-node-master=true -o name | head -n1 | cut -d/ -f2)

container=${container:-}

oc cp -n $namespace "$dir/elasticsearch.sh" "$pod:/tmp/elasticsearch.sh" --container elasticsearch

oc exec -n $namespace "$pod" --container elasticsearch -- \
  bash -c 'source /tmp/elasticsearch.sh; container='"$container"' es-search "'"$*"'"'
