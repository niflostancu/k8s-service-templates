#!/bin/bash

if [[ -f "/etc/container.d/entry-extra.sh" ]]; then
	bash /etc/container.d/entry-extra.sh
fi

exec "/entrypoint.sh" "$@"

