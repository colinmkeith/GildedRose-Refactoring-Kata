package GildedRose::Item;

use strict;
use warnings;

use parent 'Item';
use GildedRose::Constants qw(:all);

sub new {
    my ( $class, %attrs ) = @_;
    if( exists($attrs{quality}) ) {
      # - The Quality of an item is never more than 50
      if( $attrs{quality} > 50 ) {
        $attrs{quality} = 50;
      }

      # - The Quality of an item is never negative
      elsif( $attrs{quality} < 0 ) {
        $attrs{quality} = 0;
      }
    }

    my $self = $class->SUPER::new(%attrs);
    return bless $self, $class;
}

sub is_aged_brie {
  my $self = shift;
  return $self->name eq AGED_BRIE;
}

sub is_backstage_pass {
  my $self = shift;
  return $self->name eq BACKSTAGE_PASS;
}

sub is_hand_of_ragnaros {
  my $self = shift;
  return $self->name eq SULFURAS;
}

sub is_conjured {
  my $self = shift;
  return $self->name =~ m/^Conjured /;
}

sub name {
  my $self = shift;
  return $self->{name};
}

sub quality {
  my $self = shift;
  return $self->{quality};
}

sub sell_in {
  my $self = shift;
  return $self->{sell_in};
}

1;
