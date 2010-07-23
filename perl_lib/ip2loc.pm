package ip2loc;;

use strict;
use warnings;
use Data::Dumper;

use vars qw($VERSION);
$VERSION = '0.01';

our $total;
our @ipbase;

sub new() {
    my $package = shift;
    return bless( {}, $package);
}

sub load {
    my $self = shift;
    my $file = shift;

    open F, "<", $file or die "Can't open file: $file";

    $total = 0;
    while ( <F> ) {
        chomp;
        my ( $low, $hi, $loc ) = split(/\t/);
        $loc =~ s/$//g;
        push @ipbase, [ ( $low, $hi, $loc ) ];
        $total ++;
    }
}

sub parse {
    my $self = shift;
    my $ip_str = shift;

    return '' if not $ip_str;
    my @t = split(/\./, $ip_str);
    return '' if (scalar @t) != 4;

    my $ip_long = $self->ip2long( $ip_str );

    my $s = 0;
    my $e = $total - 1;

    my $now = int( $e / 2 );

    while ( 1 ) {
        my $r = $self->compare($now, $ip_long);

        if ( $r == 0 ) {
            return ${$ipbase[$now]}[2];
        } elsif ( $r == -1 ) {
            $e = $now -1;
            $now  = int(( $e - $s ) / 2) + $s;
        } else {
            $s = $now + 1;
            $now = int(( $e - $s ) / 2) + $s;
        }

        if ( $s > $e ) {
            return "UNKNOW";
        }
    }
}

sub ip2long {
    my $self = shift;
    my $ip_str = shift;

    my $n = 256;
    my @sip = split(/\./,$ip_str);
    my $ip_long = ($sip[0]*($n * $n * $n))+($sip[1]*($n * $n))+($sip[2] * $n) + ($sip[3]);
    return $ip_long;
}

sub compare {
    my $self = shift;
    my $now = shift;
    my $ip_long = shift;

    my $low = ${$ipbase[$now]}[0];
    my $hi = ${$ipbase[$now]}[1];

    if ( $ip_long >= $low and $ip_long <= $hi ) {
        return 0;
    } elsif ( $ip_long > $hi ) {
        return 1;
    } else {
        return -1;
    }
}

1;
