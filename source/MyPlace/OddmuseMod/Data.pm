#!/usr/bin/perl -w
#package MyPlace::OddmuseMod::Data;
#package Oddmuse;
use Encode;
use vars qw/$ModulesDescription $q $UsePathInfo $XD_LOG_FILE $DataDir $FSEncodingName/;
use vars qw/$FSEncodingName $PageDir $KeepDir %IndexHash @IndexList $IndexFile/;
use vars qw/$FreeLinkPattern $LinkPattern $ScriptName/;
use vars qw/$ZimDefaultUser/;
use vars qw/%Action/;
$ModulesDescription .= '<p>$Id: xrzdata.pl,v 0.1,2009/08/21 00:55:26 as Exp $<br/> - Data presentation</p>';

use vars qw/
    $ModuleDir
    $ModuleXRZDebug
    $ModuleFixGetId
    $ModuleXRZPage
    $ModuleFSEncoding
    $PageFileExt
    $ZimDataParser
/;

use MyPlace::OddmuseMod::Debug;
use MyPlace::OddmuseMod::Hook;
my $PACKAGE_MAIN = 'OddMuse';
my $DEBUG = new MyPlace::OddmuseMod::Debug;
my $HOOK = new MyPlace::OddmuseMod::Hook;
#do "$ModuleDir/xrzdebug.pl" if(!$ModuleXRZDebug and -f "$ModuleDir/xrzdebug.pl");
#do "$ModuleDir/xrzio.pl" if($FSEncodingName and -f "$ModuleDir/xrzio.pl");
#do "$ModuleDir/xrzpageid.pl" if(!$ModuleFixGetId and -f "$ModuleDir/xrzpageid.pl");
#do "$ModuleDir/xrzpage.pl" if(!$ModuleXRZPage and -f "$ModuleDir/xrzpage.pl");

$Action{source}=$Action{download};

$PageFileExt = ".txt";
$ZimDataParser = 0;


sub GetPageList {
    my $dir = shift;
    my @r;
    foreach(glob("$dir/*")) {
        next if(/\/\.+$/);
        push @r,$_ if(-f $_);
        push @r,&GetPageList($_);
    }
    return @r;
}

$HOOK->hook($PACKAGE_MAIN,
	"AllPagesList",
	"ParseData",
	"EncodePage",
	"GetSearchLink",
	'PrintWikiToHTML',
	'ResolveId',
	'GetPageOrEditLink',
);

sub NewAllPagesList {
  my $refresh = GetParam('refresh', 0);
  return @IndexList if @IndexList and not $refresh;
  if (not $refresh and -f $IndexFile) {
    my ($status, $rawIndex) = ReadFile($IndexFile); # not fatal
    if ($status) {
      %IndexHash = split(/\s+/, $rawIndex);
      @IndexList = sort(keys %IndexHash);
      return @IndexList;
    }
    # If open fails just refresh the index
  }
  @IndexList = ();
  %IndexHash = ();
  # Try to write out the list for future runs.  If file exists and cannot be changed, error!
  my $locked = RequestLockDir('index', undef, undef, -f $IndexFile);
  my $ext = $PageFileExt;
  $ext =~ s/\./\\./g;
  foreach (GetPageList($PageDir)) { # find .dotfiles, too
    next unless m|$PageDir/(.+)$ext$|;
    my $id = $1;
    $id =~ s|\/|:|g;
    $id = _from_to($id,$FSEncodingName,"utf8") if($FSEncodingName);
    push(@IndexList, $id);
    $IndexHash{$id} = 1;
  }
  WriteStringToFile($IndexFile, join(' ', %IndexHash)) if $locked;
  ReleaseLockDir('index') if $locked;
  return @IndexList;
};



my $meta_start = "-"x9 . "<META>" . "-"x9 . "\n";
my $meta_start_1 = "-"x9 . "<META>" . "-"x9 . "\r\n";
my $meta_start_2 = "\n" . "version information" . "\n" .  
                        "------- -----------" . "\n";
use vars qw/$Now/;

use vars qw/$Message/;
sub NewParseData {
    return OldParseData(@_) unless($ZimDataParser);
    my $data = shift;   # by eliminating non-trivial regular expressions
#  $data =~ s/\015//og;
    my $meta_text;
    my %result;
    $result{flags}=0;
    $result{ts} = 0;
    $result{revision} = 1;
    $result{username} = $ZimDefaultUser if($ZimDefaultUser);
    my $end = index($data, $meta_start);
    my $meta_length = length($meta_start);
  #  $result{text}=$meta_start . "\n" . $end ."\n" .  $data;
  #  return %result;
    if($end <0) {
        $end = index($data,$meta_start_1);
        $meta_length = length($meta_start_1);
    }
    if($end <0) {
        $end = index($data,$meta_start_2);
        $meta_length = length($meta_start_2);
    }

    if($end >=0) {
        $result{text} = substr($data,0,$end);
        $meta_text = substr($data,$end + $meta_length);
    }
    else {
        $result{text} = $data;
        return %result;
    }
    if($meta_text) {
            if($meta_text =~ m/^Revision (\d+)/cg) {
                $result{revision} = $1;
            }
            if($meta_text =~ m/, by ([^,\@\n]+)/cg) {
                $result{username} = $1;
            }
            if($meta_text =~ m/\G\@([^\n]+)\n/cg) {
                $result{host} = $1;
            }
            while($meta_text =~ m/\s*(flags|ip|minor|host|summary|languages|reversion|ts|lastmajor|keep-ts): ([^\r\n]+)[\r\n]/g) {
    #            $Message .= "<pre>MEAT_TEXT:$1 : $2</pre>";
                $result{$1} = $2;
            }
    }

  return %result;
}

sub NewEncodePage {
  return OldEncodePage(@_) unless($ZimDataParser);
  my %data = @_;
#  &xrz_debug_log("NewEncodePage: dumper %data : \n" . Dumper(\%data));
  my $result=$data{text} || "";
  my $meta_info =  $meta_start_2 . 
                   "Revision " . ($data{revision} || '1') .
                   ($data{ts} ? ", Last updated " . localtime($data{ts}) : "") . 
                   ($data{username} ? ", by " . $data{username} : "" ).
                   ($data{host} ? "@" . $data{host} : "") .
                   "\n";
  foreach(qw/ts lastmajor keep-ts/) {
        $meta_info .= "$_: " .  $data{$_} . "\n";
  }
  return $result . $meta_info;
}

sub NewPrintWikiToHTML {
  my ($markup, $is_saving_cache, $revision, $is_locked) = @_;
  my ($blocks, $flags);
  $FootnoteNumber = 0;
  $markup =~ s/$FS//go if $markup;  # Remove separators (paranoia)
  $markup = QuoteHtml($markup);
  ($blocks, $flags) = ApplyRules($markup, 1, $is_saving_cache, $revision, 'p');
  $Page{blocks} = $blocks;
  $Page{flags} =  $flags;
  return;
}

sub NewResolveId { 
  my $id = shift;
  return ('local', $id, '', 1) if $IndexHash{$id};
  my $file = GetPageFile($id);
  if(-f $file) {
    $IndexHash{$id} = 1;
    @IndexList = sort(keys %IndexHash);
    WriteStringToFile($IndexFile, join(' ', %IndexHash));
    return ('local',$id,'',1);
  }
  &xrz_debug_log("ResolveId faild for $id\n");
  return ('', '', '', '');
}


sub NewGetSearchLink {
    my $id = shift;
    if($id =~ /([\/:])/) {
        my $spe = $1;
        my @ids = split(/[\/:]/,$id);
        my $cur = "";
        my $result;
        foreach(@ids) {
            $cur = $cur ?  "$cur$1$_" : $_;
            $result = $result ? $result . "$1" . ScriptLink($cur,$_) : ScriptLink($cur,$_);
        }
        return $result;
    }
    else {
        return OldGetSearchLink($id,@_);
    }
}
sub NewGetPageOrEditLink { # use GetPageLink and GetEditLink if you know the result!
  my ($id, $text, $bracket, $free) = @_;
  $id = FreeToNormal($id);
  my ($class, $resolved, $title, $exists) = NewResolveId($id);
  if (!$text && $resolved && $bracket) {
    $text = BracketLink(++$FootnoteNumber);
    $class .= ' number';
    $title = NormalToFree($id);
  }
  my $link = $text||NormalToFree($id);
  if ($resolved) { # anchors don't exist as pages, therefore do not use $exists
    return ScriptLink(UrlEncode($resolved), $link, $class, undef, $title);
  } else {      # reproduce markup if $UseQuestionmark
    return GetEditLink($id, $bracket ? "[$link]" : $link) if not $UseQuestionmark;
    $link = ($text ? $text : $id ) . GetEditLink($id, '?');
    #$link .= ($free ? '|' : ' ') . $text if $text and $text ne $id;
    $link = "[[$link]]" if $free;
    $link = "[$link]" if $bracket or not $free;# and $text;
    return $link;
  }
}

1;
