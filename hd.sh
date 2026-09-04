#!/bin/bash
TUNER_ID="10725EFE"
CMD_HD="$HOME/bin.local/libhdhomerun/hdhomerun_config"
SCANLOGGFILE="${0%/*}""/scanOutput.txt"


if [ ! -e "$CMD_HD" ]; then 
    echo "ERROR:   Unable to find hdhomerun_config executable"
    exit 1;
fi

USAGE="
Silicon Dust HDHomeRun TV tuner script

Usage:    $0  vchannel

Options:      
  -h                     This Help menu 
  -H                     Detailed Help menu 
  -c  [tuner list]       Clear Tuner [0..3].
  -d                     Discover Tuner's ID
  -l                     List available virtual channels
  -s                     Show all the Tuners Status
  -S                     Scan for all channels.  Note, this takes 5-10 mins.  $SCANLOGGFILE
                         Also creates a signalStrength.txt file to show signal strenght per locked freq.
  -t                     Show all the Tuners targets, if any.
  -v  [virtual channel]  Set an open tuner to Virtual Channel and Stream to VLC


Examples:
  $0  -c 1 3             Clear tuners 1 and 3
  $0  -S                 Scan for available channels and create signal strength file
  $0  -v 9.1             Launch VLC and stream virtual ch 9.1 to VLC.

"


HDHomeRunHelp="HDHomeRun Help
Parameters:
hd.sh get help
hd.sh get <item>
hd.sh set <item> <value>
hd.sh scan <tuner> [<filename>]
hd.sh save <tuner> <filename>
hd.sh upgrade <filename>


Supported configuration options:
/tuner<n>/channel <modulation>:<freq|ch>    Get/set modulation and frequency    
/tuner<n>/channelmap <channel map>          Get/set channel to frequency map
/tuner<n>/filter 0x<nnnn>-0x<nnnn> [...]    Get/set PID filter
/tuner<n>/program <program number>          Get/set MPEG program filter
/tuner<n>/target <ip>:<port>                Get/set target IP for tuner
/tuner<n>/status                            Display status of tuner
/tuner<n>/streaminfo                        Display stream info
/tuner<n>/debug                             Display debug info for tuner
/tuner<n>/lockkey                           Set/clear tuner lock
/ir/target <ip>:<port>                      Get/set target IP for IR
/lineup/location <countrycode>:<postcode>   Get/Set location for lineup
/lineup/location disabled                   Disable lineup server connection
/sys/model                                  Display model name
/sys/features                               Display supported features
/sys/version                                Display firmware version
/sys/copyright                              Display firmware copyright
/sys/debug                                  Display debug info     

Supported configuration options:
/lineup/scan                                Get
/sys/hwmodel                                Get
/sys/restart <resource>                     Get
/tuner<n>/plpinfo                           Get
/tuner<n>/vchannel <vchannel>               Get/set
"

# Quad had four tuners.   Adjust as neccasary.
declare -a TUNERLIST=( {0..3} )

### Functions ############################################################
### Functions ############################################################
### Functions ############################################################
### Functions ############################################################
### Functions ############################################################
#

clearTuner () {
    local tuner

    #set -o xtrace
    tuner="$1"
    "$CMD_HD" "$TUNER_ID"  set /tuner"$tuner"/channel none
    #set +o xtrace
}

createScanOutputFile () {

    local openTuner
    openTuner=$(findOpenTuner)
    "$CMD_HD" "$TUNER_ID"  scan /tuner"$openTuner" "$SCANLOGGFILE"

    # clear the tuner used during scan
    clearTuner "$openTuner"

    # print out the Freq, Signal Strength, and Signal Quality for all locked channels
    DATE=$(date +"%Y-%m-%d_%H:%M:%S")
    echo "$DATE"  | tee -a signalStrength.txt
    perl -lne 'print "$p $_" if $_ =~ /8vsb/; $p = $_' "$SCANLOGGFILE" | sort | tee -a signalStrength.txt 
}

listVirtualChannels () { 


    if [ ! -e "$SCANLOGGFILE" ]; then  
        echo "Not Scan Log File found.  Creating it takes about 5-10 mins"
        createScanOutputFile
    fi

    grep PROGRAM "$SCANLOGGFILE"  | awk 'BEGIN {print "VChannel" "\t"  "ChannelName"} { print $3 "\t\t" $4 } '

    

}


discoverTuner () { 
    # device id of homerun
    local DEVICE
    DEVICE=$("$CMD_HD" discover | awk '{print $3}')
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
    "$CMD_HD" "$TUNER_ID" set /tuner"$TUNER"/target "rtp://""$myipAddress"":""$RTP_PORT"
    # start VLC listening for stream
    vlc rtp://@:"$RTP_PORT"   > /dev/null 2>&1
    echo VLC retruned $?
    echo .
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

    #`echo "$MY_IP"  | awk '{print $1}'
    echo "$MY_IP"  | head -1
    #set +o xtrace
}


#### Main ######################################################################
#### Main ######################################################################
#### Main ######################################################################
#### Main ######################################################################
#### Main ######################################################################

if [ "$1" == "-h" ]; then
    echo "$USAGE"
    exit 0;
fi


if [ "$1" == "-H" ]; then
    echo "$HDHomeRunHelp"
    exit 0;
fi

if [ "$1" == "-d" ]; then
    tuner_id=$(discoverTuner)
    echo Change the scripts line 2 TUNER_ID="$tuner_id"
    exit 0
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
    shift
    for tuner in "$@"; do 
        echo Clearing $tuner
        clearTuner  "$tuner"
    done
    exit 0
fi

if [ "$1" == "-S" ]; then
    createScanOutputFile
    exit 0
fi

if [ "$1" == "-l" ]; then
    listVirtualChannels
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
