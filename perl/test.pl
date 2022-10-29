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

done_testing();
