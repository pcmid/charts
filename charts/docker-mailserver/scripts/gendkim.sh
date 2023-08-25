#!/bin/bash

set -eu
set -x

_gen() {
  domains=$@

  mkdir -p /data/keys /data/txt /data/configs
  for domain in ${domains};do
    _gen_single ${domain}
  done

  for config in {SigningTable,KeyTable,TrustedHosts}; do
    new_config=/tmp/docker-mailserver/opendkim/${config}
    [ -f $new_config ] && cat $new_config >> /data/configs/${config}
  done

  touch /data/done
}

_gen_single() {
  domain=$1

  echo "Checking for existing key for ${domain}..."
  if [ -f /keys/${domain} ];then
      echo "Key exists, skip..."
      return 0
  fi

  setup config dkim domain ${domain}

  cp /tmp/docker-mailserver/opendkim/keys/${domain}/mail.private /data/keys/${domain}
  cp /tmp/docker-mailserver/opendkim/keys/${domain}/mail.txt /data/txt/${domain}

  for config in {SigningTable,KeyTable,TrustedHosts}; do
    [ -f /configs/${config} ] && cat /configs/${config} > /data/configs/${config} || touch /data/configs/${config}

    new_config=/tmp/docker-mailserver/opendkim/${config}
    cat $new_config
    [ -f $new_config ] && cat $new_config >> /data/configs/${config}
    cat /data/configs/${config}
  done

  return 0
}


_update() {
  if ! _wait_done; then
    echo "Timed out waiting for dkimkeys to appear."
    exit 1
  fi

  echo "Storing dkim key in Kubernetes secret..."
  for key in $(ls /data/keys); do
    kubectl patch secret "$KEYS_SECRET_NAME" -p "{\"data\":{\"${key}\":\"$(base64 /data/keys/${key} -w 0)\"}}"
  done

  # merge...
  echo "Storing dkim txt in Kubernetes secret..."
  for txt in $(ls /data/txt); do
    kubectl patch secret "$TXTS_SECRET_NAME" -p "{\"data\":{\"${txt}\":\"$(base64 /data/txt/${txt} -w 0)\"}}"
  done

  echo "Storing dkim configs in Kubernetes configmap..."
  for config in $(ls /data/configs); do
    data=$(cat /data/configs/${config} | sort | uniq)
    #data="${data//\"/\\\"}"
    #data="${data//$'\t'/\\t}"
    data="${data//$'\n'/\\n}"
    kubectl patch configmap "$CONFIGMAP_NAME" -p "{\"data\":{\"${config}\":\"${data}\"}}"
  done
}

_wait_done() {
  echo "Waiting for dkimkeys to be generated..."
  begin=$(date +%s)
  end=$((begin + 300)) # 5 minutes

  while true;do
    [ -f /data/done ] && return 0
    [ "$(date +%s)" -gt $end ] && return 1
    sleep 5
  done
}

case $1 in
  "gen")
    shift
    _gen $@
  ;;
  "update")
    _update
  ;;
esac

