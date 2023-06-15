#!/usr/bin/env bash
set -xeuo pipefail

ES_REST_BASEURL=${ES_REST_BASEURL:-https://localhost:9200}
ES_PATH_CONF=${ES_PATH_CONF:-/etc/elasticsearch}

function es {
  path="$1"
  shift
  curl -s \
      --cacert "${ES_PATH_CONF}"/secret/admin-ca \
      --cert "${ES_PATH_CONF}"/secret/admin-cert \
      --key  "${ES_PATH_CONF}"/secret/admin-key \
      --max-time 30 \
      "${ES_REST_BASEURL}${path}" "$@"
}

function es-search {
  payload='{
    "query": {
      "match": {
        "message": {
          "query": "'"$1"'",
          "operator": "and"
        }
      }
    }
  }'
#   payload='{
#   "query": {
#     "bool": {
#       "must": [
#         {
#           "match": {
#             "kubernetes.pod_name": "'"$1"'"
#           }
#         },
#         {
#           "match": {
#             "message": "'"$2"'"
#           }
#         }
#       ]
#     }
#   }
# }'
#   shift
#   shift

  es "/app-*/_search" -X POST -H 'Content-Type: application/json' -d "$payload"
}
