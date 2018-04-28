#!/usr/bin/perl

use strict;
use warnings;

my $file = $ARGV[0];
my $new  = $file;

unless ($file) { die("No file specified! Usage: $0 file-to-compile.c\n"); }

if (-e $file) {
    $new =~ s/([.].*)//;
    print("Compiling file '$file'...");
    system("gcc $file -o $new");
    print("\rExecuting file '$new'\n");
    exec("./$new");
} else { die("File '$file' doesn't exist!\n"); }

# Copyright © 2018 - Judah Caruso Rodriguez (0px.moe)