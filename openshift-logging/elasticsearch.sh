#!/usr/bin/env bash
set -xeuo pipefail

ES_REST_BASEURL=${ES_REST_BASEURL:-https://localhost:9200}
ES_PATH_CONF=${ES_PATH_CONF:-/etc/elasticsearch/}
container=${container:-}
query=${query:-}

function es {
  path="$1"
  shift
  curl -s \
      --cacert "${ES_PATH_CONF}"secret/admin-ca \
      --cert "${ES_PATH_CONF}"secret/admin-cert \
      --key  "${ES_PATH_CONF}"secret/admin-key \
      --max-time 30 \
      "${ES_REST_BASEURL}${path}" "$@"
}

function es-search {
  queries=()
  if [[ $1 != "" ]]; then
    queries+=('{ "match": { "message": { "query": "'"$1"'", "operator": "and" }}}')
  fi

  if [[ $container != "" ]]; then
    queries+=('{"term": {"kubernetes.container_name": "'"$container"'" }}')
  fi

  if [[ -f /tmp/elasticsearch-query.json ]]; then
    queries+=("$(tr -d '\n' < /tmp/elasticsearch-query.json)")
  fi

  if [[ ${#queries[@]} == 0 ]]; then
    echo "Expected at least container=name or a search term" >&2
    exit 1
  fi

  if [[ ${#queries[@]} == 1 ]]; then
    payload='{ "query": '"${queries[0]}"'}'
  else
    queries_joined=$(printf ",%s" "${queries[@]}")
    queries_joined=${queries_joined:1}

    payload='{
      "from": 0,
      "size": 1000,
      "query": {
        "bool": {
          "must": ['"$queries_joined"']
        }
      }
    }'
  fi
  shift

  echo "Searching for $queries_joined" >&2
  es "/app-*/_search" -X POST -H 'Content-Type: application/json' -d "$payload" "$@"
}
