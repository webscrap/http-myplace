
package MyPlace::OddmuseMod::Utils;
use strict;
use MyPlace::OddmuseMod::Debug;
my $DEBUG = new MyPlace::OddmuseMod::Debug;
my $SELF;

sub new {
	return $SELF if($SELF);
	my $class = shift;
	$SELF = bless \$class,$class;
	return $SELF;
}

sub escape_id {
	my $self = shift;
	my $id = shift;
	$id =~ s/ /%20/g;
	return $id;
}

sub unescape_id {
	my $self = shift;
	my $id = shift;
	$id =~ s/%20/ /g;
	return $id;
}

sub importSymbol {
	my $self = shift;
	my $target = shift;
	my $source = shift;
	no strict 'refs';
	foreach(@_) {
		$DEBUG->log($target . "::$_ => $source" . "::$_\n");
		${$target . "::"}{$_} = ${$source . "::"}{$_};
	}
}

__PACKAGE__->new();

1;

package OddMuse;
use vars qw/$UTILS/;
$UTILS = new MyPlace::OddmuseMod::Utils;
1;
