#
#===============================================================================
#
#         FILE: chinese.t
#
#  DESCRIPTION: test Chinese word in sql
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME ( wd ), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 11/10/2012 10:13:14 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use lib "../";
use utf8;

binmode STDOUT, ':utf8';

use Test::More tests => 1;                      # last test to print

use SQL::Beautify;

my $sql = new SQL::Beautify;

my $in = 'select a.中文, a.test from t';

$sql->query($in);
my $t = $sql->beautify;

my $out = "select
    a.中文,
    a.test
from
    t
";

ok($out eq $t, "sql with chinese");
