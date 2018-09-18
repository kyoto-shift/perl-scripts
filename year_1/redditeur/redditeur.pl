#!/usr/bin/perl

# !!!!!!!!!!!!!!! WHAT IS REDDITEUR? !!!!!!!!!!!!!!!

#    Redditeur takes a subreddit and a folder as
#   arguments. It downloads every gif link it can
#   find, then goes to the next page and repeats.

#     It does this until you stop the script or
#                 run out of pages!

#  Example usage: redditeur.pl -s aww -d cuteimages
#   (this downloads from /r/aww into cuteimages/)

# !!!!!!!!!!!!!!! WHAT IS REDDITEUR? !!!!!!!!!!!!!!!

use utf8;
use strict;
use warnings;
use Getopt::Long;
use WWW::Mechanize ();

# =============== PKG INFO ===============
my $pkg_name    = "Redditeur";
my $pkg_version = "2.5";
my $pkg_flavor  = "guitar strings";

# =============== INIT VARS ===============
my $sub = "aww";
my $homepage;
my $path;
my $help;
my $img;
my $verified = 0;
my $icon     = "*";

my $mech = WWW::Mechanize->new(
    autocheck         => 1,
    protocols_allowed => [ 'http', 'https' ],
    onerror           => undef,
    stact_depth       => 1,
);

# =============== OPTIONS ===============
GetOptions(
    "sub|s=s"           => \$sub,
    'dir|directory|d=s' => \$path,
    'img|i'             => \$img,
    'help|h'            => \$help,
) or die($help);

unless ($path) {
    $path = "./_$sub";    # reassign path variable to create new folder
}

if ($help) {
    die <<HELP

    $pkg_name $pkg_version ($pkg_flavor)

    Downloads every available gif from any subreddit!

    Usage: $0 [-sdh] [-s subreddit] [-d directory]
    
        --sub, -s [subreddit]
            Which subreddit to download from.
        --directory, --dir, -d [directory]
            Where to download to.
        --img, -i
            If $pkg_name should download images (jpeg/png) too.
        --help, -h
            Displays this cool shit.

HELP
        ;
}

if ( -d "$path" ) { }    # check if our path exists, if not make one
else {
    mkdir($path);
    print "Status:\t'$path' doesn't exist! Creating...\n";
}

# =============== MAIN LOGIC ===============
sub _start {
    if ( !$_[0] ) {
        $homepage = "https://old.reddit.com/r/$sub";
        $mech->get($homepage);
    }
    else {
        $homepage = $_[0];
        $mech->get($homepage);
    }

    if ( $mech->title =~ /over 18\?/i ) {
        $icon     = "XXX";
        $verified = 1;
        $mech->click_button( number => 2 );
    }

    print "\n$icon Starting at $homepage $icon\n\n";
    my @links = $mech->find_all_links( class_regex => qr/title/ );

    if ( scalar @links == 0 ) {
        die "Status: No posts found! Restarting $pkg_name should fix this.\n";
    }

    my $imgur_regex = "imgur.*.gifv";

    if ($img) {
        $imgur_regex = "imgur.*.(png|jpeg|jpg)";
        print
            "Warning: Downloading images is very experimental and might not work correctly!\n\n";
    }

    foreach my $link (@links) {
        my $url = $link->url_abs;
        if ( $url =~ qr/gfycat/ ) {
            _download_gfycat($url);
        }
        elsif ( $url =~ qr/$imgur_regex/ ) {
            _download_imgur($url);
        }
    }

    print "Status:\tPage complete! Redirecting...\n";
    undef @links;
    _newpage();
}

sub _newpage {
    $mech->get($homepage);

    die("\n$icon Search complete! (No more posts found) $icon\n\n")
        unless $mech->follow_link(
        url_regex => qr/($sub\/\?count\=[0-9].+?[&]after)/i );

    my $newpage = $mech->uri;
    _start($newpage);
}

sub _download_imgur {
    my $link = $_[0];
    my $file = $link;

    $file =~ s[^.+\/][];
    $file =~ s[\.(gifv|png|jpeg|jpg)][];
    my $download = "https://imgur.com/download/$file";

    my $fname = $mech->get($download)->filename;
    $fname =~ s[\s-\sImgur][];

    if ( -e "$path\/$fname" ) {
        print "Status:\t'$file' exists! Skipping...\n";
        return;
    }
    else {
        print "Downloading: '$file' [Imgur]\n";
        $mech->get( $download, ":content_file" => "$path/$fname" );
        if ( $mech->status != 200 ) {
            print "Status:\t'$file' is unavailable! Skipping...\n";
        }
    }
}

sub _download_gfycat {
    my $link = $_[0];
    $mech->get($link);

    my $to_dl = $link;
    $to_dl =~ s[.*\.com\/(.*\/)?][];

    my $downloaded = 0;
    my @dl_attempts = ( "$to_dl.webm", "$to_dl.gif" );

    foreach my $file (@dl_attempts) {
        my $download = "https://giant.gfycat.com/$file";
        if ( $downloaded == 0 ) {
            if ( -e "$path\/$file" ) {
                print "Status:\t'$file' exists! Skipping...\n";
                $downloaded = 1;
                next;
            }
            else {
                print "Downloading: '$file' [Gfycat] \n";
                $mech->get( $download, ":content_file" => "$path/$file" );
                $downloaded = 1;
                if ( $mech->status != 200 ) {
                    print
                        "Status:\t'$file' cannot be downloaded! Skipping...\n";
                    next;
                }
            }
        }
        else {
            next;
        }
    }
}

_start();
