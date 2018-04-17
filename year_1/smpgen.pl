#!/usr/bin/perl

# !!!!!!!!!!!!!!! WHAT IS SMPGEN? !!!!!!!!!!!!!!!

#   Smpgen generates somewhat secure passwords
#  using 6 different "templates." It also uses a
# simple list "engine" to make template creation
#          a bit easier. Yay buzzwords!

#  This was also the first Perl script I wrote,
# so it isn't very well written and doesn't even
#    use strict mode or check for duplicates.

# !!!!!!!!!!!!!!! WHAT IS SMPGEN? !!!!!!!!!!!!!!!

use Switch;
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);

# =============== INFORMATION ===============

$name    = "smpgen";
$flavor  = "luck";
$version = "0.5";

# =============== FLAGS ===============
$num;
$variation = 1;
$help;

GetOptions(
    'number|n=i'    => \$num,
    'variation|v=i' => \$variation,
    'help|h'        => \$help,
) or die("Error! Please use --help to see usage details.");

if ( !$num ) {
    $help = 1;
}

if ($help) {
    print <<HELP

    $name $version ($flavor)

    Usage:
        --number, -n [number]
            Specifies the number of passwords to generate.
        --variation, -v [number]
            Specifies the password variation:
                1 -> AbC123!@# (default)
                2 -> a1B2c3!@#
                3 -> 123B!a\@R#
                4 -> !@#AbC123
                5 -> !1\@2#3abC
                6 -> 1!Ab\@23#C
    Tips:
        1. You can route $name\'s output to a file using the "->" operator:
            ex. $name -n 500 -v4 -> passwords.txt (Unix/OS X)

HELP
        ;
}

# =============== GENERATION ===============
@u_case = ( A .. Z );
@l_case = ( a .. z );
@nums   = ( 0 .. 9 );
@chars  = qw( ! @ # $ % ^ & * - _ + = ? " ' . , ; ~ );

# =============== "PARSING" ===============
sub generate {
    # check our list and add correct values to "output"
    for ( $x = 0; $x < @_; $x++ ) {
        $output = ""; # reset output
        # each value is checked for its number or (lowercase) letter equivalent
        if ( @_[$x] eq 1 || @_[$x] eq "C" ) {       # uppercase letter
            $output .= @u_case[ rand(@u_case) ];
        }
        elsif ( @_[$x] eq 2 || @_[$x] eq "c" ) {    # lowercase letter
            $output .= @l_case[ rand(@l_case) ];
        }
        elsif ( @_[$x] eq 3 || @_[$x] eq "#" ) {    # number
            $output .= @nums[ rand(@nums) ];
        }
        elsif ( @_[$x] eq 4 || @_[$x] eq "!" ) {    # punctuation character
            $output .= @chars[ rand(@chars) ];
        }
        print $output;
    }
    # new line for separation
    print "\n";
}

# =============== VARIATIONS ===============
for ( $i = 0; $i < $num; $i++ ) {
    switch ($variation) {
        case 1 {

            # format -> AbC123!@#
            @template = qw( 1 2 1 3 3 3 4 4 4 );
            #             ( C c C # # # ! ! ! )
            &generate(@template);
        }
        case 2 {

            # format -> a1B2c3!@#
            @template = qw( 2 3 1 3 2 3 4 4 4 );
            #             ( c # C # c # ! ! ! )
            &generate(@template);
        }
        case 3 {

            # format -> 123B!a@R#
            @template = qw( 3 3 3 1 4 2 4 1 4);
            #             ( # # # C ! c ! C !)
            &generate(@template);
        }
        case 4 {

            # format -> !@#AbC123
            @template = qw( ! ! ! C c C # # # );
            #             ( 4 4 4 1 2 1 3 3 3 )
            &generate(@template);
        }
        case 5 {

            # format -> !1@2#3abC
            @template = qw( ! # ! # ! # c c C );
            #             ( 4 3 4 3 4 3 2 2 1 )
            &generate(@template);
        }
        case 6 {

            # format -> 1!Ab@23#C
            @template = qw( # ! C c ! # # ! C );
            #             ( 3 4 1 2 4 3 3 4 1 )
            &generate(@template);
        }
    }
}

# Copyright © 2018 - Judah Caruso Rodriguez (0px.moe)