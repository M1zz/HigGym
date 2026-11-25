#!/bin/zsh
# usage: capture.sh name "ENV=V ENV2=V2" [wait]
SP=${0:A:h}
name=$1; envs=$2; wait=${3:-4}
xcrun simctl terminate booted com.leeo.higgym 2>/dev/null
args=()
for kv in ${(z)envs}; do args+=("SIMCTL_CHILD_$kv"); done
env $args xcrun simctl launch booted com.leeo.higgym -AppleLanguages "(ko)" -AppleLocale ko_KR >/dev/null
sleep $wait
xcrun simctl io booted screenshot --type=png $SP/raw/$name.png >/dev/null 2>&1 && echo "$name ok"
