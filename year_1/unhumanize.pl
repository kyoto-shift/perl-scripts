#!/usr/bin/perl

# !!!!!!!!!!!!!!! WHAT IS UNHUMANIZE? !!!!!!!!!!!!!!!

# Unhumanize obfuscates strings in Perl files while 
# keeping the output format intact. However, it's a 
# little broken right now... so it doesn't fully do 
# that yet.

# !!!!!!!!!!!!!!! WHAT IS UNHUMANIZE? !!!!!!!!!!!!!!!

# =============== TO DO ===============
# 1. fix variables and lists being encoded literally
# 2. general cleaning and fixing

# use warnings;
use strict;
use Encode;

my ( $string, $handler, $file_tp, @file_lines, $found_quote, $new_val,
    $old_val, @old_vars, @new_vars);
my $reg_quoted   = q/".+?"/;
my $reg_inquotes = q/(?<=").*(?=")/;

for ( my $i = 0; $i < @ARGV; $i++ ) {
    for $file_tp ( $ARGV[$i] ) {
        open( $handler, "<", $file_tp )
            or die "Fatal: Unable to open file '$file_tp'! $!\n";
        @file_lines = <$handler>;
        foreach my $line (@file_lines) {
            if ( $line =~ /(.*#.*)/ ) { next; }    # line is/contains comment
            elsif ( $line =~ /$reg_quoted/ ) {     # we process the quoted thing
                my @old_val = $line =~ m/$reg_inquotes/g;
                my @old_vars = $line =~ /([\$\@].+?\b)/;
                my @new_vars = _convert_utf8(@old_vars);
                my $new_val = _convert_utf8(@old_val);      # convert old to new
                $line =~ s/$reg_inquotes/$new_val/img;    # replace old with new
                print "@old_vars\n";
                foreach my $i (@old_vars) {
                    # print "@old_vars[$i]\n";
                    # $line =~ s/$cur/$i/img; # replace vars with self
                }
                $line =~ s/(\\x5c\\x6e)/\\n/img;  # replace any \n with actual\n
                $found_quote = 1;
            }
        }
        if ($found_quote) {
            open( $handler, ">", $file_tp )
                or die "Fatal: Unable to write to file '$file_tp'! $!\n";
            print $handler @file_lines;
        }
        else {
            print "Didn't find any quotes in $file_tp!\n";
        }
        close $handler;
    }
}

sub _convert_utf8 {
    my $to_encode = decode( "utf8", @_[$_] );
    my (@i_chars) = unpack( "U*", $to_encode );
    my (@encoded) = map { sprintf "\\x%02x", $_ } @i_chars;
    my $encoded = join( "", @encoded );
    my $output = $encoded;
}
