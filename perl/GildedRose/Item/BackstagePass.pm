package GildedRose::Item::BackstagePass;

use strict;
use warnings;

use parent 'GildedRose::Item';

sub age {
    my $self = shift;
    my $sell_in = $self->sell_in;

    # Quality drops to 0 after the concert
    if ( $sell_in < 0 ) {
        $self->quality(0);
    }
    # and by 3 when there are 5 days or less
    elsif ( $sell_in < 6 ) {
        $self->quality('+3');
    }
    # Quality increases by 2 when there are 10 days or less
    elsif ( $sell_in < 11 ) {
        $self->quality('+2');
    }
    # - "Backstage passes" [...] increases in Quality as its SellIn value approaches
    else {
        $self->quality('+1');
    }
    $self->sell_in(-1);
}

sub sell_in {
  my($self, $value) = @_;
  my $ret = $self->SUPER::sell_in($value);
  $self->SUPER::sell_in < 0 && $self->quality(0);
  return $ret;
}


1;
