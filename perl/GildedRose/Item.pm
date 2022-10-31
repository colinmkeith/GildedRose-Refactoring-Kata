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
      $value = ($self->{quality} || 0) + $1;
    }
    elsif($value =~ m/^-([0-9]+)$/) {
      $value = ($self->{quality} || 0) - $1;
    }

    # Enforce quality limits
    $value > 50 && ($value = 50);
    $value <  0 && ($value = 0);

    $self->{quality} = $value;
  }

  return $self->{quality};
}

sub sell_in {
  my($self, $value) = @_;
  if(defined($value) ) {

    if($value =~ m/^\+([0-9]+)$/) {
      $value = ($self->{sell_in} || 0) + $1;
    }
    elsif($value =~ m/^-([0-9]+)$/) {
      $value = ($self->{sell_in} || 0) - $1;
    }

    $self->{sell_in} = $value;

  }
  return $self->{sell_in};
}

sub age {
    my $self = shift;
    $self->quality(-1);
    $self->is_conjured && $self->quality(-1);

    $self->sell_in(-1);

    if ( $self->sell_in < 0 ) {
        $self->quality(-1);
    }
}

1;
