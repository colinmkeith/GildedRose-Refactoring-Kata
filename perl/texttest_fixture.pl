#!/usr/bin/env perl

use strict;
use warnings;

use GildedRose;
use GildedRose::Item;
use GildedRose::Constants qw(:all);

print 'OMGHAI!', "\n";
my $items = [
    GildedRose::Item->new(
        name    => +DEX_VEST,
        sell_in => 10,
        quality => 20
    ),
    GildedRose::Item->new(
        name    => AGED_BRIE,
        sell_in => 2,
        quality => 0
    ),
    GildedRose::Item->new(
        name    => MONGOOSE_ELIXIR,
        sell_in => 5,
        quality => 7
    ),
    GildedRose::Item->new(
        name    => SULFURAS,
        sell_in => 0,
        quality => 80
    ),
    GildedRose::Item->new(
        name    => SULFURAS,
        sell_in => -1,
        quality => 80
    ),
    GildedRose::Item->new(
        name    => BACKSTAGE_PASS,
        sell_in => 15,
        quality => 20
    ),
    GildedRose::Item->new(
        name    => BACKSTAGE_PASS,
        sell_in => 10,
        quality => 49
    ),
    GildedRose::Item->new(
        name    => BACKSTAGE_PASS,
        sell_in => 5,
        quality => 49
    ),
    GildedRose::Item->new(    # This Conjured item does not work properly yet
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
    for my $item ( $gilded_rose->items ) {
        print $item->to_string(), "\n";
    }
    print "\n";
    $gilded_rose->update_quality();
}
