package GildedRose::Item::AgedBrie;

use strict;
use warnings;

use parent 'GildedRose::Item';

sub age {
    my $self = shift;
    $self->quality('+1');
}

1;
