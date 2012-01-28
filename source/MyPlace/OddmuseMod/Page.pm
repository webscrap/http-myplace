#package MyPlace::OddmuseMod::Page;
use strict;
use File::Spec::Functions qw/catfile catdir splitdir rootdir/;
use vars qw/$ModulesDescription $ModuleDir $PageInCatalog $ModuleXRZPage $PageDirectoryBase $PageFileExt $PageDir $KeepDir $DataDir $FSEncodingName/;

unless($ModuleXRZPage) {
$ModulesDescription .= '<p>$Id: MyPlace::OddMuse::Page,v 0.1 2009/08/21  $<br />   -   Map page Id to filesystem structure</p>';

$ModuleXRZPage = 1;
$PageDirectoryBase = undef;
$PageFileExt = undef;
$PageInCatalog = 0;

use MyPlace::OddmuseMod::Debug;
use MyPlace::OddmuseMod::Hook;
my $PACKAGE_MAIN = 'OddMuse';
my $DEBUG = new MyPlace::OddmuseMod::Debug;
my $HOOK = new MyPlace::OddmuseMod::Hook;

sub _CleanPath {
    my $r = shift;
    #$DEBUG->log("CleanPath: [$r] ===>");
    $r =~ s/[\\\/\:]+/\//go;
    #$DEBUG->log(" [$r]\n");
    return $r;
}

sub _BaseName {
    return unless($_[0]);
    my $id = $_[0];
    $id =~ s/(?:^.*[\/\\:]+|[\/:\\]+$)//;
    $DEBUG->log("_BaseName:@_===>$id\n");
    return $id;
}

sub ExMakeDir {
    return unless(@_);
	foreach(@_) {
		my @dirs = splitdir($_);
		my $path = rootdir();
	    foreach my $part (@dirs) {
			$path = catdir($path,$part);
			next if(-d $path);
	        CreateDir($path);
		}
	}
}


$HOOK->hook($PACKAGE_MAIN,"CreateKeepDir");
sub NewCreateKeepDir {
  my ($dir, $id) = @_;
  ExMakeDir(&catdir($dir,_CleanPath($id)));
  $DEBUG->log("CreateKeepDir $dir,$id\n");
}

$HOOK->hook($PACKAGE_MAIN,"GetKeepFile");
sub NewGetKeepFile {
  my ($id, $revision) = @_; die 'No revision' unless $revision; #FIXME
  my $r = catfile(NewGetKeepDir($id),"$revision.kp");
  $DEBUG->log("GetKeepFile:$id,$revision => $r\n");
  return $r;
}


$HOOK->hook($PACKAGE_MAIN,"GetKeepDir");
sub NewGetKeepDir {
  my $id = shift; die 'No id' unless $id;
  my $r = catdir($KeepDir,_CleanPath($id));
  $DEBUG->log("GetKeepDir:$id => $r\n");
  return $r;
}


$HOOK->hook($PACKAGE_MAIN,"GetKeepFiles");
use File::Glob qw/bsd_glob/;
sub NewGetKeepFiles {
    my $id = shift;
    my @files = bsd_glob(catfile(NewGetKeepDir($id), "*.kp"));
    $DEBUG->log("GetKeepFiles: $id====>@files\n");
    if($FSEncodingName && @files) {
        map {$_ = _from_to($_,$FSEncodingName,"utf8");$_} @files;
    }
    $DEBUG->log("GetKeepFiles: @files\n");
    return @files;
}

sub split_id {
	my $id = shift;
	return undef,undef unless($id);
	if($id =~ m/(.*)([\/:])([^\1]+)$/) {
		return $1,$3;
	}
	else {
		return undef,$id;
	}
}


sub GetPageDir {
	my($dir,$name) = split_id(@_);
	my @r;
	if(!$dir) {
		@r = ($PageDir,$name);
	}
	@r = (catdir($PageDir,_CleanPath($dir)),$name);
	if(wantarray) {
		return @r;
	}
	else {
		return $r[0];
	}
}

sub NewGetPageFile {
    return unless($_[0]);
	my($dir,$name) = GetPageDir(@_);
	my $ext = $PageFileExt ? $PageFileExt : ".pg"; 
	my $r;
	foreach my $filename ($name . $ext, "content$ext") {
		$filename = catfile($dir,$name,$filename);
		if(-f $filename) {
			$r = $filename;
			last;
		}
	}
	$r = catfile($dir,$name . $ext) unless($r);
	$DEBUG->log("GetPageFile @_=>$r\n");
	return $r;
}


$HOOK->hook($PACKAGE_MAIN,"GetPageFile","GetPageDirectory","CreatePageDir");
sub NewCreatePageDir {
  my ($dir, $id) = @_;
  my $page_dir = GetPageDir($id);
  $DEBUG->log("CreatePageDir: $page_dir\n");
  ExMakeDir($page_dir) unless(-d $page_dir);
}
sub NewGetPageDirectory {
    my $id = shift;
	return "" unless($id);
    $id =~ s/:+/\//g;
    $id =~ s/^\/+//g;
    if($id =~ /\//) {
       $id =~ s/\/[^\/]*$//g;
    }
    else {
        $id = "";
    }
    $DEBUG->log("GetPageDirectory:@_=>$id\n");
    return $id;
}


$HOOK->hook($PACKAGE_MAIN,"GetLockedPageFile");
sub NewGetLockedPageFile {
  my $id = shift;
  return catfile(NewGetKeepDir($id) .  ".lck");
}
1;




}

1;

