#!/usr/bin/env perl
#===============================================================================
#
#         FILE: hdHomeScanToChannelProgram.pl
#
#        USAGE: ./hdHomeScanToChannelProgram.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Paul Rohwer (PWR), prohwer65@gmail.com
# ORGANIZATION: PowerAudio
#      VERSION: 1.0
#      CREATED: 12/31/2025 09:48:37 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use FindBin qw{$Script };
#use FindBin qw{$Bin $Script $RealBin $RealScript $Dir $RealDir};

my $VERSION        = '';

my $DOCUMENTATION = <<EOMESSAGE;
hdHomeRun Configuration Front end.  Simplifies the use of Silicon Dust's HD HomeRun TV Tuner

Usage : $Script [-he [-w Z] [-d X] [-f N] 

    Options     : Descriptions
    --------      ------------------------------------------------------
    -h          : Help menu
    -s          : Scan all the TV channels and create a list of all available channels.
                : Note, this takes 5-10 mins to run.  
                : It creates a file to avoid having to run frequently.  
                :
    -D  n       : Change he DEBUG level to n.  Default is 0
    -f  n.n     : Change the tuner to channel n.n and redirect to VLC
    -w  win     : Option with agrument
    --help      : Help Menu
    --version   : Version 

EOMESSAGE

use Getopt::Std;
use POSIX ":sys_wait_h";
use English '-no_match_vars';
    # see perlvar for variable names and features
    # no_match to reduce regx effiecency loss


#use File::stat;
#use File::Copy;
use Config;
use Data::Dumper;


#use Readonly;
#Readonly my $PI => 3.14;

# ------------------------------------------------------------------------------
# BEGIN
# ------------------------------------------------------------------------------
#BEGIN {
#}

# ------------------------------------------------------------------------------
# INIT
# ------------------------------------------------------------------------------
#INIT {
#}

# ------------------------------------------------------------------------------
# END
# ------------------------------------------------------------------------------
#END {
#}

# ------------------------------------------------------------------------------
# CHECK
# ------------------------------------------------------------------------------
#CHECK {
#}

# ------------------------------------------------------------------------------
# declare sub  <+SUB+>
# ------------------------------------------------------------------------------
sub passing_argu_3orless;
sub passing_argu_4ormore;
sub HELP_MESSAGE();
sub VERSION_MESSAGE();

# ------------------------------------------------------------------------------
# global variables
# ------------------------------------------------------------------------------

my $OS;
my %cmdLineOption;
my $findTVChannel;
my $DEBUGLEVEL=0;
my $HOME="/home/pohwer";
my $hdHomeConfigCmd = "/home/prohwer/bin.local/libhdhomerun/hdhomerun_config";
my $scanfilename = '/home/prohwer/Documents/perl/hdHomeScanToChannelProgram/scanOutput.txt';
getopts( "hsD:f:", \%cmdLineOption );
    #	<+INPUTOPTIONS+>

 # examples of direct associating
my @ARRAY = qw(0  2 3 4 5 6 7 8 9   17 19 20 21 23 25);
my %HASH  = ( somevalue => 'as', );

my $ref_ARRAY = [ qw(0  2 3 4 5 6 7 8 9   17 19 20 21 23 25)] ;
my $ref_HASH  = { somevalue => 'as', another => "value", };
# ------------------------------------------------------------------------------
# Database of values;
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# parse command line and setup defaults
# ------------------------------------------------------------------------------
if ( $Config{'osname'} =~ /Win/ ) {
    $OS = "Windows";
}

local $Data::Dumper::Sortkeys = 1;
local $Data::Dumper::Purity   = 1;  ##new to verify this

#print Data::Dumper->Dump( [ \%Config ], [qw(Config  )] );

if ( defined $cmdLineOption{h} ) {
    HELP_MESSAGE();
    exit(15);
}

if ( defined $cmdLineOption{D} )  {
    $DEBUGLEVEL =   $cmdLineOption{D} ;
    #<+INPUTOPTIONS+>
}

if ( defined $cmdLineOption{f} )  {
   $findTVChannel =   $cmdLineOption{f} ;
   #<+INPUTOPTIONS+>
}

if ( defined $cmdLineOption{s} )  {
    scan_hdHomeRun_channels();
    exit(0);
    
}
# ------------------------------------------------------------------------------
#  MAIN part of program
# ------------------------------------------------------------------------------

#<+MAIN+>
#my $time = localtime();

my $hdHomeConfig = discoverHDHome();
print Data::Dumper->Dump( [  \$hdHomeConfig ], [qw(hdHomeConfig   )] ) if ( $DEBUGLEVEL > 1);


my $channelProgram = getFreqChannelList();
print Data::Dumper->Dump( [  \$channelProgram ], [qw(channelProgram   )] ) if ( $DEBUGLEVEL > 2);


print "Searching for $findTVChannel\n" if ( $DEBUGLEVEL > 2);
if ( defined $findTVChannel && defined $channelProgram->{ $findTVChannel} ) {
    print $channelProgram->{ $findTVChannel }{Ch} . "  " . $channelProgram->{ $findTVChannel}{Prog} . "\n";

    my $script = '/home/prohwer/Documents/perl/hdHomeScanToChannelProgram/hdHomeRun.sh';

    my $runStr = "$script $channelProgram->{ $findTVChannel }{Ch} $channelProgram->{ $findTVChannel}{Prog} ";
    print $runStr . "\n";
    system( $runStr );
}
exit 0;



passing_argu_3orless( 1, 2, 3 );
my $runFunction = \&passing_argu_3orless;

&{ $runFunction }(4, 5, 6);
# or [\&passing_argu_3orless, 4, 5, 6 ]   # when passing a agru to another function like Tk's -command =>  


passing_argu_4ormore( { text => "test", cols => 20, centered => 1, } );

my $sc = returnScalar();
my $ar = returnArray();
my $ha = returnHash();

my $b = 0;
my $a = ref( \$b);

print "Return Scalar ". $a ." \n";
print "Return Array ". ref( $ar ) ." \n";
print "Return Hash ". ref( $ha ) ." \n";
print "Return Hash ". scalar( $ha ) ." \n";


#print Data::Dumper->Dump( [ \$time, \@ARRAY, \%cmdLineOption, \%HASH ], [qw(time   ARRAY    cmd_line_option    HASH )] );

exit 0;

# ------------------------------------------------------------------------------
# Define subroutines
#     <+SUB+>
# ------------------------------------------------------------------------------

sub passing_argu_3orless {

    # unpack input arguments
    my ( $first, $second, $third ) = @_;

    print "passing_argu_3orless()\n";
    print "First arg is $first, then $second, and $third\n";
}

sub passing_argu_4ormore() {

    # when passing in several input arguments, use a hash
    my ($in_argu_ref) = @_;

    print "passing_argu_4ormore()\n";
    if ( !defined $in_argu_ref->{junk} ) {
        # set an agrument to default value if not defined. 
        $in_argu_ref->{junk} = "JUNK";
    }

    foreach my $key (keys %$in_argu_ref) {
        print "$key -> $in_argu_ref->{$key}, ";
    }
    print "\n";

    #print " $in_argu_ref->{cols};\n";
    #print " $in_argu_ref->{centered};\n";
} # end of passing_argu_4ormore


sub returnScalar {
    my $a = 0;
    return \$a;
}

sub returnArray {
    my @a = qw/ 1 2 3/; 
    return \@a;
}

sub returnHash {
    my %a = ( 'a' => 'asdf');

    return \%a;
}

sub scan_hdHomeRun_channels {

    system( "$hdHomeConfigCmd 10725EFE scan /tuner0  $scanfilename  ");
}

sub getFreqChannelList {
    my %channelProgram;

    my $lastChannel;


    # Open the file for reading (mode '<')
    open(my $fh, '<:encoding(UTF-8)', $scanfilename) or die "Could not open file '$scanfilename' $!";

    # Read each line from the filehandle ($fh) into the variable $line
    while (my $line = <$fh>) {
        # Remove the newline character from the end of the line
        chomp $line;
        
        # Process the line here (e.g., print it, split it, run regex)
        print "Processing line: $line\n" if ( $DEBUGLEVEL > 9);
        if ( $line =~ /SCANNING/ ) {
            my @fields = split(/ /, $line);
            print "Channel Freq field is: $fields[1]\n" if ( $DEBUGLEVEL > 8);
            $lastChannel=$fields[1];
        }
        if ( $line =~ /PROGRAM/ ) {
            my @fields = split(/[: ]/, $line);
            print "Program field is: $fields[1]\n" if ( $DEBUGLEVEL > 8);
            print "TVChannel field is: $fields[3]\n" if ( $DEBUGLEVEL > 8);

            $channelProgram{$fields[3]}{Ch} = $lastChannel;
            $channelProgram{$fields[3]}{Prog} = $fields[1];
            $channelProgram{$fields[3]}{Name} = $fields[4];
        }

            
        
        # Example: split the line by a delimiter (e.g., comma)
        # my @fields = split(/,/, $line);
        # print "First field is: $fields[0]\n";
    }

    # Close the filehandle
    close $fh;


    return \%channelProgram;
}



#===  FUNCTION  ================================================================
#{{{1     NAME: discoverHDHome
#      PURPOSE: Use the hdhomerun_config program to discover any Silicon
#               Dust tuner and return the ID and the IP address.
#   PARAMETERS: ????
#      RETURNS: A hash that hold the ID and IP address of the first found
#               tuner.
#               $hdHomeConfig = \{
#                    'hdHomeID' => '10725EFE',
#                    'hdHomeIP' => '192.168.0.6'
#                  };
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub discoverHDHome {


    my $command = "$hdHomeConfigCmd discover -4"; # Command as an array of arguments
    my $hdHomeID;
    my $hdHomeIP;
    my %hdHomeConfig;

    # Open a pipe to run the command, reading its STDOUT
    if (open(my $fh, '-|', $command)) {
        while (my $line = <$fh>) {
            # Process each line as it's read
            print "Line: $line" if ( $DEBUGLEVEL > 3);
            # "unable to connect to device"  : could mean a firewall issue.
            # 
            # You can use regex here to parse the line, e.g.,
            # if ($line =~ /^drwx/) { ... }
            if ( $line =~ /found/ ) {
                chomp $line;
                my @fields = split(/ /, $line);
                $hdHomeConfig{hdHomeID} = $fields[2];
                $hdHomeConfig{hdHomeIP} = $fields[5];
                print "HD Home found.  ID=$hdHomeConfig{hdHomeID}.  IP=$hdHomeConfig{hdHomeIP}. \n" if ($DEBUGLEVEL > 0);
                return  \%hdHomeConfig;
            }

        }
        close($fh) or die "Error closing pipe: $!";
    } else {
        die "Can't open pipe from $command: $!";
    }


}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
sub HELP_MESSAGE() {

    print <<EOTEXT;
-----------------------------------------------------------------------------
$Script - TITLE
$DOCUMENTATION

$^X
EOTEXT
    exit(1);
}

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
sub VERSION_MESSAGE() {
    $Getopt::Std::STANDARD_HELP_VERSION = 1;

    # The above prevents this function from running exit();
    # but it causes a false warning, therefore I print it.
    print "$Script :  $VERSION $Getopt::Std::STANDARD_HELP_VERSION \n";
}


##################################################################
#                                                                #
#                                                                #
#                                                                #
##################################################################

# }}}1
# vim:tabstop=4:si:expandtab:shiftwidth=4:shiftround:set foldenable foldmethod=marker:


