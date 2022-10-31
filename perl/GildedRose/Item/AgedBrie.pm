package GildedRose::Item::AgedBrie;

use strict;
use warnings;

use parent 'GildedRose::Item';

sub age {
    my $self = shift;
    $self->quality('+1');
    $self->sell_in(-1);
}

1;
