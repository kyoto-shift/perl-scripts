#!/usr/bin/perl

# !!!!!!!!!!!!!!! WHAT IS REDDITEUR? !!!!!!!!!!!!!!!

#    Redditeur takes a subreddit and a folder as
#  arguments. It downloads every Gfycat link it can
#   find, then goes to the next page and repeats.
#      It does this until you stop the script.

#  Example usage: redditeur.pl -s aww -d cuteimages
#   (this downloads from /r/aww into cuteimages/)

# !!!!!!!!!!!!!!! WHAT IS REDDITEUR? !!!!!!!!!!!!!!!

# =============== TODO ===============
# 1. Add support for imgur and i.redd.it
# =============== TODO ===============

use strict;
use warnings;
use Getopt::Long;
use WWW::Mechanize ();

# =============== PKG INFO ===============
my $pkg_name = "Redditeur";
my $pkg_version = "1.8";
my $pkg_flavor = "(folder full of \"memes\")";

# =============== INIT VARS ===============
my $sub = "aww";
my $homepage;
my $path;
my $nsfw;
my $help;
my $verified = 0;
my $mech = WWW::Mechanize->new(
    autocheck         => 1,
    protocols_allowed => [ 'http', 'https' ],
    onerror => undef,
    stact_depth => 1,
);

# =============== OPTIONS ===============
GetOptions (
        "sub|s=s" => \$sub,
        'dir|directory|d=s' => \$path,
        'nsfw|n' => \$nsfw,
        'help|h' => \$help,
    ) or die ($help);

unless ( $path ) {
    $path = "./_$sub"; # reassign path variable to create new folder
}

if ( $help ) {
die <<HELP

    $pkg_name $pkg_version $pkg_flavor

    Downloads every available Gfycat link from any subreddit!

    Usage: $0 [-sdnh] [-s subreddit] [-n if_nsfw] [-d directory]
    
        --sub, -s [subreddit]
            Which subreddit to download from.
        --directory, --dir, -d [directory]
            Where to download to.
        --nsfw, -n
            If the subreddit is Not Safe For Work.
        --help, -h
            Displays this cool shit.

HELP
;
}

if ( -d "$path" ) { } # check if our path exists, if not make one
else {
    mkdir($path);
    print "Status: '$path' doesn't exist! Creating...\n";
}

# =============== MAIN LOGIC ===============
sub _start {
    # if we don't have a url argument, use first page of sub (first invocation)
    if ( !$_[0] ) {
        $homepage = "https://www.reddit.com/r/$sub";
        $mech->get($homepage);
    }
    # if we do, use that url instead (second invocation)
    else {
        $homepage = $_[0];
        $mech->get($homepage);
    }

    if ( $nsfw && $verified == 0) {
        print "Status:  /r/$sub specified as NSFW! Checking...\n";
        if ($mech->title !~ /over 18\?/i) {
            die("Error:  Are you sure /r/$sub is NSFW?\n");
        } else {   
            $verified = 1;
            $mech->click_button(number => 2);
        }
    } else {
        if ( $mech->title =~ /over 18\?/i ) {
            die("Error:  /r/$sub is NSFW. Please specify that with '-n'!\n");
        }
    }

    print "*\nStarting at $homepage\n*\n";
    my @links = $mech->find_all_links( class_regex => qr/title/ );

    foreach my $link (@links) {
        my $url = $link->url_abs;
        if ( $url =~ qr/gfycat/ ) {
            _download_gfycat($url);
        }
    }
    print "Status: Page complete! Redirecting...\n";
    _newpage();
}

sub _newpage {
    $mech->get($homepage);
    $mech->follow_link( url_regex => qr/($sub\/\?count\=[0-9].+?[&]after)/i );
    my $newpage = $mech->uri;
    _start($newpage);
}

sub _download_gfycat {
    my $link = $_[0];
    $mech->get($link);

    my @found_links
        = $mech->find_link( url_regex => qr/(giant.*|max[-]14mb[.]gif)$/i );

    foreach my $found (@found_links) {
        my $download = $found->url_abs;
        my $file     = $download;
        $file =~ s[^.+\/][];

        if ( -e "$path/$file" ) {
            print "Status: '$file' exists! Skipping...\n";
            next;
        }
        else {
            print "Downloading:  $file!\n";
            $mech->get( $download, ":content_file" => "$path/$file" );
            if ($mech->status == 403) {
                print "Status: $download is unavailable! Skipping...\n";
                next;
            }
        }
    }
}

_start();
