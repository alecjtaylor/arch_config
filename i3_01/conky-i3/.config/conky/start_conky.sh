#!/bin/bash
killall -q conky
sleep 10s 
conky -c "$HOME/.config/conky/conky.conf" &
