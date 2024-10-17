#!/bin/bash
# Author: Ruben Lopez (Logon84) <rubenlogon@yahoo.es>
# Description: A shell script to switch pulseaudio sinks (outputs).

# Add sink names (separated with '|') to SKIP while switching with this script. Choose names to skip from the output of this command:
# pactl list short sinks | awk '{print $2}'
# if no skip names are added, this script will switch between every available audio sink (output).
SINKS_TO_SKIP=("other_sink_name1|other_sink_name2|other_sink_name3")

#Define Aliases (OPTIONAL)
ALIASES="sink_name1:ALIAS1\nsink_name2:ALIAS2"

#Create array of sink names to switch to
declare -a SINKS_TO_SWITCH=($(pactl list short sinks | awk '{print $2}' | grep -Ev $SINKS_TO_SKIP))
SINK_ELEMENTS=$(echo ${#SINKS_TO_SWITCH[@]})

#get current sink name and array position
ACTIVE_SINK_ID=$(pacmd info | sed -n '/sink(/,/source(/p' | grep '*' | awk '{print $3}')
ACTIVE_SINK_NAME=$(pactl list short sinks | grep ^"$ACTIVE_SINK_ID" | awk '{print $2}')
ACTIVE_ARRAY_INDEX=$(echo ${SINKS_TO_SWITCH[@]/$ACTIVE_SINK_NAME//} | cut -d/ -f1 | wc -w | tr -d ' ')

#Get next array name and ID
NEXT_ARRAY_INDEX=$((($ACTIVE_ARRAY_INDEX+1)%$SINK_ELEMENTS))
NEXT_SINK_NAME=${SINKS_TO_SWITCH[$NEXT_ARRAY_INDEX]}
NEXT_SINK_ID=$(pactl list short sinks | grep $NEXT_SINK_NAME | awk '{print $1}')

#switch to sink
pacmd set-default-sink $NEXT_SINK_ID
$(gdbus call --session \
             --dest org.freedesktop.Notifications \
             --object-path /org/freedesktop/Notifications \
             --method org.freedesktop.Notifications.CloseNotification \
             "$(</tmp/sss.id)")
ALIAS=$(echo -e $ALIASES | grep $NEXT_SINK_NAME | awk -F ':' '{print ($2)}')
$(gdbus call --session \
             --dest org.freedesktop.Notifications \
             --object-path /org/freedesktop/Notifications \
             --method org.freedesktop.Notifications.Notify sss \
             0 \
             gtk-dialog-info "Sound Sink Switcher" "Switching to $NEXT_SINK_ID : $NEXT_SINK_NAME ($ALIAS)" [] {} 5000 | \
             sed 's/(uint32 \([0-9]\+\),)/\1/g' > /tmp/sss.id)
