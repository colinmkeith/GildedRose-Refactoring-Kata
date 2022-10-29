package GildedRose;

use strict;
use warnings;
use GildedRose::Constants qw(:all);

sub new {
    my ( $class, %attrs ) = @_;
    return bless \%attrs, $class;
}

sub items {
  my($self, $by_name) = @_;

  if($by_name) {
    return (grep { $_->{name} eq $by_name } @{ $self->{items} })[0];
  }

  return @{ $self->{items} };
}

sub item_degrades_over_time {
    my $item = shift;
    $item->is_hand_of_ragnaros && return;
    $item->quality > 0 && $item->{quality}--;
}

sub update_quality {
    my $self = shift;
    for my $item ( $self->items() ) {
        update_item_quality($item);

        if ( !$item->is_hand_of_ragnaros ) {
            $item->{sell_in}--;
        }

        if ( $item->sell_in < 0 ) {
            if ( !$item->is_aged_brie ) {
                if ( !$item->is_backstage_pass )
                {
                    if ( $item->quality > 0 ) {
                        if ( !$item->is_hand_of_ragnaros ) {
                            $item->{quality}--;
                        }
                    }
                }
                else {
                    $item->{quality} = 0;
                }
            }
            else {
                if ( $item->quality < 50 ) {
                    $item->{quality}++;
                }
            }
        }
    }
    return;
}

sub update_item_quality {
    my $item = shift;
    if ( !$item->is_aged_brie
      && !$item->is_backstage_pass )
    {
       item_degrades_over_time($item);
    }
    else {
        if ( $item->quality < 50 ) {
            $item->{quality}++;

            if ( $item->is_backstage_pass )
            {
                if ( $item->sell_in < 11 ) {
                    if ( $item->quality < 50 ) {
                        $item->{quality}++;
                    }
                }

                if ( $item->sell_in < 6 ) {
                    if ( $item->quality < 50 ) {
                        $item->{quality}++;
                    }
                }
            }
        }
    }
}

1;
