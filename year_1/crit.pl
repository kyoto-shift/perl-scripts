#!/usr/bin/perl

# !!!!!!!!!!!!!!! WHAT IS CRIT? !!!!!!!!!!!!!!!

#    Crit adds a copyright tag to any file.

# !!!!!!!!!!!!!!! WHAT IS CRIT? !!!!!!!!!!!!!!!

use strict;
use warnings;
use Getopt::Long;

# =============== PKG INFO ===============
my $pkg_name    = "crit";
my $pkg_version = "0.4";

# =============== INIT VARIABLES ===============
my (
    $name,
    $copyright,    # copyright (c) year - name
    $comment,      # type of comment we use
    $added_num,    # number of files we've modified
    $file_tp,      # file to process
    $handler,      # open/saving file handler
    @file_lines,
    $year,
);

$year      = 1900 + (localtime)[5];
$name      = "Judah Caruso Rodriguez (0px.moe)";
$comment   = "#";
$copyright = "\n$comment Copyright \x{00a9} $year - $name";
$added_num = 0;

# =============== CHECK FLAGS ===============
if ( @ARGV == 0 ) {
    die "Adds a copyright tag to files.\nUsage: $pkg_name [file ...]\n";
}

# =============== FILE PROCESSING ===============
for ( my $i = 0; $i < @ARGV; $i++ ) {
    for $file_tp ( $ARGV[$i] ) {
        open( $handler, "<", $file_tp )
            or die "Fatal: Unable to open file '$file_tp'! $!\n";
        {
            local $/;
            undef $/;
            @file_lines = <$handler>;
        }
        if ( "@file_lines" =~ /^($comment.*)(Copyright.*)/im ) {
            print
                "Skipping file:  '$ARGV[$i]' (contains copyright information)\n";
            next;
        }
        else {
            open( $handler, ">>", $file_tp )
                or die "Fatal: Unable to write to file '$file_tp'! $!\n";
            print $handler $copyright;    # commit changes to file
            print "Modifying file: '$ARGV[$i]'\n";
            $added_num++;
        }
        close $handler;
    }
}

# =============== FINAL OUTPUT ===============
print "Processing complete! Modified $added_num file(s)\n";

# Copyright © 2018 - Judah Caruso Rodriguez (0px.moe)