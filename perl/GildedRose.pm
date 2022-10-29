package GildedRose;

use strict;
use warnings;
use GildedRose::Constants qw(:all);

sub new {
    my ( $class, %attrs ) = @_;
    return bless \%attrs, $class;
}

sub items {
  my $self = shift;
  return @{ $self->{items} };
}

sub is_aged_brie {
  my $item = shift;
  return $item->{name} eq 'Aged Brie';
}

sub is_backstage_pass {
  my $item = shift;
  return $item->{name} eq 'Backstage passes to a TAFKAL80ETC concert';
}

sub is_hand_of_ragnaros {
  my $item = shift;
  return $item->{name} eq 'Sulfuras, Hand of Ragnaros';
}

sub item_degrades_over_time {
    my $item = shift;
    is_hand_of_ragnaros($item) && return;
    $item->{quality} > 0 && $item->{quality}--;
}

sub update_quality {
    my $self = shift;
    for my $item ( $self->items() ) {
        update_item_quality($item);

        if ( !is_hand_of_ragnaros($item) ) {
            $item->{sell_in}--;
        }

        if ( $item->{sell_in} < 0 ) {
            if ( !is_aged_brie($item) ) {
                if ( !is_backstage_pass($item) )
                {
                    if ( $item->{quality} > 0 ) {
                        if ( !is_hand_of_ragnaros($item) ) {
                            $item->{quality}--;
                        }
                    }
                }
                else {
                    $item->{quality}--;
                }
            }
            else {
                if ( $item->{quality} < 50 ) {
                    $item->{quality}++;
                }
            }
        }
    }
    return;
}

sub update_item_quality {
    my $item = shift;
    if ( !is_aged_brie($item)
      && !is_backstage_pass($item) )
    {
       item_degrades_over_time($item);
    }
    else {
        if ( $item->{quality} < 50 ) {
            $item->{quality}++;

            if ( is_backstage_pass($item) )
            {
                if ( $item->{sell_in} < 11 ) {
                    if ( $item->{quality} < 50 ) {
                        $item->{quality}++;
                    }
                }

                if ( $item->{sell_in} < 6 ) {
                    if ( $item->{quality} < 50 ) {
                        $item->{quality}++;
                    }
                }
            }
        }
    }
}

1;
