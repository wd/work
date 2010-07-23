package UAparser;

use strict;
use warnings;
use Data::Dumper;

use vars qw($VERSION);
$VERSION = '0.01';

########################
# from awstats-6.95/wwwroot/cgi-bin/awstats.pl
our $regvermsie        = qr/msie([+_ ]|)([\d\.]*)/i;
our $regvernetscape    = qr/netscape.?\/([\d\.]*)/i;
our $regverfirefox     = qr/firefox\/([\d\.]*)/i;
our $regveropera       = qr/opera\/([\d\.]*)/i;
our $regversafari      = qr/safari\/([\d\.]*)/i;
our $regversafariver   = qr/version\/([\d\.]*)/i;
our $regverchrome      = qr/chrome\/([\d\.]*)/i;
our $regverkonqueror   = qr/konqueror\/([\d\.]*)/i;
our $regversvn         = qr/svn\/([\d\.]*)/i;
our $regvermozilla     = qr/mozilla(\/|)([\d\.]*)/i;
our $regnotie          = qr/webtv|omniweb|opera/i;
our $regnotnetscape    = qr/gecko|compatible|opera|galeon|safari|charon/i;
our $regnotfirefox     = qr/flock/i;
our $regnotsafari      = qr/android|arora|chrome|shiira/i;


our %SafariBuildToVersion = (
	'85'        => '1.0',
	'85.5'      => '1.0',
	'85.7'      => '1.0.2',
	'85.8'      => '1.0.3',
	'85.8.1'    => '1.0.3',
	'100'       => '1.1',
	'100.1'     => '1.1.1',
	'125.7'     => '1.2.2',
	'125.8'     => '1.2.2',
	'125.9'     => '1.2.3',
	'125.11'    => '1.2.4',
	'125.12'    => '1.2.4',
	'312'       => '1.3',
	'312.3'     => '1.3.1',
	'312.3.1'   => '1.3.1',
	'312.5'     => '1.3.2',
	'312.6'     => '1.3.2',
	'412'       => '2.0',
	'412.2'     => '2.0',
	'412.2.2'   => '2.0',
	'412.5'     => '2.0.1',
	'413'       => '2.0.1',
	'416.12'    => '2.0.2',
	'416.13'    => '2.0.2',
	'417.8'     => '2.0.3',
	'417.9.2'   => '2.0.3',
	'417.9.3'   => '2.0.3',
	'419.3'     => '2.0.4',
	'522.11.3'  => '3.0',
	'522.12'    => '3.0.2',
	'523.10'    => '3.0.4',
	'523.12'    => '3.0.4',
	'525.13'    => '3.1',
	'525.17'    => '3.1.1',
	'525.20'    => '3.1.1',
	'525.20.1'  => '3.1.2',
	'525.21'    => '3.1.2',
	'525.22'    => '3.1.2',
	'525.26'    => '3.2',
	'525.26.13' => '3.2',
	'525.27'    => '3.2.1',
	'525.27.1'  => '3.2.1',
	'526.11.2'  => '4.0',
	'528.1'     => '4.0',
	'528.16'    => '4.0'
);

sub UnCompileRegex {
    #shift =~ /\(\?[-\w]*:(.*)\)/;
    my $tmp = shift;
    $tmp =~ s/\\//g;
    return $tmp;
}

############################

###########################
# from awstats-6.95/wwwroot/cgi-bin/lib/browsers.pm
our @BrowsersSearchIDOrder = (
# Most frequent standard web browsers are first in this list except the ones hardcoded in awstats.pl:
# firefox, opera, chrome, safari, konqueror, svn, msie, netscape
'elinks',
'firebird',
'go!zilla',
'icab',
'links',
'lynx',
'omniweb',
# Other standard web browsers
'22acidownload',
'abrowse',
'aol\-iweng',
'amaya',
'amigavoyager',
'arora',
'aweb',
'charon',
'donzilla',
'seamonkey',
'flock',
'minefield',
'bonecho',
'granparadiso',
'songbird',
'strata',
'sylera',
'kazehakase',
'prism',
'icecat',
'iceape',
'iceweasel',
'w3clinemode',
'bpftp',
'camino',
'chimera',
'cyberdog',
'dillo',
'xchaos_arachne',
'doris',
'dreamcast',
'xbox',
'downloadagent',
'ecatch',
'emailsiphon',
'encompass',
'epiphany',
'friendlyspider',
'fresco',
'galeon',
'flashget',
'freshdownload',
'getright',
'leechget',
'netants',
'headdump',
'hotjava',
'ibrowse',
'intergo',
'k\-meleon',
'k\-ninja',
'linemodebrowser',
'lotus\-notes',
'macweb',
'multizilla',
'ncsa_mosaic',
'netcaptor',
'netpositive',
'nutscrape',
'msfrontpageexpress',
'contiki',
'emacs\-w3',
'phoenix',
'shiira',               # Must be before safari
'tzgeturl',
'viking',
'webfetcher',
'webexplorer',
'webmirror',
'webvcr',
'qnx\svoyager',
# Site grabbers
'teleport',
'webcapture',
'webcopier',
# Media only browsers
'real',
'winamp',				# Works for winampmpeg and winamp3httprdr
'windows\-media\-player',
'audion',
'freeamp',
'itunes',
'jetaudio',
'mint_audio',
'mpg123',
'mplayer',
'nsplayer',
'qts',
'quicktime',
'sonique',
'uplayer',
'xaudio',
'xine',
'xmms',
'gstreamer',
# RSS Readers
'abilon',
'aggrevator',
'aiderss',
'akregator',
'applesyndication',
'betanews_reader',
'blogbridge',
'cyndicate',
'feeddemon', 
'feedreader', 
'feedtools',
'greatnews',
'gregarius',
'hatena_rss', 
'jetbrains_omea', 
'liferea',
'netnewswire', 
'newsfire', 
'newsgator', 
'newzcrawler',
'plagger',
'pluck', 
'potu',
'pubsub\-rss\-reader',
'pulpfiction', 
'rssbandit', 
'rssreader',
'rssowl', 
'rss\sxpress',
'rssxpress',
'sage', 
'sharpreader', 
'shrook', 
'straw', 
'syndirella', 
'vienna',
'wizz\srss\snews\sreader',
# PDA/Phonecell browsers
'alcatel',				# Alcatel
'lg\-',					# LG
'mot\-',				# Motorola
'nokia',				# Nokia
'panasonic',			# Panasonic
'philips',				# Philips
'sagem',				# Sagem
'samsung',				# Samsung
'sie\-',				# SIE
'sec\-',				# SonyEricsson
'sonyericsson',			# SonyEricsson
'ericsson',				# Ericsson (must be after sonyericsson)
'mmef',
'mspie',
'vodafone',
'wapalizer',
'wapsilon',
'wap',					# Generic WAP phone (must be after 'wap*')
'webcollage',
'up\.',					# Works for UP.Browser and UP.Link
# PDA/Phonecell browsers
'android',
'blackberry',
'cnf2',
'docomo',
'ipcheck',
'iphone',
'portalmmm',
# Others (TV)
'webtv',
'democracy',
# Anonymous Proxy Browsers (can be used as grabbers as well...)
'cjb\.net',
'ossproxy',
'smallproxy',
# Other kind of browsers
'adobeair',
'apt',
'analogx_proxy',
'gnome\-vfs',
'neon',
'curl',
'csscheck',
'httrack',
'fdm',
'javaws',
'wget',
'fget',
'chilkat',
'webdownloader\sfor\sx',
'w3m',
'wdg_validator',
'w3c_validator',
'jigsaw',
'webreaper',
'webzip',
'staroffice',
'gnus', 
'nikto', 
'download\smaster',
'microsoft\-webdav\-miniredir', 
'microsoft\sdata\saccess\sinternet\spublishing\sprovider\scache\smanager',
'microsoft\sdata\saccess\sinternet\spublishing\sprovider\sdav',
'POE\-Component\-Client\-HTTP',
'mozilla',				# Must be at end because a lot of browsers contains mozilla in string
'libwww',				# Must be at end because some browser have both 'browser id' and 'libwww'
'lwp'
);

################################

my %TmpBrowser = ();
my @_browser = ();

sub new() {
    my $package = shift;
    return bless( {}, $package);
}


sub parse() {
    my $self = shift;
    my $UserAgent = shift;

    ################
    # from awstats-6.95/wwwroot/cgi-bin/awstats.pl
    # Analyze: Browser
    #-----------------
    my @uabrowser = ();
    @uabrowser = @{$TmpBrowser{$UserAgent}} if ( defined $TmpBrowser{$UserAgent} );
    if ( ! @uabrowser ) {
    	my $found = 1;
    
    	# Firefox ?
    	if (   $UserAgent =~ /$regverfirefox/o
    		&& $UserAgent !~ /$regnotfirefox/o )
    	{
            @_browser = ( 'frefox', $1 );
    		$TmpBrowser{$UserAgent} = [ "firefox" , $1 ];
    	}
    
    	# Opera ?
    	elsif ( $UserAgent =~ /$regveropera/o ) {
            @_browser = ( 'opera', $1 );
    		$TmpBrowser{$UserAgent} = [ "opera", $1 ];
    	}
    
    	# Chrome ?
    	elsif ( $UserAgent =~ /$regverchrome/o ) {
            @_browser = ( 'chrome', $1 );
    		$TmpBrowser{$UserAgent} = [ "chrome" , $1 ];
    	}
    
    	# Safari ?
    	elsif ($UserAgent =~ /$regversafari/o
    		&& $UserAgent !~ /$regnotsafari/o )
    	{
    		my $safariver = $SafariBuildToVersion{$1};
    		if ( $UserAgent =~ /$regversafariver/o ) {
    			$safariver = $1;
    		}
            @_browser = ( 'safari', $safariver );
    		$TmpBrowser{$UserAgent} = [ "safari" , $safariver ];
    	}
    
    	# Konqueror ?
    	elsif ( $UserAgent =~ /$regverkonqueror/o ) {
            @_browser = ( 'konqueror', $1 );
    		$TmpBrowser{$UserAgent} = [ "konqueror", $1 ];
    	}
    
    	# Subversion ?
    	elsif ( $UserAgent =~ /$regversvn/o ) {
            @_browser = ( 'svn', $1 );
    		$TmpBrowser{$UserAgent} = [ "svn", $1 ];
    	}
    
    	# IE ? (must be at end of test)
    	elsif ($UserAgent =~ /$regvermsie/o
    		&& $UserAgent !~ /$regnotie/o )
    	{
            @_browser = ( 'msie', $2 );
    		$TmpBrowser{$UserAgent} = [ "msie", $2 ];
    	}
    
    	# Netscape 6.x, 7.x ... ? (must be at end of test)
    	elsif ( $UserAgent =~ /$regvernetscape/o ) {
            @_browser = ( 'netscape', $1 );
    		$TmpBrowser{$UserAgent} = [ "netscape", $1 ];
    	}
    
    	# Netscape 3.x, 4.x ... ? (must be at end of test)
    	elsif ($UserAgent =~ /$regvermozilla/o
    		&& $UserAgent !~ /$regnotnetscape/o )
    	{
            @_browser = ( 'netscape', $2 );
    		$TmpBrowser{$UserAgent} = [ "netscape", $2 ];
    	}
    
    	# Other known browsers ?
    	else {
    		$found = 0;
    		foreach (@BrowsersSearchIDOrder)
    		{    # Search ID in order of BrowsersSearchIDOrder
    			if ( $UserAgent =~ /$_/ ) {
    				my $browser = &UnCompileRegex($_);
    
    			   # TODO If browser is in a family, use version
                    @_browser = ( $browser, 0 );
    				$TmpBrowser{$UserAgent} = [ "$browser", 0 ];
    				$found = 1;
    				last;
    			}
    		}
    	}
    
    	# Unknown browser ?
    	if ( !$found ) {
            @_browser = ( 'Unknown', 0 );
    		$TmpBrowser{$UserAgent} = [ 'Unknown', 0 ];
    	}
    } else {
        @_browser = @uabrowser;
    }

    return \@_browser;
}

1;
