#!/usr/bin/env sh

# kill all instances of polybar
killall -q polybar

# Wait while all instances of polybar die
while pgrep -x polybar >/dev/null; do sleep 1; done

# Now launch polybar
polybar &

