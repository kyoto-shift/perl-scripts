#!/usr/bin/perl

# !!!!!!!!!!!!!!! WHAT IS BITTER? !!!!!!!!!!!!!!!

# Bitter saves code snippets (known as "bits") of
# your code. Simply specify the start and end 
# lines and it'll do the rest!

# !!!!!!!!!!!!!!! WHAT IS BITTER? !!!!!!!!!!!!!!!

use Getopt::Long qw(GetOptions);
use POSIX qw(strftime);
Getopt::Long::Configure qw(gnu_getopt);

# =============== INFORMATION ===============
$name    = "bitter";
$version = "1.0";
$flavor  = "no cream, no sugar";

# =============== VARIABLES ===============
( $sec, $min, $hour, $mon, $mday ) = localtime(time);
$time = strftime "%Y%m%d-%H%M%S", localtime;
$error_help = "Please use --help to see usage details.\n";

# =============== FLAGS ===============
$input;
$output;
$dir          = "./";
$default_name = $dir . "snippet" . $time;
$line_start;
$line_end;

GetOptions(
    'file|f|i=s'        => \$input,
    'output|o=s'        => \$output,
    'directory|dir|d=s' => \$dir,
    'start|s=i'         => \$line_start,
    'end|e=i'           => \$line_end,
    'help|h'            => \$help,
) or die $error_help;

if ($help) {
    print <<HELP

    $name $version ($flavor)
	
    Usage:
	--file, -f, -i [file]
		Specifies which file $name will make a snippet from.
	--output, -o [file]
		Specifies where to save the snippet. 
		If no output is specified, $name will automatically 
		create a snippet in the current directory.
	--directory, -dir, -d [directory]
		Allows you to specify where snippets are saved
		while still using the default naming scheme.
	--start, -s [number]
		The line number where your snippet starts.
	--end, -e [number]
		The line number where your snippet ends.
	--help, -h
		Displays this cool shit.

HELP
        ;
    exit;
}

# =============== CHECKS ===============
if ( !$input ) {    # check if a file was specified
    print "No file specified! $error_help" and exit;
}

# if we didn't get an output, make one with the input's extension
# and reassign our default_name if we got a new directory
if ( !$output ) {
    $default_name = $dir . "snippet" . $time;
    ($ext) = $input =~ /(\.[^.]+)$/;
    $output = $default_name . $ext;
}

# =============== PROCESSING ===============
open( DATAFILE, $input )
    or print "File '$input' doesn't exist! Please try again!\n" and exit;
@lines = <DATAFILE>;
close(DATAFILE);

# loop over the specified start and end points
for ( $i = $line_start - 1; $i < $line_end; $i++ ) {
    $lines .= @lines[$i];
}

# =============== OUTPUT ===============
# unless we can save to the specified directory, exit
unless ( open SAVETO, '+>' . $output ) {
    print "Unable to create $output. Please check your permissions.\n"
        and exit;
}

chomp($lines);          # trim off any excess lines
print SAVETO $lines;    # write our new file
close(SAVETO);          # close file

print "Snippet saved to $output\n";

# Copyright © 2018 - Judah Caruso Rodriguez (0px.moe)