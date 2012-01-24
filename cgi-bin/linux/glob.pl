#!/usr/bin/perl
print "Content-type: text/plain; charset=iso-8859-1\n\n";
if($ENV{PATH_INFO}) {
        print $ENV{PATH_INFO},"\n";
	print join("\n",glob($ENV{PATH_INFO} . "/*"));
}
else {
        print "*.pl\n";
	print join("\n",glob("*.pl"));
}


