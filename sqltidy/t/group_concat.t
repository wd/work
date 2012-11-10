#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use lib "../";

use Test::More;

use_ok("SQL::Beautify");


my $sql = new SQL::Beautify;

my $in = "INSERT INTO logstat.hotelinfo (HotelSEQ,hotelName,hotelAddress,dangci,hotelBrand,HotelArea,HotelAround,hotelStars,hotelType,ppc_id,ppc_name,tradingArea) SELECT ghotel. hotelseq,hnames,hadds,hdcs,hbrands,hareas,harounds,hstars,htypes,ppcHotelId,NAME,htrareas FROM ( SELECT   hotelseq,GROUP_CONCAT(hname SEPARATOR '') hnames,             GROUP_CONCAT(hadd SEPARATOR '') hadds,   GROUP_CONCAT(hdc SEPARATOR '') hdcs ,GROUP_CONCAT(harea SEPARATOR '') hareas,GROUP_CONCAT(haround SEPARATOR '') harounds,      GROUP_CONCAT(hbrand SEPARATOR '') hbrands,GROUP_CONCAT(hstar SEPARATOR '') hstars,GROUP_CONCAT(htype SEPARATOR '') htypes ,GROUP_CONCAT(htrarea SEPARATOR '') htrareas  FROM ( SELECT   hotelseq,   IF(a.name='hotelName',IF(a.valueChecked IS NULL || a.valueChecked='', a.value, a.valueChecked),'') hname,   IF(a.name='hotelAddress',IF(a.  valueChecked IS NULL || a.valueChecked='', a.value, a.valueChecked),'') hadd,   IF(a.name='dangci',IF(a.valueChecked IS NULL || a.valueChecked='', a.value, a.          valueChecked),'') hdc,   IF(a.name='HotelArea',IF(a.valueChecked IS NULL || a.valueChecked='', a.value, a.valueChecked),'') harea,   IF(a.name='HotelAround',IF(a.      valueChecked IS NULL || a.valueChecked='', a.value, a.valueChecked),'') haround,   IF(a.name='hotelBrand',IF(a.valueChecked IS NULL || a.valueChecked='', a.value, a.   valueChecked),'') hbrand,   IF(a.name='hotelStars',IF(a.valueChecked IS NULL || a.valueChecked='', a.value, a.valueChecked),'') hstar,   IF(a.name='hotelType',IF(a.    valueChecked IS NULL || a.valueChecked='', a.value, a.valueChecked),'') htype , IF(a.name='tradingArea',IF(a.valueChecked IS NULL || a.valueChecked='', a.value, a.     valueChecked),'') htrarea  FROM hotelInfo a ) thotel GROUP BY hotelseq ) ghotel LEFT JOIN  (SELECT a.ppcHotelId,a.hotelSeq,b.username,c.name FROM (SELECT               SUBSTRING(site_param,4) ppcHotelId,hotel_seq hotelSeq FROM hotel_tree WHERE wrapper_id='wippchotel0')a, (SELECT username,ppc_id FROM ppc_user WHERE endDate>='2012-11-02' )b,ppc_userinfo  c WHERE a.ppcHotelID=b.ppc_id AND b.username=c.username group by a.hotelSeq) photel ON photel.hotelSeq= ghotel.hotelseq WHERE hnames!=''";

my $out = "INSERT INTO logstat.hotelinfo( HotelSEQ, hotelName, hotelAddress, dangci, hotelBrand, HotelArea, HotelAround, hotelStars, hotelType, ppc_id, ppc_name, tradingArea )
SELECT
    ghotel. hotelseq,
    hnames,
    hadds,
    hdcs,
    hbrands,
    hareas,
    harounds,
    hstars,
    htypes,
    ppcHotelId,
    NAME,
    htrareas
FROM (
        SELECT
            hotelseq,
            GROUP_CONCAT( hname SEPARATOR '' ) hnames,
            GROUP_CONCAT( hadd SEPARATOR '' ) hadds,
            GROUP_CONCAT( hdc SEPARATOR '' ) hdcs,
            GROUP_CONCAT( harea SEPARATOR '' ) hareas,
            GROUP_CONCAT( haround SEPARATOR '' ) harounds,
            GROUP_CONCAT( hbrand SEPARATOR '' ) hbrands,
            GROUP_CONCAT( hstar SEPARATOR '' ) hstars,
            GROUP_CONCAT( htype SEPARATOR '' ) htypes,
            GROUP_CONCAT( htrarea SEPARATOR '' ) htrareas
        FROM (
                SELECT
                    hotelseq,
                    IF( a.name = 'hotelName', IF( a.valueChecked IS NULL || a.valueChecked = '', a.value, a.valueChecked ), '' ) hname,
                    IF( a.name = 'hotelAddress', IF( a. valueChecked IS NULL || a.valueChecked = '', a.value, a.valueChecked ), '' ) hadd,
                    IF( a.name = 'dangci', IF( a.valueChecked IS NULL || a.valueChecked = '', a.value, a. valueChecked ), '' ) hdc,
                    IF( a.name = 'HotelArea', IF( a.valueChecked IS NULL || a.valueChecked = '', a.value, a.valueChecked ), '' ) harea,
                    IF( a.name = 'HotelAround', IF( a. valueChecked IS NULL || a.valueChecked = '', a.value, a.valueChecked ), '' ) haround,
                    IF( a.name = 'hotelBrand', IF( a.valueChecked IS NULL || a.valueChecked = '', a.value, a. valueChecked ), '' ) hbrand,
                    IF( a.name = 'hotelStars', IF( a.valueChecked IS NULL || a.valueChecked = '', a.value, a.valueChecked ), '' ) hstar,
                    IF( a.name = 'hotelType', IF( a. valueChecked IS NULL || a.valueChecked = '', a.value, a.valueChecked ), '' ) htype,
                    IF( a.name = 'tradingArea', IF( a.valueChecked IS NULL || a.valueChecked = '', a.value, a. valueChecked ), '' ) htrarea
                FROM
                    hotelInfo a
            ) thotel
        GROUP BY
            hotelseq
    ) ghotel
LEFT JOIN (
        SELECT
            a.ppcHotelId,
            a.hotelSeq,
            b.username,
            c.name
        FROM (
                SELECT
                    SUBSTRING( site_param, 4 ) ppcHotelId,
                    hotel_seq hotelSeq
                FROM
                    hotel_tree
                WHERE
                    wrapper_id = 'wippchotel0'
            ) a,
           (
                SELECT
                    username, ppc_id
                FROM
                    ppc_user
                WHERE
                    endDate >= '2012-11-02' ) b,
            ppc_userinfo c
        WHERE
            a.ppcHotelID = b.ppc_id
            AND b.username = c.username
        group by
            a.hotelSeq
    ) photel
ON
    photel.hotelSeq = ghotel.hotelseq
WHERE
    hnames != ''
";


$sql->query( $in );

ok($out eq $sql->beautify($in), "group_concat ok");

done_testing();
