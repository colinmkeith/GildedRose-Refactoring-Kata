package GildedRose::Item::Sulfuras;

use strict;
use warnings;

use parent 'GildedRose::Item';

sub quality {
  my($self, $value) = @_;
  if( defined($value) ) {
    # Ignore all reset/incr/decr of values
    $self->quality && return;

    # Enforce quality limits
    $value > 50 && ($value = 50);
    $value <  0 && ($value = 0);
  }
  return $self->SUPER::quality($value);
}

sub sell_in {
  my($self, $value) = @_;

  # Is legendary item, so never ages.
  defined($value) && defined($self->sell_in) && return;
  return $self->SUPER::sell_in($value);
}

1;
