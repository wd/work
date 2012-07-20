#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Carp;
use File::Basename;
use MIME::Lite;
use MIME::Types;

sub usage {
    print <<EOF;
$0
    -to 邮件收件人
    -from 邮件发件人，默认 searcher\@qunar.com
    -title 邮件标题，默认 A test msg
    -file file1 -file file2 附加图片，可以使用多次
    -contents 附加文本内容
EOF
    exit;
}

sub main {
    my $v;
    my $to;
    my $from;
    my $title;
    my $files;
    my $contents;

    GetOptions (
        "verbose"   => \$v,
        'to=s' => \$to,
        'from=s' => \$from,
        'title=s' => \$title,
        'file=s@' => \$files,
        'contents=s' => \$contents,
    );


    #my $msg = MIME::Lite->new(
    #     To      =>'you@yourhost.com',
    #     Subject =>'HTML with in-line images!',
    #     Type    =>'multipart/related'
    #);

    my $msg = MIME::Lite->new(
        To => $to || &usage,
        From => $from || 'searcher@qunar.com',
        Subject => $title || 'A test msg',
        Type => 'multipart/related',
    );


    my $html = "";
    my $mime = MIME::Types->new();

    for my $file ( @$files ) {

        croak "file <$file> not exits! " if !-e $file;

        my ( $name, $path, $suffix ) = fileparse($file);
        $html .= qq{ $name : <br /><img src="cid:$name" /><br /> };

    }

    $contents = defined $contents ? $contents : "";

    if ( $html ) {

        $msg->attach(
            Type => 'text/html',
            Data => "<body><p>$contents</p>$html</body>",
        );
    } else {
        $msg->attach(
            Type => "text/html",
            Data => "<body><p>$contents</p>no file attached</body>",
        );
    }

    for my $file ( @$files ) {

        my ( $name, $path, $suffix ) = fileparse($file);

        my $type = $mime->mimeTypeOf($file);
        $msg->attach(
            Type => $type,
            Id => "$name",
            Path => "$file",
        );
    }

    $msg->attr('content-type.charset' => 'UTF-8');
    $msg->send( );
}

&main;
