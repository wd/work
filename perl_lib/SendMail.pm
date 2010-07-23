package SendMail;

use strict;
use warnings;
use Data::Dumper;
use Encode;
use MIME::Base64;

=head1 Examples

my $sm = SendMail->new( {
    To => 'you@foo.com, other@bar.com',
    Subject => 'just a test 中文',
    });

-- or --

my $sm = SendMail->new( {
    From => 'me@abc.com',
    To => 'you@foo.com, other@bar.com',
    Subject => 'just a test 中文',
    } );

-- or --

my $sm = SendMail->new( {
    From => 'me@abc.com',
    To => 'you@foo.com, other@bar.com',
    Cc => 'cc@foobar.com',
    Subject => 'just a test 中文',
    } );


$sm->attach( {
    Type => "text/plain",
    Data => "只是一个测试..a test"
    });

$sm->attach( {
    Type => 'application/octet-stream',
    Filename => 'test 中文.txt',
    Data => "只是一个 test ..."
    });

$sm->test;

-- or --

$sm->send;

=cut



use vars qw($VERSION);
$VERSION = '0.01';

our $boundary = "FFFFFFFFKKKKKK";
our $from = 'logs@qunar.com';
our $subject = "No subject";

our $to;
our $cc;
our @body;


sub new {
    my $package = shift;
    my $info = shift;

    $subject = $info->{Subject} || $subject;
    $subject = encode('MIME-B', decode('utf8', $subject));
    $from = $info->{From} || $from;
    $to = $info->{To} || die "Need to set MailTo 'To'!";
    $cc = $info->{Cc} || "";

    push @body, "MIME-Version: 1.0";
    push @body, "Content-Type: multipart/mixed; boundary=\"$boundary\"";
    push @body, "";

    return bless( {}, $package);
}

sub attach {
    my $self = shift;
    my $f_hash = shift;

    die "Need data when attach!" if ( not defined $f_hash->{Data} );

    my $type = "text/plain";
    $type = $f_hash->{Type} if defined $f_hash->{Type};

    my @t;
    push @t, "--$boundary";
    if ( $type eq "text/plain" ) {
        push @t, "Content-Type: $type; charset=utf-8";
    } else {
        my $filename = "file1.txt";
        $filename = encode('MIME-B', decode('utf8', $f_hash->{Filename})) if defined $f_hash->{Filename};
        push @t, "Content-Type: $type";
        push @t, "Content-Disposition: attachment; filename=$filename";
    }
    push @t, "Content-Transfer-Encoding: base64";
    push @t, "";
    push @t, encode_base64($f_hash->{Data});

    push @body, @t;
}

sub send {
    my $self = shift;

    open(my $fh, '|/usr/sbin/sendmail -t');
    $self->print_to($fh);
    close($fh);
}

sub print_to {
    my $self = shift;
    my $fh = shift;

    push @body, "--$boundary--";

    print $fh "From: $from\r\n";
    print $fh "To: $to\r\n";
    print $fh "Cc: $cc\r\n" if $cc;
    print $fh "Subject: $subject\r\n";

    for ( @body ) {
        print $fh "$_\r\n";
    }
}

sub test {
    my $self = shift;

    open ( my $fh, '>-');
    $self->print_to($fh);
    close($fh);
}

1;
