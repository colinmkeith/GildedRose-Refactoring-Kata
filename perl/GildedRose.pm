package GildedRose;

use strict;
use warnings;
use GildedRose::Constants qw(:all);

my $itemclasses = {
  SULFURAS()       => 'GildedRose::Item::Sulfuras',
  AGED_BRIE()      => 'GildedRose::Item::AgedBrie',
  BACKSTAGE_PASS() => 'GildedRose::Item::BackstagePass',
  IS_CONJURED()    => 'GildedRose::Item::Conjured',
  DEFAULT()        => 'GildedRose::Item'
};

sub new {
    my ( $class, %attrs ) = @_;

    if( exists($attrs{items}) ) {
        for my $item ( @{$attrs{items}} ) {
            $item->{name} || die "Error: Items must have a name\n";

            my $itemclass = $itemclasses->{ $item->{name} }
                         || $itemclasses->{ substr($item->{name}, 0, length(+IS_CONJURED))  }
                         || $itemclasses->{+DEFAULT};
            eval "use $itemclass;";
            $item = $itemclass->new(
              name    => $item->{name},
              quality => $item->{quality},
              sell_in => $item->{sell_in},
            );
        }
    }

    return bless \%attrs, $class;
}

sub items {
  my($self, $by_name) = @_;

  if($by_name) {
    return (grep { $_->{name} eq $by_name } @{ $self->{items} })[0];
  }

  return @{ $self->{items} };
}

sub update_quality {
    my $self = shift;
    for my $item ( $self->items() ) {
        $item->age;
    }
}


1;
