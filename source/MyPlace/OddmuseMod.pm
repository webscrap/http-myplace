#package MyPlace::OddmuseMod;

use vars /%Action/;


if(!$Action{'showmod'}) {
	$Action{'showmod'} = sub {1;};
}
my $old = $Action{'showmod'};
$Action{'showmod'} = sub {
	print '<li>MyPlace::OddmuseMod</li>';
	&old;
}
