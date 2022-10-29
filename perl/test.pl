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
    my $app          = initGR($sell_in_days, $quality);
    $app->update_quality();

    my $item = [ $app->items() ]->[0];
    cmp_ok($item->quality, '>=', 0, "Quality lower bounds: Does not go below 0" );

    $app = initGR($sell_in_days, $quality);
    $app->update_quality();

    my $item2 = [ $app->items() ]->[0];
    cmp_ok($item2->quality, '<', 50, "Quality upper bounds: Does not go above 50" );
};

=pod
  - Once the sell by date has passed, Quality degrades twice as fast
=cut
subtest 'Degradation Tests for normal item' => sub {
    my $sell_in_days = 2;
    my $quality      = 20;
    my $app          = initGR($sell_in_days, $quality);

    my $res_quality;
    my $res_sell_by;
    my $expected_quality;
    my $expected_sell_by;

    $app->update_quality();
    $app->update_quality();
    $res_quality = $app->items(DEX_VEST)->quality;
    $res_sell_by = $app->items(DEX_VEST)->sell_in;
    $expected_quality = $quality - $sell_in_days;
    $expected_sell_by = $sell_in_days - 2;
    is($res_quality, $expected_quality, "quality decreased correctly on sell by date (Quality = $expected_quality)" );
    is($res_sell_by, $expected_sell_by, 'sell_by decreased correctly to 0');

    # I understand "sell by date has passed" to be sell by < 0
    $app->update_quality();
    $res_quality = $app->items(DEX_VEST)->quality;
    $res_sell_by = $app->items(DEX_VEST)->sell_in;
    $expected_quality = $quality - $sell_in_days - 2;
    $expected_sell_by = $sell_in_days - 3;
    is($res_quality, $expected_quality, "quality decreased by double correctly 1 day after sell by date (Quality = $expected_quality)" );
    is($res_sell_by, $expected_sell_by, 'sell_by decreased correctly to < 0');

    $app->update_quality();
    $res_quality = $app->items(DEX_VEST)->quality;
    $expected_quality = $quality - $sell_in_days - 4;
    is($res_quality, $expected_quality, "quality decreased by double correctly 2 days after sell by date (Quality = $expected_quality)" );
};

done_testing();
