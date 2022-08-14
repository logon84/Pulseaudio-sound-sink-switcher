##!/bin/bash

#list sinks: pactl list short sinks
SINK1="alsa_output.pci-0000_00_03.0.hdmi-stereo-extra1"
SINK2="alsa_output.pci-0000_00_1b.0.analog-stereo"

#get current sink
ACTIVE_SINK_ID=$(pacmd info | sed -n '/sink(/,/source(/p' | grep '*' | cut -d ' ' -f 5)

#get inactive sink
NEXT_SINK=$(pactl list short sinks | grep "$SINK1\|$SINK2" | grep -v ^"$ACTIVE_SINK_ID")
NEXT_ID=${NEXT_SINK::1}

if [[ $NEXT_SINK == *$SINK1* ]]
then
	OUTPUT_NAME=$SINK1
else
	OUTPUT_NAME=$SINK2
fi

#switch to sink
$(pacmd set-default-sink $NEXT_ID)
echo "switching to sink $NEXT_ID"

notify-send AudioSwitch "Switching to $OUTPUT_NAME"
