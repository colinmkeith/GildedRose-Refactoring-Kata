package GildedRose::Constants;

use Exporter qw( import );

our @EXPORT = ();

our %EXPORT_TAGS = (
    'all' => [ qw( DEX_VEST AGED_BRIE MONGOOSE_ELIXIR
                   HAND_RAGNAROS BACKSTAGE_PASS MANA_CAKE) ],
);

our @EXPORT_OK = (
    @{ $EXPORT_TAGS{all} },
);

use constant {
  DEX_VEST        => '+5 Dexterity Vest',
  AGED_BRIE       => 'Aged Brie',
  MONGOOSE_ELIXIR => 'Elixir of the Mongoose',
  HAND_RAGNAROS   => 'Sulfuras, Hand of Ragnaros',
  BACKSTAGE_PASS  => 'Backstage passes to a TAFKAL80ETC concert',
  MANA_CAKE       => 'Conjured Mana Cake',
};

1;
