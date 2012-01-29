#!/usr/bin/perl -w
package MyPlace::OddmuseMod::Action;
use strict;

use MyPlace::OddmuseMod::Debug;
use MyPlace::OddmuseMod::Utils;
my $DEBUG = new MyPlace::OddmuseMod::Debug;
my $UTILS = new MyPlace::OddmuseMod::Utils;


use vars qw/$q $OpenPageName/;
$UTILS->importSymbol(
	__PACKAGE__,"OddMuse",
	qw/
		q
		OpenPageName
		GetPageFile
		GetPageDir
	/,
);

sub DoListDirectory {
	my $id = shift;
	print $q->p(&GetPageDir($id));
}

$OddMuse::Action{'listdir'} = \&DoListDirectory;

