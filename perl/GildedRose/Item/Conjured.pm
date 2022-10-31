package GildedRose::Item::Conjured;

use strict;
use warnings;

use parent 'GildedRose::Item';

sub age {
    my $self = shift;
    $self->quality(-1);
    return $self->SUPER::age();
}

1;
