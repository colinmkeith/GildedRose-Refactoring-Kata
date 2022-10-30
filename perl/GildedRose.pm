package GildedRose;

use strict;
use warnings;
use GildedRose::Item;
use GildedRose::Constants qw(:all);

sub new {
    my ( $class, %attrs ) = @_;

    if( exists($attrs{items}) ) {
        for my $item ( @{$attrs{items}} ) {
                $item = GildedRose::Item->new(
                  name    => $item->{name},
                  quality => $item->{quality},
                  sell_in => $item->{sell_in},
                );
        }
    }

    return bless \%attrs, $class;
}

sub items {
  my($self, $by_name) = @_;

  if($by_name) {
    return (grep { $_->{name} eq $by_name } @{ $self->{items} })[0];
  }

  return @{ $self->{items} };
}

sub update_quality {
    my $self = shift;
    for my $item ( $self->items() ) {
        update_item_quality($item);
        update_item_sell_in($item);
    }
}

sub update_item_sell_in {
    my $item = shift;
    $item->sell_in(-1);

    if ( $item->sell_in < 0 ) {
        if ( !$item->is_aged_brie ) {
            if ( !$item->is_backstage_pass )
            {
                $item->quality(-1);
            }
            else {
                $item->quality(0);
            }
        }
        else {
            $item->quality('+1');
        }
    }
}

sub update_item_quality {
    my $item = shift;
    if ( $item->is_aged_brie )
    {
        $item->quality('+1');
    }
    elsif ( $item->is_backstage_pass )
    {
       if ( $item->sell_in < 0 ) {
           $item->quality(0);
       }
       elsif ( $item->sell_in < 6 ) {
           $item->quality('+3');
       }
       elsif ( $item->sell_in < 11 ) {
           $item->quality('+2');
       }
       else {
           $item->quality('+1');
       }
    }
    else {
        $item->quality(-1);
        $item->is_conjured && $item->quality(-1);
    }
}

1;
