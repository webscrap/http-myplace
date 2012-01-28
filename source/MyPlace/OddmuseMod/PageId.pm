#package MyPlace::OddmuseMod::PageId;
use vars qw/$ModuleFixGetId $ModuleXRZDebug $ModuleDir $DataDir $UsePathInfo $q/;

unless($ModuleFixGetId) {
use CGI::Util qw/unescape/;

$ModulesDescription .= '<p>$Id: xrzpageid.pl,v 0.1 2009/08/21 00:55:26 as Exp $</p>';
$ModuleFixGetId = 1;

use MyPlace::OddmuseMod::Debug;
use MyPlace::OddmuseMod::Hook;
my $PACKAGE_MAIN = 'OddMuse';
my $DEBUG = new MyPlace::OddmuseMod::Debug;
my $HOOK = new MyPlace::OddmuseMod::Hook;
$HOOK->hook($PACKAGE_MAIN,qw/
	ValidId
	UrlEncode
	FreeToNormal
/);

sub NewFreeToNormal {    # trim all spaces and convert them to underlines
	my $id = shift;
#  return '' unless $id;
#  return $id;
#  $id =~ s/ /_/g;
#  if (index($id, '_') > -1) {  # Quick check for any space/underscores
#    $id =~ s/__+/_/g;
#    $id =~ s/^_//;
#    $id =~ s/_$//;
#  }
  return $id;
}
sub NewUrlEncode {
    my $r = OldUrlEncode(@_);
    $r =~ s/\%3a/:/g;
    $r =~ s/\%2f/\//g;
    return $r;
}

sub NewValidId {
    my $id = shift;
    $id =~ s/[:\/]//g;
    #xrz_debug_log("ValidId: ID=$id\n");
    return OldValidId($id);
}

sub GetPathInfo {
    my $name = $ENV{SCRIPT_NAME};
    my $uri = unescape($ENV{REQUEST_URI});
    xrz_debug_log("SCRIPT_NAME=$name, REQUEST_URI=$uri ");
    if(substr($uri,0,length($name)) eq $name) {
        $uri = substr($uri,length($name));
    }
    $uri =~ s/\?.*$//;
    $uri =~ s/^\/+//;
#    $uri =~ s/^[^\/]+:\/\/[^\/]+\///;
    return $uri;
}

sub NewGetId {
#    my $name = $ENV{SCRIPT_NAME};
#    my $uri = unescape($ENV{REQUEST_URI});
    my $id = join("_",$q->keywords);
    if($UsePathInfo) {
        $id = GetPathInfo();
        #unless($id);
        #my @path = split(/\//,$uri);
        #$id = pop(@path) unless($id);
        #SetParam($_,1) foreach(@path);
    }
    $id = GetParam('id', GetParam('title', $id)); # id=x or title=x override
#    my @keywords = $q->keywords if($q);
    xrz_debug_log(", ID=$id","\n");
    return $id;
}

}

1;
