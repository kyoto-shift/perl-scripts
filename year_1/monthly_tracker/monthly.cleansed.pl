#!/usr/bin/perl

# !!!!!!!!!!!!!! DISCLAIMER !!!!!!!!!!!!!!

# This version has been "cleaned" from the
# version I actually use. My personal info
# has been removed,  and it's also loosely 
# maintained.

# !!!!!!!!!!!!!! DISCLAIMER !!!!!!!!!!!!!!

use strict;
use warnings;
use Time::Piece;
use Text::ASCIITable;
use Date::Calc qw( Date_to_Days Delta_Days Delta_YMD );

# =============== INIT CHECK AND SET ===============
if ( not $ARGV[0] ) { die "Usage: [all|list|service]\n" }
chomp( my $input = ucfirst( $ARGV[0] ) );

# =============== SERVICES/SUBSCRIPTIONS ===============
my %subs = (
    Adobe => {
        Service => "Creative Cloud 1 Year",
        Start   => "01/01/2001",
        Price   => "55.00",
        Account => "email\@mail.com",
    },
    Splice => {
        Service => "Serum",
        Start   => "01/01/2001",
        Price   => "10.00",
        Account => "email\@mail.com",
    },
    Microsoft => {
        Service => "Office 365 Personal",
        Start   => "01/01/2001",
        Price   => "8.00",
        Account => "email\@mail.com",
    },
    Amazon => {
        Service => "Prime",
        Start   => "01/01/2001",
        Price   => "16.00",
        Account => "email\@mail.com",
    }
);

# =============== INIT VARS ===============
my $dt        = Time::Piece->new();
my $view      = Text::ASCIITable->new( { headingText => $input } );
my $_template = $view->setCols(
    "Start Date", 
    "Service",     
    "Price", 
    "Total Spent", 
    "Total Months",
    "Account",
);

# =============== CHECK FLAGS ===============
if ( $input eq "List" ) {
    my @list;
    $view->setCols("Services", "Account");
    foreach my $key ( keys %subs ) { push @list, $key; }
    foreach my $item ( sort(@list) ) {
        push @$view, ("$item\n", "$subs{$item}{Account}");
    }
}
elsif ( $input eq "All" ) {
    my @list;
    my $sum_of_all = _get_sum();
    foreach my $key ( keys %subs ) { push @list, $key; }
    foreach my $item ( sort(@list) ) { _get_info($item); }
    $view->addRowLine();
    $view->addRow("","Monthly Total: \$$sum_of_all");
}
elsif ( $input eq "" ) {
    die "Error: Nothing supplied! Please try again.\n";
}
elsif ( not exists $subs{$input} ) {
    die "Error: $input doesn't exist!\n";
}
else {
    _get_info($input);
}

print $view;

# =============== MAIN LOGIC ===============

_get_sum() and exit;

sub _get_info {

    # GET DATE INFORMATION
    my $service = $subs{ $_[0] }{Service};
    my @y       = $subs{ $_[0] }{Start} =~ /([0-9]{4})/;    # find year
    my @m       = $subs{ $_[0] }{Start} =~ /([0-9].?+)/;    # find month
    my @d = $subs{ $_[0] }{Start} =~ /((?<=\/)[0-9].+?(?=\/))/;    # find day
    my $diff_delta = Delta_Days( @y, @m, @d, $dt->year, $dt->mon, $dt->mday );
    my $diff_m = sprintf( "%1.f", $diff_delta / 30 );    # rough delta to months

    # GET TOTAL SPENT
    my @price       = $subs{ $_[0] }{Price};
    my $total_spent = "@price" * $diff_m;

    # GET ACCOUNT INFORMATION
    my @account = $subs{ $_[0] }{Account};

    $view->addRow(
        "@m/@d/@y", # Start Date
        "$_[0] ($service)", # Name  
        "\$$subs{ $_[0] }{Price}", # Price
        "\$$total_spent", # Total Spent  
        "$diff_m", # Total Months
        "@account", # Associated Account
    );
}

sub _get_sum {
    my @list_of_prices;
    my $sum = 0;
    foreach my $key ( keys %subs ) { push @list_of_prices, $subs{$key}{Price}; }
    foreach my $price ( sort(@list_of_prices) ) {
        $sum += $price;
    }
    return $sum;
}
