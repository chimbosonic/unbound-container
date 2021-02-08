#!/bin/bash
set -e
ROOT_HINTS="https://www.internic.net/domain/named.root"
ICANN_CERT="https://data.iana.org/root-anchors/icannbundle.pem"
CONFIG_FOLDER=/var/unbound/etc
PGID="2000"
PUID="2000"

function create_unbound_user() {
	echo "Creating unbound user"
	addgroup -g ${PGID} unbound
    	adduser -D -u ${PUID} -G unbound unbound
}


function install_unbound() {
	echo "Installing unbound"
	apk update
	apk add --no-cache tini drill curl unbound ca-certificates 
}

function get_root_hints() {
	echo "Fetching root hints"
	curl -q -o ${CONFIG_FOLDER}/root.hints -SL ${ROOT_HINTS}
	echo "Fixing permissions for root hints"
	chmod 0444 ${CONFIG_FOLDER}/root.hints
	chown unbound:unbound ${CONFIG_FOLDER}/root.hints
}

function get_root_key() {
	echo "Fetching Icann Keys"
	curl -o /tmp/icannbundle.pem -SL ${ICANN_CERT}
	echo "Fetching Root Anchor Key"
	unbound-anchor -a ${CONFIG_FOLDER}/root.key -c /tmp/icannbundle.pem -r ${CONFIG_FOLDER}/root.hints || echo "Root Key was updated" 
	echo "Fixing Root Anchor Key Permissions"
	chmod 0444 ${CONFIG_FOLDER}/root.key
	chown unbound:unbound ${CONFIG_FOLDER}/root.key
}

function clean_up() {
	echo "Changing ownership of /var/unbound to unbound user"
	chown -R unbound:unbound /var/unbound
	echo "Deleting temp files"
	rm -rf /tmp/*
}

create_unbound_user
install_unbound
get_root_hints
get_root_key
clean_up
