#!/bin/bash

#Sinks array space-separated. Add or remove sink names from "pactl list short sinks" command output to switch to with this script.
declare -a SINKS_TO_SWITCH=("alsa_output.pci-0000_00_1b.0.analog-stereo" "alsa_output.pci-0000_00_03.0.hdmi-stereo-extra1")
SINK_ELEMENTS=$(echo ${#SINKS_TO_SWITCH[@]})

#get current sink
ACTIVE_SINK_ID=$(pacmd info | sed -n '/sink(/,/source(/p' | grep '*' | awk '{print $3}')
ACTIVE_SINK_NAME=$(pactl list short sinks | grep ^"$ACTIVE_SINK_ID" | awk '{print $2}')

#get active sink array index
ACTIVE_ARRAY_INDEX=$(echo ${SINKS_TO_SWITCH[@]/$ACTIVE_SINK_NAME//} | cut -d/ -f1 | wc -w | tr -d ' ')

#get next element in array
NEXT_ARRAY_INDEX=$(($ACTIVE_ARRAY_INDEX+1))
NEXT_ARRAY_INDEX=$(($NEXT_ARRAY_INDEX%$SINK_ELEMENTS))
NEXT_SINK_NAME=${SINKS_TO_SWITCH[$NEXT_ARRAY_INDEX]}
NEXT_SINK_ID=$(pactl list short sinks | grep $NEXT_SINK_NAME | awk '{print $1}')

#switch to sink
pacmd set-default-sink $NEXT_SINK_ID
notify-send AudioSwitch "Switching to $NEXT_SINK_NAME"
