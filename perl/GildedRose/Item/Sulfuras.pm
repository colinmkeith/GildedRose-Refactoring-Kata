package GildedRose::Item::Sulfuras;

use strict;
use warnings;

use parent 'GildedRose::Item';

sub quality {
  my($self, $value) = @_;
  if($value =~ m/^-([0-9]+)$/) {
      $self->is_sulfuras && return;
  }
  return $self->SUPER::quality($value);
}

sub sell_in {
  my($self, $value) = @_;
  if(defined($value) ) {
    $self->is_sulfuras && defined($self->sell_in) && return;
  }

  return $self->SUPER::sell_in($value);
}

1;
