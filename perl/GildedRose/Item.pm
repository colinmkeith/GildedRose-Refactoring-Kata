package GildedRose::Item;

use parent 'Item';
use strict;
use warnings;
use GildedRose::Constants qw(:all);

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
  return $self->name eq HAND_RAGNAROS;
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
