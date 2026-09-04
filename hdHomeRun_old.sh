#!/usr/bin/bash
# --- Configuration ---
HDHD_ID="10725EFE"
HDHR_IP="192.168.0.6" # Your HDHomeRun's IP address
PC_IP="192.168.0.38"  # the PC that you wish to stream too
VLC_PORT="5000"         # A free UDP port
CHANNEL_FREQ="$1" # Example frequency for a channel
CHANNEL="24"      # Example channel
PROGRAM=$2
TUNER=0
UDP=1

$HOME/bin.local/libhdhomerun/hdhomerun_config $HDHR_IP set /tuner"$TUNER"/target none
# --- Script ---
# 1. Tune the HDHomeRun to the channel
$HOME/bin.local/libhdhomerun/hdhomerun_config $HDHR_IP set /tuner"$TUNER"/channel auto:$CHANNEL_FREQ

# 2. set the program id
$HOME/bin.local/libhdhomerun/hdhomerun_config $HDHR_IP set /tuner$TUNER/program $PROGRAM

# 3. show status
$HOME/bin.local/libhdhomerun/hdhomerun_config $HDHR_IP get /tuner"$TUNER"/status

if [ $UDP -eq 0 ] ; then
    # redirect output to vlc
    echo Running the redirect method
    $HOME/bin.local/libhdhomerun/hdhomerun_config $HDHR_IP save /tuner"$TUNER" - | vlc - 
fi


# UDP method
if [ $UDP -eq 1 ] ; then
    echo Running UDP method
    # 3. Tell the tuner to stream to VLC (adjust port if needed)
    $HOME/bin.local/libhdhomerun/hdhomerun_config $HDHR_IP set /tuner"$TUNER"/target udp://$PC_IP:$VLC_PORT

    # 3. Open VLC to listen on that UDP port
    # (This command might need tweaking for your OS)
    # '&' runs it in the background
    vlc udp://@:$VLC_PORT & 
    # cvlc doesn't seem to work

fi
# (Optional) After closing VLC, you might need to reset the tuner
# $HOME/bin.local/libhdhomerun/hdhomerun_config $HDHR_IP set /tuner"$TUNER"/target none

