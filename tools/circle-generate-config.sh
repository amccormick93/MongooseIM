#!/usr/bin/env bash

OUT_FILE="$1"

echo | base64 -w0 > /dev/null 2>&1
if [ $? -eq 0 ]; then
      # GNU coreutils base64, '-w' supported
      MYBASE64="base64 -w0"
    else
      # Openssl base64, no wrapping by default
      MYBASE64="base64"
fi

set -e

function cat64 {
    cat "$1" | $MYBASE64
}

MYSQL_CNF=$(cat64 tools/db_configs/mysql/mysql.cnf)
MYSQL_SQL=$(cat64 priv/mysql.sql)
MYSQL_SETUP=$(cat64 tools/docker-setup-mysql.sh)
MIM_CERT=$(cat64 tools/ssl/mongooseim/cert.pem)
MIM_KEY=$(cat64 tools/ssl/mongooseim/key.pem)
INJECT_FILES=$(cat64 tools/inject-files.sh)

sed -e "s/__MYSQL_CNF__/${MYSQL_CNF}/" \
    -e "s/__MYSQL_SQL__/${MYSQL_SQL}/" \
    -e "s/__MYSQL_SETUP__/${MYSQL_SETUP}/" \
    -e "s/__MIM_CERT__/${MIM_CERT}/" \
    -e "s/__MIM_KEY__/${MIM_KEY}/" \
    -e "s/__INJECT_FILES__/${INJECT_FILES}/" \
    .circleci/template.yml \
    > "$OUT_FILE"
