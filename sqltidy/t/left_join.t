#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use lib "../";

use Test::More;

use_ok("SQL::Beautify");


my $sql = new SQL::Beautify;

my $in = "select a.team_id, group_name, profit, city_name, team_price, a.source, pvs, clicks, order_count, order_item_count, order_paid_count, order_paid_item_count from (select team_id, group_name, profit, city_name, team_price, source, sum(pvs) as pvs, sum(clicks) as clicks from v_tuan_detailinfo where thedate = '2011-04-10' group by team_id, group_name, profit, city_name, team_price, source ) a left join (select team_id, source, sum(order_count) as order_count, sum(order_item_count) as order_item_count, sum(order_paid_count) as order_paid_count, sum(order_paid_item_count) as order_paid_item_count from v_tuan_orderinfo where thedate = '2011-04-10' group by team_id, source ) b on ( a.team_id = b.team_id and a.source = b.source ) ";

my $out = "select
    a.team_id,
    group_name,
    profit,
    city_name,
    team_price,
    a.source,
    pvs,
    clicks,
    order_count,
    order_item_count,
    order_paid_count,
    order_paid_item_count
from (
        select
            team_id,
            group_name,
            profit,
            city_name,
            team_price,
            source,
            sum( pvs ) as pvs,
            sum( clicks ) as clicks
        from
            v_tuan_detailinfo
        where
            thedate = '2011-04-10'
        group by
            team_id,
            group_name,
            profit,
            city_name,
            team_price,
            source
    ) a
left join (
        select
            team_id,
            source,
            sum( order_count ) as order_count,
            sum( order_item_count ) as order_item_count,
            sum( order_paid_count ) as order_paid_count,
            sum( order_paid_item_count ) as order_paid_item_count
        from
            v_tuan_orderinfo
        where
            thedate = '2011-04-10'
        group by
            team_id,
            source
    ) b
on
    (
        a.team_id = b.team_id
        and a.source = b.source
    )
";

$sql->query( $in );

ok($out eq $sql->beautify, "left join ok");

done_testing();
