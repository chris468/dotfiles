#!/usr/bin/env bash

local_time="$(date +'%H:%M%z')"
local_date=" $(date +'%m/%d')"
utc_time="$(date -u +'%H:%M')"
utc_date=" $(date -u +'%m/%d')"

tomorrow=
if [[ "$utc_date" != "$local_date" ]]; then
	tomorrow='󰑎'
fi

echo "${local_time%00}$local_date ($utc_time$tomorrow)"
