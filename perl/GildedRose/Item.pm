package GildedRose::Item;

use strict;
use warnings;

use parent 'Item';
use GildedRose::Constants qw(:all);

sub new {
    my ( $class, %attrs ) = @_;
    my $quality = delete($attrs{quality});
    my $sell_in = delete($attrs{sell_in});

    my $self = $class->SUPER::new(%attrs);
    my $this = bless $self, $class;
    defined($quality) && $this->quality($quality);
    defined($sell_in) && $this->sell_in($sell_in);
    return $this;
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
  my($self, $value) = @_;
  if(defined($value)) {
    if($value =~ m/^\+([0-9]+)$/) {
      $value = $self->{quality} + $1;
    }
    elsif($value =~ m/^-([0-9]+)$/) {
      $value = $self->{quality} - $1;
    }

    $self->{quality} = $value;
  }

  # Enforce quality limits
  $self->{quality} > 50 && ($self->{quality} = 50);
  $self->{quality} <  0 && ($self->{quality} = 0);

  return $self->{quality};
}

sub sell_in {
  my($self, $value) = @_;
  if(defined($value) ) {
    if($value =~ m/^\+([0-9]+)$/) {
      $value = $self->{sell_in} + $1;
    }
    elsif($value =~ m/^-([0-9]+)$/) {
      $value = $self->{sell_in} - $1;
    }

    $self->{sell_in} = $value;
  }
  return $self->{sell_in};
}



1;
