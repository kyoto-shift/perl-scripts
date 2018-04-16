#!/usr/bin/perl

# !!!!!!!!!!!!!!! WHAT IS LIBRARYPARSER? !!!!!!!!!!!!!!!

# I love lexers and parsers, so I thought I'd try making 
# a basic one in Perl. However, this isn't technically a
# parser, as it doesn't Tokenize  or  create  any  data-
# structure from its input. However, it does technically
# parse data, just not in the traditional (smarter) way.

# !!!!!!!!!!!!!!! WHAT IS LIBRARYPARSER? !!!!!!!!!!!!!!!

use strict;
use warnings;
use Date::Simple (':all');

# =============== INIT VARS ===============
my @file_lines;
my @checked;
my @n_checked;
my @overdue;
my $date = today();

# =============== TOKENS ===============
my %chars = (
    "white_space"   => " ",
    "comment"       => "!!",
    "colon"         => ":",
    "dash"          => "-",
    "equals"        => "=",
    "semi_colon"    => ";",
    "forward_slash" => "/",
    "checked"       => "true",
    "n_checked"     => "false",
    "out"           => "out",
    "due"           => "due",
);

# I realize this is not the best way to do this.

my $ws    = $chars{"white_space"};      # WHITESPACE (  )
my $colon = $chars{"colon"};            # COLON ( : )
my $sc    = $chars{"semi_colon"};       # SEMI COLON ( ; )
my $fs    = $chars{"forward_slash"};    # FORWARD SLASH ( / )
my $dash  = $chars{"dash"};             # DASH ( - )
my $eq    = $chars{"equals"};           # EQUALS ( = )
my $cm    = $chars{"comment"};          # COMMENT ( !! )
my $true  = $chars{"checked"};          # true
my $false = $chars{"n_checked"};        # false
my $out   = $chars{"out"};              # out
my $due   = $chars{"due"};              # due

# =============== REGEXes ===============
my $out_eq   = qr/$out.*$eq.*/;                 # checks for out=
my $due_eq   = qr/$due.*$eq.*/;                 # checks for due=
my $date_seq = qr/(?<=$eq)([0-9].*)(?=$sc)/;    # check for a date

# =============== FILE CONTROL ===============
open( my $file, "<", $ARGV[0] )
    or die "Failed to open configuration file: $!\n";

while (<$file>) {
    chomp($_);
    our $gen_error = "Fatal: Failed to parse '$_' at line $.!\n";

    if    ( $_ =~ /^($cm)/ ) { }                   # if comment, do nothing
    elsif ( $_ =~ /^$ws*$/ ) { }                   # if empty line, do nothing
    elsif ( $_ !~ /($colon.*)?.*$eq.+($sc)/ ) {    # if not sequence, exit
        print $gen_error and exit;
    }
    chomp;
    push @file_lines, $_;
}

close $file;

# =============== DATA HANDLING ===============
foreach my $line (@file_lines) {
    my @book_title  = $line =~ m/.+?(?=$colon)/g;
    my @book_status = $line =~ m/$colon(.*)/g;
    my ($new_time)  = "@book_status" =~ /($date_seq)/;

    # if we have out=true
    if ( "@book_status" =~ /($out_eq)$true($sc)/ ) {
        push @checked, ( "@book_title" . "\n\t@book_status" );
    }   
    # if we have out=false
    elsif ( "@book_status" =~ /($out_eq)$false($sc)/ ) {
        push @n_checked, ( "@book_title" . "\n\t@book_status" );
    }

    # if we have a date sequence
    if ( "@book_status" =~ /($date_seq)/ ) {
        # convert our status to a date
        my $cmp_date = Date::Simple->new($new_time);
        # compare that date to today's date
        my $diff = $cmp_date - today();
        if ( $diff < 0 ) {
            $diff = abs($diff);
            print "@book_title was due $diff days ago!\n";
        }
        elsif ( $diff == 0 ) {
            print "@book_title is due today!\n";
        }
        else {
            print "@book_title is due in $diff days!\n";
        }
    }
}

# Copyright © 2018 - Judah Caruso Rodriguez (0px.moe)