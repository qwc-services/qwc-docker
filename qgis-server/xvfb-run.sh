#!/bin/sh

##
# Runit run script for xvfb
#

exec /usr/bin/Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset
