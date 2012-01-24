#package MyPlace::OddmuseMod::IO;
use vars qw/$ModulesDescription $ModuleDir $FSEncodingName $ModuleXRZDebug $WikiEncodingName $ModuleFSEncoding/;

unless($ModuleFSEncoding) {

$ModulesDescription .= '<p>$Id: xrzio.pl,v 0.1 2009/08/22  $<br />   -   Handle system level io</p>';

$ModuleFSEncoding = 1;
$WikiEncodingName = "utf8";

use MyPlace::OddmuseMod::Debug;
#do "$ModuleDir/xrzdebug.pl" unless($ModuleXRZDebug);
xrz_debug_hook("CreateDir","WriteStringToFile","ReadFile","AppendStringToFile");

#  ReportError(T('Cannot save a nameless page.'), '400 BAD REQUEST', 1) unless $OpenPageName;
sub NewAppendStringToFile {
    my $file = shift;
    $file = _from_to($file,$WikiEncodingName,$FSEncodingName) if($FSEncodingName);
#    xrz_debug_log("Append to $file\n");
    my $string = shift;
      open(OUT, ">>:perlio","$file")
        or ReportError(Ts('Cannot write %s', $file) . ": $!", '500 INTERNAL SERVER ERROR');
      print OUT  $string;
      close(OUT);
    #return OldAppendStringToFile($file,@_);
}

sub NewReadFile {
    my $file = shift;
    $file =  _from_to($file,$WikiEncodingName,$FSEncodingName) if($FSEncodingName);
#    xrz_debug_log("Read $file\n");
    if (open(IN, "<:perlio",$file)) {
        local $/ = undef;   # Read complete files
        my $data=<IN>;
        close IN;
        return (1, $data);
      }
    return (0, '');
    #return OldReadFile($file,@_);
}

sub NewWriteStringToFile {
    my $file = shift;
    $file = _from_to($file,$WikiEncodingName,$FSEncodingName) if($FSEncodingName);;
#    xrz_debug_log("Write $file\n");
    my $string = shift;
      open(OUT, ">:perlio",$file)
        or ReportError(Ts('Cannot write %s', $file) . ": $!", '500 INTERNAL SERVER ERROR');
      print OUT  $string;
      close(OUT);
      chmod 0664,$file;
   # return OldWriteStringToFile($file,@_);
}

sub NewCreateDir {
    return unless @_;
   my $dir = $FSEncodingName ? _from_to($_[0],$WikiEncodingName,$FSEncodingName) : $_[0];
    xrz_debug_log("CreateDir $dir\n");
    return OldCreateDir($dir);
   my @parts = split(/[\/\\]/,$dir);
   my $cdir = shift @parts;
   OldCreateDir($cdir) if($cdir);
   chmod 0770,$cdir if($cdir);
   foreach(@parts) {
       $cdir .= "/$_";
       OldCreateDir($cdir);
       chmod 0775,$cdir;
   }
}
}
1;
