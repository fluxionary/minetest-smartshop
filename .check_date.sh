#!/usr/bin/env bash
grep $(date -I) mod.conf
exit $?
