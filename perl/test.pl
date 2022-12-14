#!/usr/bin/env perl

use strict;
use warnings;

use Test::More 0.96;

use Data::Dumper;

use_ok 'GildedRose';
use_ok 'GildedRose::Constants';

# Need to do this to trigger constants import
use GildedRose::Constants qw(:all);

sub initGR {
    my($sell_in_days, $quality) = @_;
    my $items = [
      map {
        {
          name    => $_,
          sell_in => $sell_in_days,
          quality => $quality
        }
      } ( DEX_VEST, AGED_BRIE, SULFURAS, BACKSTAGE_PASS, MANA_CAKE )
    ];
    return GildedRose->new( items => $items );
}

subtest 'Instantiation Tests' => sub {
    my $sell_in_days = 2;
    my $quality      = 2;
    my $app          = initGR($sell_in_days, $quality);
    my $item         = $app->items(DEX_VEST);

    is($item->name,    DEX_VEST,      'Item name correct');
    is($item->quality, $quality,      'Item quality correct');
    is($item->sell_in, $sell_in_days, 'Item sell_in correct');
    $Data::Dumper::Indent = 0;
    $Data::Dumper::Sortkeys = 1;
    for my $item ($app->items) {
      diag( Data::Dumper->Dump([ $item ]) );
    }
};

=pod
 - At the end of each day our system lowers both values for every item
=cut
subtest 'Degradation Tests' => sub {
    my $sell_in_days = 2;
    my $quality      = 2;
    my $app          = initGR($sell_in_days, $quality);
    my $item         = $app->items(DEX_VEST);

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

    my $item_lower = GildedRose->new(items => [
      {
        name    => DEX_VEST,
        sell_in => 10,
        quality => -1
      }
    ]);

    my $item_upper = GildedRose->new(items => [
      {
        name    => DEX_VEST,
        sell_in => 10,
        quality => 100
      }
    ]);

    is($item_lower->items(DEX_VEST)->quality,  0, 'quality on set has correct lower limit of 0'  );
    is($item_upper->items(DEX_VEST)->quality, 50, 'quality on set has correct upper limit of 50' );
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

=pod
  - "Sulfuras", being a legendary item, never has to be sold or decreases in Quality
=cut
subtest 'Degradation Tests for special cases: Sulfuras' => sub {
    my $sell_in_days = 2;
    my $quality      = 20;
    my $app          = initGR($sell_in_days, $quality);

    my $res_quality;

    $app->update_quality();
    $res_quality = $app->items(SULFURAS)->quality;
    is($res_quality, $quality, 'quality for '.  SULFURAS .' did not change after 1 day');

    # I understand "sell by date has passed" to be sell by < 0
    $app->update_quality();
    $app->update_quality();
    $app->update_quality();
    $app->update_quality();
    $res_quality = $app->items(SULFURAS)->quality;
    is($res_quality, $quality, 'quality for '.  SULFURAS .' did not change after sell by date');
};

=pod
  - "Aged Brie" actually increases in Quality the older it gets
=cut
subtest 'Degradation Tests for special cases: Aged Brie' => sub {
    my $sell_in_days = 2;
    my $quality      = 20;
    my $app          = initGR($sell_in_days, $quality);

    my $res_quality;
    my $expected_quality;

    $app->update_quality();
    $res_quality = $app->items(AGED_BRIE)->quality;
    $expected_quality = $quality + 1;
    is($res_quality, $expected_quality, 'quality for '.  AGED_BRIE .' increased after 1 day');

    # Age 4 days (sell in -3 days)
    for (0..3) {
      $app->update_quality();
    }
    $res_quality = $app->items(AGED_BRIE)->quality;
    $expected_quality = $quality + 5;
    is($res_quality, $expected_quality, 'quality for '.  AGED_BRIE .' continued to increase after sell by date');

    my $res_sell_in = $app->items(AGED_BRIE)->sell_in;
    my $expected_sell_in = $sell_in_days - 5;
    is($res_sell_in, $expected_sell_in, 'sell_in for '.  AGED_BRIE .' continued to increase after sell by date');
};

=pod
  - "Backstage passes", like aged brie, increases in Quality as its SellIn value approaches;
  Quality increases by 2 when there are 10 days or less and by 3 when there are 5 days or less but
  Quality drops to 0 after the concert
=cut
subtest 'Degradation Tests for special cases: Backstage Passes' => sub {
    my $sell_in_days = 20;
    my $quality      = 10;
    my $app          = initGR($sell_in_days, $quality);

    my($res_quality, $expected_quality, $sell_in);

    $app->update_quality(); # 19 days
    $res_quality = $app->items(BACKSTAGE_PASS)->quality;
    $expected_quality = $quality + 1;
    is($res_quality, $expected_quality, 'quality for '.  BACKSTAGE_PASS .' increased by 1 after 1 day with 19 days left');

    # Skip forward 9 days
    for (0..8) {
      $app->update_quality();
    }
    $res_quality = $app->items(BACKSTAGE_PASS)->quality;
    $expected_quality = $quality + 10;
    is($res_quality, $expected_quality, 'quality for '.  BACKSTAGE_PASS .' increased by 10 after 10 days with 10 days left');

    $app->update_quality(); # 10 days
    $res_quality = $app->items(BACKSTAGE_PASS)->quality;
    $sell_in     = $app->items(BACKSTAGE_PASS)->sell_in;
    $expected_quality = $quality + 10 + 2;
    is($res_quality, $expected_quality, 'quality for '.  BACKSTAGE_PASS ." increased by 10 + 2 = +12 = $expected_quality with $sell_in days left");

    # Skip forward 5 days
    for (0..4) {
      $app->update_quality();
    }

    $res_quality = $app->items(BACKSTAGE_PASS)->quality;
    $sell_in     = $app->items(BACKSTAGE_PASS)->sell_in;
    $expected_quality = $quality + 10 + (2 * 5) + 3;
    is($res_quality, $expected_quality, 'quality for '.  BACKSTAGE_PASS ." increased by 10 + (2 * 5) + 3 = +23 = $expected_quality with $sell_in days left");

    # Skip forward 3 days
    for (0..2) {
      $app->update_quality();
    }

    $res_quality = $app->items(BACKSTAGE_PASS)->quality;
    $sell_in     = $app->items(BACKSTAGE_PASS)->sell_in;
    $expected_quality = $quality + 10 + (2 * 5) + (3 * 4);
    is($res_quality, $expected_quality, 'quality for '.  BACKSTAGE_PASS ." increased by 10 + (2 * 5) + (3 * 4)= +32 = $expected_quality with $sell_in days left");

    diag('I understand sell_in == 0 to mean the concert is today, so still has value.');
    $app->update_quality();
    $res_quality = $app->items(BACKSTAGE_PASS)->quality;
    $sell_in     = $app->items(BACKSTAGE_PASS)->sell_in;
    $expected_quality = $quality + 10 + (2 * 5) + (3 * 5);
    is($res_quality, $expected_quality, 'quality for '.  BACKSTAGE_PASS ." increased by 10 + (2 * 5) + (3 * 5)= +32 = $expected_quality with $sell_in days left");

    diag('Day after the concert');
    $app->update_quality();
    $res_quality = $app->items(BACKSTAGE_PASS)->quality;
    $sell_in     = $app->items(BACKSTAGE_PASS)->sell_in;
    $expected_quality = 0;
    is($res_quality, $expected_quality, 'quality for '.  BACKSTAGE_PASS .' is 0 as concert was last night');
};

=pod
"Conjured" items degrade in Quality twice as fast as normal items
=cut
subtest 'Degradation Tests for special cases: Conjured' => sub {
    my $sell_in_days = 20;
    my $quality      = 10;
    my $app          = initGR($sell_in_days, $quality);

    my($res_quality, $expected_quality, $sell_in);

    $app->update_quality();
    $res_quality = $app->items(MANA_CAKE)->quality;
    $expected_quality = $quality-2;
    is($res_quality, $expected_quality, 'quality for '.  MANA_CAKE .' decreased by 2 after 1 day');

    $app->update_quality();
    $res_quality = $app->items(MANA_CAKE)->quality;
    $expected_quality = $quality-4;
    is($res_quality, $expected_quality, 'quality for '.  MANA_CAKE .' decreased by 4 after 2 days');
};

subtest 'Code Change Check: quality / sell_in' => sub {
    my $sell_in_days = 10;
    my $quality      = 10;
    my $app          = initGR($sell_in_days, $quality);
    my $item         = $app->items(DEX_VEST);

    $item->quality(20);
    is($item->quality, 20, 'quality for '.  DEX_VEST .' set to 20');

    $item->quality('+20');
    is($item->quality, 40, 'quality for '.  DEX_VEST .' increased by 20 to 40');

    $item->quality(-20);
    is($item->quality, 20, 'quality for '.  DEX_VEST .' decreased by 20 back to 20');

    $item->quality(0);
    is($item->quality, 0, 'quality for '.  DEX_VEST .' set to 0');

    $item->sell_in(20);
    is($item->sell_in, 20, 'sell_in for '.  DEX_VEST .' set to 20');

    $item->sell_in('+20');
    is($item->sell_in, 40, 'sell_in for '.  DEX_VEST .' increased by 20 to 40');

    $item->sell_in(-20);
    is($item->sell_in, 20, 'sell_in for '.  DEX_VEST .' decreased by 20 back to 20');

    $item->sell_in(0);
    is($item->sell_in, 0, 'sell_in for '.  DEX_VEST .' set to 0');
};

done_testing();
