## hdHomeRun tuner tool

Perl frontend for the Silicon Dust hdHomeRun tuners



The first thing that needs to be done is to scan for all the channels that your
Tuner can find and create a file of that info.  This takes 5-10mins, so you only 
need to do it once and anytime you think your available channels change. 
 
 $  hdHomeScanToChannelProgram.pl -s 


To see the available channels that you can watch
 
 $  hdHomeScanToChannelProgram.pl -l 



To tune into a channel (6.1 in this example).
 
 $  hdHomeScanToChannelProgram.pl -f 6.1

