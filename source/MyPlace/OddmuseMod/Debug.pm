package MyPlace::OddmuseMod::Debug;
BEGIN {
	use Exporter;
	@ISA = ('Exporter');
	@EXPORT = qw/&xrz_debug_log &_from_to &xrz_debug_hook &xrz_debug_return $XRZDebugEnable $ModuleXRZDebug/;
}
our $ModuleDescription = '<p>$Id: MyPlace::OddmuseMod::Debug, v0.1, 2009/08/21  $</p>';
our $ModuleXRZDebug = 1;
our $XRZDebugEnable = $OddMuse::XRZDebugEnable;
our $Debugging = \@OddMuse::Debugging;
our @XRZDebugMessage;
$OddMuse::ModulesDescription .= $ModuleDescription;

if($XRZDebugEnable) {
	push @$Debugging,sub {
		$q->p(join('<BR/>',@XRZDebugMessage));
		@XRZDebugMessage = ();
	};
}
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
		  ${OddMuse::}{$old} = ${OddMuse::}{$org};
		  ${OddMuse::}{$org} = ${OddMuse::}{$new};
      }
    return $new,$old;
}

my $DataDir = $OddMuse::DataDir;
my $XD_LOG_FILE = $OddMuse::XD_LOG_FILE;
$XD_LOG_FILE = $DataDir . "/xrzdebug.log" unless($XD_LOG_FILE);
sub xrz_debug_log {
	push @XRZDebugMessage,@_;
   # return unless($XRZDebugEnable);
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

my $SELF;

sub new {
	return $SELF if($SELF);
	my $class = shift;
	$SELF = bless \$class,$class;
	return $SELF;
}

sub log {
	my $self = shift;
	return &xrz_debug_log(@_);
}

__PACKAGE__->new();
