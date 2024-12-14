#!/bin/bash

adb logcat -c
stdbuf -oL adb logcat | grep -E "processing-score|network-time" > log.txt
