#!/bin/bash

# Get current layout from hyprctl
layout=$(hyprctl devices | grep "active keymap" | awk '{print $NF}')
echo "$layout"
