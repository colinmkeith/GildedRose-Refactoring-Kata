#!/usr/bin/env perl

use strict;
use warnings;

use GildedRose;
use Item;
use GildedRose::Constants qw(:all);

print 'OMGHAI!', "\n";
my $items = [
    Item->new(
        name    => +DEX_VEST,
        sell_in => 10,
        quality => 20
    ),
    Item->new(
        name    => AGED_BRIE,
        sell_in => 2,
        quality => 0
    ),
    Item->new(
        name    => MONGOOSE_ELIXIR,
        sell_in => 5,
        quality => 7
    ),
    Item->new(
        name    => HAND_RAGNAROS,
        sell_in => 0,
        quality => 80
    ),
    Item->new(
        name    => HAND_RAGNAROS,
        sell_in => -1,
        quality => 80
    ),
    Item->new(
        name    => BACKSTAGE_PASS,
        sell_in => 15,
        quality => 20
    ),
    Item->new(
        name    => BACKSTAGE_PASS,
        sell_in => 10,
        quality => 49
    ),
    Item->new(
        name    => BACKSTAGE_PASS,
        sell_in => 5,
        quality => 49
    ),
    Item->new(    # This Conjured item does not work properly yet
        name    => MANA_CAKE,
        sell_in => 3,
        quality => 6
    ),
];

my $days = 2;
if ( $#ARGV >= 0 ) {
    $days = $ARGV[0];
}

my $gilded_rose = GildedRose->new( items => $items );
for my $day ( 0 .. $days ) {
    print "-------- day $day --------", "\n";
    print 'name, sellIn, quality',      "\n";
    for my $item ( @{$items} ) {
        print $item->to_string(), "\n";
    }
    print "\n";
    $gilded_rose->update_quality();
}
