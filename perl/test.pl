#!/usr/bin/env perl

use strict;
use warnings;

use Test::More 0.96;

use_ok 'GildedRose';
use_ok 'GildedRose::Item';

subtest 'foo' => sub {
    my $items = [ GildedRose::Item->new( name => 'foo', sell_in => 0, quality => 0 ) ];
    my $app = GildedRose->new( items => $items );
    $app->update_quality();
    is( [ $app->items() ]->[0]->{name}, 'foo' );
};

subtest 'Basic Tests' => sub {
    my $sell_in_days = 2;
    my $quality      = 2;
    my $items = [ GildedRose::Item->new( name => 'foo', sell_in => $sell_in_days, quality => $quality ) ];
    my $app = GildedRose->new( items => $items );
    my $check_item = [ $app->items() ]->[0];
    my $name = $check_item->{name};
    for my $day ( 0..2 ) {
      diag("Day: $day");
      is($check_item->sell_in, $sell_in_days - $day, "Item ${name} sell_in decreased by 1 for $day day(s)" );
      is($check_item->quality, $quality - $day,      "Item ${name} quality decreased as 1 for $day day(s)" );
      $app->update_quality();
    }
};

done_testing();
