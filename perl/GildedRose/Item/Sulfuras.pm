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

1;
