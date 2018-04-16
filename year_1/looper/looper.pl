#!/usr/bin/perl

use strict;
use warnings;
use File::Path 'rmtree';

# !!!!!!!!!!!!!!! WHAT IS LOOPER? !!!!!!!!!!!!!!!

# Looper loops through archiving and extracting 
# folders/archives. To use an existing folder, 
# simply add an underscore(_) to the beginning of
# its name, then run looper with the folder name 
# (excluding the underscore). It'll then create a
# dotfile(.foldername) and delete the directory. 
# To convert back to a directory, run the same 
# command. This is a completed "loop."

# !!!!!!!!!!!!!!! WHAT IS LOOPER? !!!!!!!!!!!!!!!

my ( $folder, $archive );

# =============== CHECK FLAGS ===============
if ( $ARGV[0] && $ARGV[0] eq "-v" ) {
    die "looper v1.4.1\n";    # (stable.beta.alpha);
}
elsif ( $ARGV[0] && $ARGV[0] =~ /-h$/i ) {
    die "Turns folders into hidden archives.
    \rUsage: looper.pl [file ...]\n";
}

if ( $ARGV[0] ) {
    $folder  = "./_$ARGV[0]";
    $archive = "./.$ARGV[0]";
}
else {
    $folder  = "./_looperfile";
    $archive = "./.looperfile";
}

# =============== PROCESSING ===============
if ( -d $folder ) {    # folder exists, zip and delete
    print "Packing \"$folder\"\n";
    `tar -zcf $archive $folder`;

    print "Cleaning up...\n";
    rmtree($folder);    # delete folder, keep archive

    print "Process F->A completed!\n";
}
elsif ( -e $archive ) {    # archive exists, unzip and delete
    print "Unpacking \"$archive\"\n";
    `tar -xzf $archive`;

    print "Cleaning up...\n";
    unlink($archive);      # delete archive, keep folder

    print "Process A->F complete!\n";
}
else {                     # neither exists, create folder with default name
    mkdir($folder);
    print "Folder doesn't exist! Creating empty...\n";
}

# Copyright © 2018 - Judah Caruso Rodriguez (0px.moe)
