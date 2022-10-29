#!/usr/bin/env perl

use strict;
use warnings;

use Test::More 0.96;

use_ok 'GildedRose';
use_ok 'GildedRose::Item';
use_ok 'GildedRose::Constants';

subtest 'Instantiation Tests' => sub {
    my $sell_in_days = 2;
    my $quality      = 2;
    my $name         = 'Foo Fighting Sword';
    my $items = [ GildedRose::Item->new( name => $name, sell_in => $sell_in_days, quality => $quality ) ];
    my $app = GildedRose->new( items => $items );
    my $check_item = [ $app->items() ]->[0];
    is($check_item->name,    $name,         'Item name correct');
    is($check_item->quality, $quality,      'Item quality correct');
    is($check_item->sell_in, $sell_in_days, 'Item sell_in correct');
};

=pod
 - At the end of each day our system lowers both values for every item
=end
subtest 'Degradation Tests' => sub {
    my $sell_in_days = 2;
    my $quality      = 2;
    my $items = [ GildedRose::Item->new( name => 'foo', sell_in => $sell_in_days, quality => $quality ) ];
    my $app = GildedRose->new( items => $items );
    my $check_item = [ $app->items() ]->[0];
    my $name = $check_item->{name};
    for my $day ( 1..2 ) {
      $app->update_quality();
      diag("Day: $day");
      my $target_sell_in = $sell_in_days - $day;
      my $target_quality = $quality - $day;
      is($check_item->sell_in, $target_sell_in, 'sell_in decreased over time correctly' );
      is($check_item->quality, $target_quality, 'quality decreased over time correctly' );
    }
};

=pod
 - The Quality of an item is never negative
 - The Quality of an item is never more than 50
=end
subtest 'Boundary Tests' => sub {
    my $sell_in_days = 2;
    my $quality      = 1;
    my $items = [ GildedRose::Item->new( name => 'foo',  sell_in => $sell_in_days, quality => $quality ) ];
    my $app = GildedRose->new( items => $items );
    my $check_item = [ $app->items() ]->[0];
    my $name = $check_item->{name};
    $app->update_quality();
    $app->update_quality();

    cmp_ok($check_item->quality, '>=', 0, "Quality lower bounds: Does not go below 0" );
    $items = [ GildedRose::Item->new( name => 'foo',  sell_in => $sell_in_days, quality => 60 ) ];
    $app = GildedRose->new( items => $items );
    $app->update_quality();
    my $check_item2 = [ $app->items() ]->[0];

    cmp_ok($check_item2->quality, '<', 50, "Quality upper bounds: Does not go above 50" );
};

done_testing();
