#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

BEGIN {
    push @INC, "/home/wd/work/sqltidy";
}

use SQL::Beautify;

my $sql = new SQL::Beautify;

my @a = <STDIN>;

$sql->query(join("", @a));
my $nice_sql = $sql->beautify;
print $nice_sql;
