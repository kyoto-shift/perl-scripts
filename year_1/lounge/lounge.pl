#!/usr/bin/perl

# !!!!!!!!!!!!!!! WHAT IS LOUNGE? !!!!!!!!!!!!!!!

#   Lounge is a small logging/note taking CLI!
#    Lounge was made so I could keep track of
#      how often I work on certain projects.

# !!!!!!!!!!!!!!! WHAT IS LOUNGE? !!!!!!!!!!!!!!!

use strict;
use warnings;
use POSIX qw[strftime];
use File::Path qw[make_path];
use File::Basename;

# =============== PKG INFO ===============
my $pkg_name    = "Lounge";
my $lc_name     = lc($pkg_name);
my $pkg_version = "1.3.5";
my $pkg_flavor  = "beanbag chair";
my $pkg_usage   = "$0 [create/config/show/clear] [options ...]";
my $pkg_help = 
<<HELP

    $pkg_name $pkg_version ($pkg_flavor)

    A small project logging cli to stop you from lounging around!

    Usage: $pkg_usage

        create [task] ["description of task"]
            Creates a new entry.
        config [time=12|24]
            Sets the time format to either 12/24 hour.
        show [log/config]
            Prints either the currently active configuration,
            or the entire $pkg_name file.
        clear [log]
            Clears your entire $pkg_name file. This cannot be undone.
        version 
            Prints the current version of $pkg_name. 
            Which is currently $pkg_version
        help
            Prints this shit!

HELP
;

# =============== INIT VARS ===============
my $time_cur = strftime( "%Y/%m/%d (%H:%M:%S)", localtime ); # sys time 24h
my $file_log = "$ENV{HOME}/.$lc_name/log.lounge";            # log file location
my $file_config = "$ENV{HOME}/.$lc_name/config.lounge"; # lounge config location
my $dir_log     = dirname($file_log);                   # /USER/.lounge/

# =============== MAIN LOGIC ===============
sub _start {
    if ( -d $dir_log ) { 
        _parse(); 
    } else {
        print "$pkg_name directory doesn't exist! Creating...\n";
        make_path $dir_log or die "Can't create $pkg_name directory! $!\n";
    }
}

sub _parse {
    if ( !@ARGV ) { die $pkg_help; }
    foreach (@ARGV) {
        if ( $ARGV[0] =~ /help\b/i ) { die $pkg_help; }
        elsif ( $ARGV[0] =~ /version\b/i ) { die $pkg_version, "\n"; }
        elsif ( $ARGV[0] =~ /create\b/i ) {    # CREATE A NEW LOG
            if (-e $file_config ) {   
                _check_config();
                shift(@ARGV);
                _add_new_log();
            } else {
                shift(@ARGV);
                _add_new_log();
            }
        }
        elsif ( $ARGV[0] =~ /config\b/i ) {    # CREATE/ADD TO CONFIG
            shift(@ARGV);
            _edit_config();
        }
        elsif ( $ARGV[0] =~ /show\b/i ) {
            shift(@ARGV);
            if (@ARGV == 0 ) { die "Not enough arguments passed!\n"; }
            foreach (@ARGV) {
                if ( $_ =~ /log(s)?/i ) {
                    open FILE, "<", $file_log
                        or die "Can't open $pkg_name file! $!\n";
                    while (<FILE>) {
                        print $_;
                    }
                    close FILE;
                } elsif ( $_ =~ /conf(iguration)?/i ) {
                    open CONFIG, "<", $file_config
                        or die "Can't open configuration! $!\n";
                    while (<CONFIG>) {
                        print $_;
                    }
                    close CONFIG;
                }
                else {
                    die "Invalid command '$_'!\n";
                }
            }
        }
        elsif ( $ARGV[0] =~ /clear\b/i) {     # DELETE ALL LOGS
            shift(@ARGV);
            if (@ARGV == 0 ) { die "Not enough arguments passed!\n"; }
            foreach (@ARGV) {
                if ( $_ =~ /log(s)?/i ) {
                    print "Are you sure you want to clear your $pkg_name file? [Y/n] ";
                    chomp(my $choice = <STDIN>);
                    if ($choice =~ /(y|yes)/i) {
                        open LOGGER, ">", $file_log
                            or die "Can't modify $pkg_name file! $!\n";
                            print LOGGER "";
                        close LOGGER;
                        die "$pkg_name file has been successfully cleared!\n";
                    } elsif ( $choice =~ /(n|no)/i) {
                        die "$pkg_name file has not been modified.\n";
                    }
                }
                else {
                    die "Invalid command '$_'!\n";
                }
            }
        }
        else {                               # INVALID COMMAND
            die
                "'$_' is not a command! Use --help for a list of valid commands!\n";
        }
    }
}

sub _check_config {
    my @lines;
    open CONFIGCHECKER, "<", $file_config
        or die "Can't open configuration! $!\n";
        push @lines, <CONFIGCHECKER>;
    close CONFIGCHECKER;
    # check our config for the only 2 options we have (time=12, time=24)
    # re-set time_cur based on what we find
    foreach my $line (@lines) {
        if ( $line =~ /time=12/i ) {
            $time_cur = strftime( "%Y/%m/%d (%I:%M:%S %p)", localtime );
        } elsif ( $line =~ /time=24/i ) {
            $time_cur = strftime( "%Y/%m/%d (%H:%M:%S)", localtime );
        } elsif ( $line =~ /\n/ ) {
            next;
        }
        else {
            die "Error at line $. in $file_config!\n";
        }
    }
}

sub _add_new_log() {
    if ( @ARGV == 2 ) {
        my $title = shift(@ARGV); 
        my $desc  = shift(@ARGV);
        open LOGGER, ">>", $file_log
            or die "Can't modify $pkg_name file! $!\n";
                print LOGGER "$time_cur: $title - $desc\n";
        close LOGGER;
        print "Task '$desc' was successfully added to '$title'\n";
    } elsif ( @ARGV < 2 ) {
        die "Not enough arguments passed!\n";
    } else {
        die "Too many arguments passed! Did you mean to use quotation marks?\n";
    }
}

sub _edit_config() {
    if (@ARGV == 0 ) { die "Not enough arguments passed!\n"; }
    foreach (@ARGV) {
        if ($_ =~ /time/i) {
            if ($_ =~ /12/ ) {
                open CONFIGSAVER, ">", $file_config 
                or die "Can't modify configuration! $!\n";
                    print CONFIGSAVER "time=12\n";
                close CONFIGSAVER;
                print "12 hour time has been set!\n";
            }  
            elsif ($_ =~ /24/ ) {
                open CONFIGSAVER, ">", $file_config 
                or die "Can't modify configuration! $!\n";
                    print CONFIGSAVER "time=24\n";
                close CONFIGSAVER;
                print "24 hour time has been set!\n";
            }
            else {
                die "Invalid configuration '$_'!\n";
            }
        }
    }
}

_start();
