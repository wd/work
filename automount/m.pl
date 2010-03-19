#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use YAML;
use Getopt::Long;


my $c = 'm.conf';
my ( $v , $h );

sub usage {
	my $e = shift;
	print $e if $e;
	print "Usage: $0 -c conf -v -h
    -c Conf file, default is m.conf 
    -v print debug info
    -h Print this help\n";
	exit(1);
}

sub error() {
	my $msg = shift;
	print $msg . "\n";
	exit;
}

sub select() {
	my @conf = @_;
	my $i = 0;
	for ( @conf ) {
		$i ++;
		print "$i\t" . $_->{'name'} . "\n";
	}

	print "Input your choise:";
	my $sel = <>;
	chomp($sel);
	&error("Input error") if ( ( not $sel) or ( $sel !~ /^[0-9]+$/ ) );

	return $conf[$sel - 1];
}

sub mount_smb() {
	my $conf = shift;
	my $ip = $conf->{'ip'};
	my $type = $conf->{'type'};
	my $user = defined $conf->{'user'} ? $conf->{'user'} : "";
	my $pwd = defined $conf->{'pwd'} ? $conf->{'pwd'} : "";
	my $opt = defined $conf->{'opt'} ? $conf->{'opt'} : "";

	if ( not $ip ) {
		print "Enter server's ip: ";
		my $sel = <>;
		chomp($sel);
		&error("Input error") if not $sel;
		$ip = $sel;
	}

	my $cmd ;
	if ( $pwd && $user ) {
		$cmd = "sudo smbclient -g -U $user%$pwd --list $ip";
	} elsif ( $user ) {
		$cmd = "sudo smbclient -g -U $user --list $ip";
	} else {
		$cmd = "sudo smbclient -g -N --list $ip";
	}

	my @out = `$cmd 2>/dev/null`;
	my @error = grep { /Error/i } @out;

	&error("@error") if @error;
	my @shares ;

	for ( @out ) {
		chomp;
		s/^\s+//;
		s/\s+$//;

		my @tmp = split /\|/i;
		push @shares, \@tmp;
	}

	my $i = 0;
	print "num\tname\ttype\n";
	for( @shares ) {
		$i++;
		printf "%d\t%s\t%s\n", $i, @$_[1], @$_[0] if scalar @$_ > 1;
	}

	&error("No share found.") if not @shares;

	print "Mount which share? ";
	my $sel = <>;
	chomp($sel);
	&error("Input error") if (( $sel !~ /^[0-9]+$/) or ( $sel eq "" ));
	my $mount_what = ${$shares[$sel-1]}[1];
	print "Mount $mount_what to where? [/mnt] ";
	$sel = <>;
	chomp($sel);
	$sel = "/mnt" if not $sel;

	if ( $pwd && $user ) {
		$cmd = "sudo mount -t $type -o username=$user,password=$pwd,$opt '//$ip/$mount_what' $sel";
	} elsif ( $user ) {
		$cmd = "sudo mount -t $type -o username=$user,$opt '//$ip/$mount_what' $sel";
	} else {
		$cmd = "sudo mount -t $type -o guest,$opt '//$ip/$mount_what' $sel";
	}

	@out = `$cmd`;
	&error("@out") if @out;
	print "sudo umount $sel\n";
}

sub mount_u() {
	my $conf = shift;
	my @partitions = split(/[,\s]+/, $conf->{'partitions'});

	print "Mount to where? [/mnt] ";
	my $sel = <>;
	chomp($sel);
	$sel = "/mnt" if not $sel;

	my @tmp;
	for ( @partitions ) {
		my $path = $_;
		$path =~ s#.*/([^/]+)#m_$1#;
		`sudo mkdir -p $sel/$path`;
		my @out = `sudo mount $_ $sel/$path`;
		&error("@out") if @out;
		push @tmp, $path;
	}

	for ( @tmp ) {
		print "sudo umount $sel/$_\n";
	}
}

sub main() {
	GetOptions("c=s" => \$c, "v" => \$v, 'h' => \$h);
	&usage if ( $h ) ;
	&usage("File not found: $c\n") if ( ! -e $c );

	my $conf = YAML::LoadFile($c);
	my $sel = &select( @$conf );
	&error("Nothing found in conf file.") if not $sel;

	print "You select: " . $sel->{'name'} . " type: " . $sel->{'type'} . "\n";

	for ( $sel->{'type'} ) {
		/^smbfs|cifs$/i && do { &mount_smb( $sel ) ; last; }; 
		/^u$/i && $sel->{'partitions'} && do { &mount_u ( $sel ) ; last; };
	}
}

&main();
