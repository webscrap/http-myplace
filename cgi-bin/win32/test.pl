#!p:\program\perl\5.8.9\bin\MSWin32-x86-multi-thread\perl.exe
##
##  test
##
use CGI;
use Data::Dumper;
use CGI::Util qw/unescape/;


my $q = new CGI();
$q->charset("utf8");
$q->escape(0);
print $q->header;
print $q->Dump;
print "<pre>\n",Dumper($q),"\n</pre>\n";
print "<pre>\n",Dumper(\%ENV),"\n</pre>\n";
print "<pre>\n";
print "\tURL = ",unescape($q->url()),"\n";
print "\tPathInfo = ", $q->path_info(),"\n";
print "\tPATH_URL = ",unescape($q->url(-path=>1)),"\n";
print "\tRelURL = ", unescape($q->url(-relative=>1)),"\n";
print "\tABS_URL = ", unescape($q->url(-absolute=>1)),"\n";
print "\tQuery = ", unescape($q->url(-query_string=>1)),"n";
print "</pre>\n";
print $q->end_html;
1;

