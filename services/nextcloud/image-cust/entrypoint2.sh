#!/bin/bash
# Custom container entrypoint which modifies the UID / GID for the nextcloud user

NEXTCLOUD_USER=www-data

if [ -z "$NEXTCLOUD_UID" ]; then
	NEXTCLOUD_UID=1000
fi
if [ -z "$NEXTCLOUD_GID" ]; then
	NEXTCLOUD_UID=1000
fi

usermod -u "$NEXTCLOUD_UID" "$NEXTCLOUD_USER"
groupmod -g "$NEXTCLOUD_GID" "$NEXTCLOUD_USER"

if [[ -f "/etc/container.d/entry-extra.sh" ]]; then
	bash /etc/container.d/entry-extra.sh
fi

exec "/entrypoint.sh" "$@"

