#package MyPlace::OddmuseMod::Debug;
use vars qw/$ModuleXRZDebug $XRZDebugEnable/;
$ModuleXRZDebug=1;
$ModulesDescription .= '<p>$Id: xrzdebug.pl,v 0.1 2009/08/21  $</p>';

use Encode;
sub _from_to {
    my ($var,$from,$to) = @_;
    return $var unless($var);
    return $var unless($to);
    $from = "utf8" unless($from);
    #xrz_debug_log("FSLocale: From $var\n");
        $var = Encode::encode($to,Encode::decode($from,$var)) || $var;
        #xrz_debug_log("FSLocale:  To  $var\n");
        return $var;
    return Encode::encode($to,Encode::decode($from,$var)) or $var;
}

sub xrz_debug_hook {
    no strict;
      foreach(@_) {
          my $org = "$_";
          my $old = "Old$_";
          my $new = "New$_"; 
          *$old = *$org;
          *$org = *$new;
      }
    return $new,$old;
}
use vars qw/$DataDir $XD_LOG_FILE/;
$XD_LOG_FILE = $DataDir . "/xrzdebug.log" unless($XD_LOG_FILE);
sub xrz_debug_log {
    return unless($XRZDebugEnable);
    return unless(@_);
    open FO,">>",$XD_LOG_FILE;
    print FO @_;
    close FO;
    print STDERR @_;
  1;
}

sub xrz_debug_return {
    my $pre = shift;
    my $suf = shift;
    return @_ unless($XRZDebugEnable);
    xrz_debug_log($pre,@_,$suf);
    return @_;
}

1;
