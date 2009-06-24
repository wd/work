#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use LWP::UserAgent;
use Term::ANSIColor;

my $ua = LWP::UserAgent->new(
	agent => 'Mozilla/5.0',
	max_size => 1024*1024);
$ua->timeout(20);

if ( ! scalar @ARGV ) {
	print "need verycd url as args\n";
	exit 1;
}

my $url = $ARGV[0];
my $response = $ua->get($url);
if ( $response->is_success ) {
	my @contents = split /\n/, $response->decoded_content;
	my %o = ();
	foreach( @contents) {
		if ( /<a\s+href="(ed2k:\/\/\|file\|(.*?)\|.*?)"/i ) {
			my ( $file, $link)  = ($2, $1);
			$file =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
			$o{$file} = $link;
		}	
	}
	foreach( sort(keys %o) ) {
		print color "yellow";
		print $_,"\n";
		print color "reset";
		print $o{$_}, "\n";
	}
} else {
	return $response->status_line;
}
