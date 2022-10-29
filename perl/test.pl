#!/usr/bin/env perl

use strict;
use warnings;

use Test::More 0.96;

use_ok 'GildedRose';
use_ok 'GildedRose::Item';
use_ok 'GildedRose::Constants';

# Need to do this to trigger constants import
use GildedRose::Constants qw(:all);

sub initGR {
    my($sell_in_days, $quality) = @_;
    my $items = [
      GildedRose::Item->new( name => DEX_VEST, sell_in => $sell_in_days, quality => $quality ),
      GildedRose::Item->new( name => AGED_BRIE, sell_in => $sell_in_days, quality => $quality ),
      GildedRose::Item->new( name => SULFURAS, sell_in => $sell_in_days, quality => $quality ),
    ];
    return GildedRose->new( items => $items );
}

subtest 'Instantiation Tests' => sub {
    my $sell_in_days = 2;
    my $quality      = 2;
    my $app          = initGR($sell_in_days, $quality);
    my $item         = [ $app->items() ]->[0];

    is($item->name,    DEX_VEST,      'Item name correct');
    is($item->quality, $quality,      'Item quality correct');
    is($item->sell_in, $sell_in_days, 'Item sell_in correct');
};

=pod
 - At the end of each day our system lowers both values for every item
=cut
subtest 'Degradation Tests' => sub {
    my $sell_in_days = 2;
    my $quality      = 2;
    my $app          = initGR($sell_in_days, $quality);
    my $item         = [ $app->items() ]->[0];

    for my $day ( 1..2 ) {
      $app->update_quality();
      my $target_sell_in = $sell_in_days - $day;
      my $target_quality = $quality - $day;

      is($item->sell_in, $target_sell_in, "sell_in decreased over time correctly on day $day" );
      is($item->quality, $target_quality, "quality decreased over time correctly on day $day" );
    }
};

=pod
 - The Quality of an item is never negative
 - The Quality of an item is never more than 50
=cut
subtest 'Boundary Tests' => sub {
    my $sell_in_days = 2;
    my $quality      = 1;
    my $items = [ GildedRose::Item->new( name => DEX_VEST,  sell_in => $sell_in_days, quality => $quality ) ];
    my $app = GildedRose->new( items => $items );
    $app->update_quality();

    my $item = [ $app->items() ]->[0];
    cmp_ok($item->quality, '>=', 0, "Quality lower bounds: Does not go below 0" );

    $items = [ GildedRose::Item->new( name => DEX_VEST,  sell_in => $sell_in_days, quality => 60 ) ];
    $app = GildedRose->new( items => $items );
    $app->update_quality();

    my $item2 = [ $app->items() ]->[0];
    cmp_ok($item2->quality, '<', 50, "Quality upper bounds: Does not go above 50" );
};

done_testing();
