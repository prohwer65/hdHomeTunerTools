# hdHomeRun tuner tool

Bash frontend for the Silicon Dust hdHomeRun tuners.  I've tested this with an HDHR5-4US

Requirements:
- vlc




1.  The first thing that needs to be done is to discover if any hdHomeRun tuners are available. 

   > `hd.sh -d`
  
2. This will display the TUNER ID for any available tuners.   You'll need to edit the hd.sh file and change the 2nd line to match your tuner id.

   > Example:  `TUNER_ID="10725EFE"`

3. Use your tuner to scan for all the available channels that your Tuner can find.  This takes 5-10mins, so you only need to do it **once** and anytime you think your available channels change.

   > Example: `hd.sh -S`

4. List the available Virtuals channels. 
 
    > Example:`hd.sh -l`
   
5. Select a virtual channel and launch VLC to accept the stream from your tuner.

   > `hd.sh -l  <virtual channel>`

   > Example:   `hd.sh -v 7.2`


