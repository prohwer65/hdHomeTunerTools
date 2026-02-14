#!/bin/bash
TUNER_ID="10725EFE"
CMD_HD="/home/prohwer/bin.local/libhdhomerun/hdhomerun_config"


USAGE="
Silicon Dust HDHomeRun TV tuner script

Usage:    $0  vchannel

Options:      
  -h                     This Help menu 
  -c  [tuner]            Clear a Tuner [0..3].
  -s                     Show all the Tuners Status
  -t                     Show all the Tuners targets, if any.
  -v  [virtual channel]  Set an open tuner to Virtual Channel and Stream to VLC



"


HDHomeRunHelp="HDHomeRun Help
Supported configuration options:
/lineup/scan
/sys/copyright
/sys/debug
/sys/features
/sys/hwmodel
/sys/model
/sys/restart <resource>
/sys/version
/tuner<n>/channel <modulation>:<freq|ch>
/tuner<n>/channelmap <channelmap>
/tuner<n>/debug
/tuner<n>/filter \"0x<nnnn>-0x<nnnn> [...]\"
/tuner<n>/lockkey
/tuner<n>/program <program number>
/tuner<n>/status
/tuner<n>/plpinfo
/tuner<n>/streaminfo
/tuner<n>/target <ip>:<port>
/tuner<n>/vchannel <vchannel>
"


declare -a TUNERLIST=( {0..3} )

### Functions ############################################################
### Functions ############################################################
### Functions ############################################################
### Functions ############################################################
### Functions ############################################################
#

clearTuner () {
    local tuner

    set -o xtrace
    tuner="$1"
    "$CMD_HD" "$TUNER_ID"  set /tuner"$tuner"/channel none
    set +o xtrace
}


discoverTuner () { 
    # device id of homerun
    local DEVICE
    DEVICE=$(hdhomerun_config discover | awk '{print $3}')
    echo "$DEVICE"
}
showTunerStatus ()  {
    for tuner in "${TUNERLIST[@]}"; do 
        echo -n "Tuner""$tuner"": "

        "$CMD_HD" "$TUNER_ID"  get /tuner"$tuner"/status  | grep "ch="
    done

}


showTunerTarget ()  {
    for tuner in "${TUNERLIST[@]}"; do 

        if "$CMD_HD" "$TUNER_ID"  get /tuner"$tuner"/status  | grep -q "ch=8" ; then 
            echo -n "Tuner""$tuner"": is targeting  "
            "$CMD_HD" "$TUNER_ID"  get /tuner"$tuner"/target  
        fi
    done

}


findOpenTuner ()  {
    for tuner in "${TUNERLIST[@]}"; do 

        if "$CMD_HD" "$TUNER_ID"  get /tuner"$tuner"/status  | grep -q "ch=none" ; then 
            echo "$tuner"
            return
        fi
    done

}

streamToVLC () { 

    local TUNER
    local RTP_PORT
    local CHANNEL
    local PROGRAM
    local virtualChannel=$1

    TUNER=$(findOpenTuner)

    myipAddress=$(getMyIPAddress)



    # arbitrary port for VLC to listen on
    RTP_PORT=5000

    set -o xtrace
    # won't work if VLC is already running
    killall -9 VLC > /dev/null 2>&1
    sleep 0.5

    # set the tuner channel
    #"$CMD_HD" "$TUNER_ID" set /tuner$TUNER/channel auto:$CHANNEL

    # set the program id
    #"$CMD_HD" "$TUNER_ID" set /tuner$TUNER/program $PROGRAM
    "$CMD_HD" "$TUNER_ID" set /tuner"$TUNER"/vchannel "$virtualChannel"
    #/tuner<n>/vchannel <vchannel>

    # tell it to send the video stream our way
    "$CMD_HD" "$TUNER_ID" set /tuner"$TUNER"/target rtp://"$myipAddress":"$RTP_PORT"
    # start VLC listening for stream
    vlc rtp://@:"$RTP_PORT"   > /dev/null 2>&1

    clearTuner "$TUNER"
    set +o xtrace
    
}


getMyIPAddress () { 

    #set -o xtrace
    # this computer's ip address I want the Homerun to connect to
    local MY_IP
    MY_IP=$(ifconfig | grep -v "127.0.0" | grep -w inet | awk '{print $2}')
    if [ -z "$MY_IP" ]; then
        MY_IP=$(ifconfig |  grep -w inet6 | awk '{print $2}')
    fi

    echo "$MY_IP"
    #set +o xtrace
}


#### Main ######################################################################
#### Main ######################################################################
#### Main ######################################################################
#### Main ######################################################################
#### Main ######################################################################

if [ "$1" == "-h" ]; then
    echo "$USAGE"
    echo "$HDHomeRunHelp"
    exit 0;
fi

if [ "$1" == "-s" ]; then
    showTunerStatus
    exit 0
fi
if [ "$1" == "-t" ]; then
    showTunerTarget
    exit 0
fi

if [ "$1" == "-c" ]; then
    clearTuner  "$2"
    exit 0
fi

if [ "$1" == "-v" ]; then
    streamToVLC  "$2"
    exit 0
fi

openTuner=$(findOpenTuner)

myipAddress=$(getMyIPAddress)
echo My IP Address is "$myipAddress"

echo "There is a open tuner at " "$openTuner"


if [  -n "$1" ]; then
    echo Running: "$CMD_HD" "$TUNER_ID"  "$@"
    "$CMD_HD" "$TUNER_ID"  "$@"
fi 
#/home/prohwer/bin.local/libhdhomerun/hdhomerun_config 10725EFE  "$@"
