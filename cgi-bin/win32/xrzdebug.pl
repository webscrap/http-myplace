use vars qw/$XD_LOG_FILE $DataDir/;
  $XD_LOG_FILE = $DataDir . "/xrzdebug.log" unless($XD_LOG_FILE);
  sub xrz_debug_hook {
      no strict;
        foreach(@_) {
            my $org = "$_";
            my $old = "$_";
            my $new = "$_"; 
            *$old = *$org;
            *$org = *$new;
        }
  }
  sub xrz_debug_log {
    return unless(@_);
    open FO,">>",$XD_LOG_FILE;
    print FO "@_" if(@_);;
    close FO;
    return 1;
  }
  sub xrz_debug_return {
      my $pre = shift;
      my $suf = shift;
      xrz_debug_log($pre,@_,$suf);
      return @_;
  }
 1; 