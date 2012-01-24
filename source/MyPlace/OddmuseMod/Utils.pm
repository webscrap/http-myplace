
package MyPlace::OddmuseMod::Utils;
use strict;

sub new {
	my $class = shift;
	return bless {@_},$class;
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

1;

package OddMuse;
use vars qw/$UTILS/;
$UTILS = new MyPlace::OddmuseMod::Utils;
1;
