package GildedRose;

use strict;
use warnings;
use GildedRose::Constants qw(:all);

my $itemclasses = {
  SULFURAS()  => 'GildedRose::Item::Sulfuras',
  AGED_BRIE() => 'GildedRose::Item::AgedBrie',
  _DEFAULT_   => 'GildedRose::Item'
};

sub new {
    my ( $class, %attrs ) = @_;

    if( exists($attrs{items}) ) {
        for my $item ( @{$attrs{items}} ) {
            $item->{name} || die "Error: Items must have a name\n";

            my $itemclass = $itemclasses->{ $item->{name} }
                         || $itemclasses->{_DEFAULT_};
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
