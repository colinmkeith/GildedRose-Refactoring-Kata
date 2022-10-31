package GildedRose;

use strict;
use warnings;
use GildedRose::Item;
use GildedRose::Item::Sulfuras;
use GildedRose::Constants qw(:all);

sub new {
    my ( $class, %attrs ) = @_;

    if( exists($attrs{items}) ) {
        for my $item ( @{$attrs{items}} ) {
            if($item->{name} && $item->{name} eq SULFURAS) {
                $item = GildedRose::Item::Sulfuras->new(
                  name    => $item->{name},
                  quality => $item->{quality},
                  sell_in => $item->{sell_in},
                );
            }
            else {
                $item = GildedRose::Item->new(
                  name    => $item->{name},
                  quality => $item->{quality},
                  sell_in => $item->{sell_in},
                );
            }
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
