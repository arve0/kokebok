#!/usr/bin/env bash
# example usages:
#   ./search.sh | jq '.hits.hits[]._source.message'
#   ./search.sh | jq '.hits.hits[]._source.kubernetes.pod_name'
#   ./search.sh | jq '.hits.hits[]._source."@timestamp"'
set -xeuo pipefail

pod=$(oc get pods -l es-node-master=true -o name | head -n1 | cut -d/ -f2)

oc cp elasticsearch.sh "$pod:/tmp/elasticsearch.sh" --container elasticsearch

oc exec "$pod" --container elasticsearch -- \
  bash -c 'source /tmp/elasticsearch.sh; es-search "Healthcheck passed"'
