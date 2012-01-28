package MyPlace::OddmuseMod::Hook;
use vars qw/$ModuleXRZHook/;
$OddMuse::ModuleXRZHook=1;
$OddMuse::ModulesDescription .= '<p>$Id: MyPlace::OddmuseMod::Hook, v0.1, 2012/01/28  $</p>';

use MyPlace::OddmuseMod::Debug;
my $DEBUG = MyPlace::OddmuseMod::Debug->new;

my $SELF;
sub new {
	return $SELF if($SELF);
	my $class = shift;
	$SELF = bless \$class,$class;
	return $SELF;
}

sub hook {
	my $self = shift;
	my $package = shift;
	return unless $package;
	$package .= '::';
    no strict 'refs';
    foreach(@_) {
        my $org = "$_";
        my $old = "Old$_";
        my $new = "New$_"; 
#		${OddMuse::}{$old} = ${OddMuse::}{$org};
#		${OddMuse::}{$org} = ${OddMuse::}{$new};
		${$package}{$old} = ${$package}{$org};
		${$package}{$org} = ${$package}{$new};
#		eval ("*$package$old = *$package$org;*$$package$org = *$package$new;") or die("$@");
		$DEBUG->log("Replace [$org] as [$new], original saved to [$old]\n");
    }
    return $new,$old;
}
__PACKAGE__->new();
