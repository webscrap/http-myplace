#package MyPlace::OddmuseMod::Style;

use vars qw/$ModulesDescription %Action $Message @MyRules %RuleOrder $OpenPageName %Action $q $ImageExtensions $AllNetworkFiles $ModuleDir $ModuleXRZUtils/;
use File::Spec::Functions;
use File::Basename;
use File::Glob qw/:glob/;

$ModulesDescription .= '<p>$Id: zimstyle.pl,v 0.1 2009/08/21 00:55:26 as Exp $</p>';

#do "$ModuleDir/xrzutils.pl" unless($ModuleXRZUtils);

$AllNetworkFiles = 1;

push(@MyRules, \&ZimSupportRule);
push(@MyRules, \&PreMarkdownRule);
#push(@MyRules, \&PostMarkdownRule);
$RuleOrder{\&ZimSupportRule} = -99;
$RuleOrder{\&PreMarkdownRule}  = +9999999;
#$RuleOrder{\&PostMarkdownRule} = -9999999;

$blosxom::version = 1;
do "$ModuleDir/Markdown/Markdown.pl";

my $markdowned;

*OldApplyRules = *ApplyRules;
*ApplyRules = *ApplyMarkdownRule;

sub PreMarkdownRule {
    if (m/\G(.*?<code>[^<>]+<\/code>)/cg) {
        return $1;
    }
    elsif(m/\G(.*?<a\s+[^<]+<\/a>)/cg) {
        return $1;
    }
    elsif(m/\G(.*?<img\s+[^<>]+>)/cg) {
        return $1;
    }
    return undef;
}
sub PostMarkdownRule {
    if(m/\G(.*?)(?:<br>){2,}/cg) {
        return $1;
    }
    elsif(m/\G(.*?)(?:&lt;br&gt;){2,}/cg) {
        return $1;
    }
    return undef;
}
sub ApplyMarkdownRule {
    my $text = shift;

    $text =~ s/_/\\_/g;
    $text = Markdown::Markdown(UnquoteHtml($text));
    $text =~ s/\>\n+/>/g;
    return OldApplyRules($text,@_);
}

$Action{source} = \&DoSource;

sub DoSource {
  my $id = shift;
  my $text = ReadFile(GetPageFile($id));
  print GetHttpHeader('text/plain');
  print $text;
  return;
}
sub _GetDirectory {
	my (undef,$p) = fileparse(GetPageFile(@_));
	return $p;
}

sub GetLocalUrl {
    my ($path,$text,$force_img) = @_;
    return GetUrl($ZimRootUrl . $path,$text,0,1) unless($AllNetworkFiles);
    if ($path =~ /\.$ImageExtensions$/i) {
        return $q->img({-src=>'file://' . $PageDir . $path, -alt=>$text});#, -class=>'url file'})
    } else {
        return $q->a({-href=>'file://' . $PageDir . $path, -class=>'url file'}, $text);
    }
}

sub ZimLocalUrl {
    my $id = shift;
    my $p = "/$OpenPageName";
#    $p =~ s/[\:\/\\][^\:\/\\]+$//; 
    $id =~ s/:/\//g;
    $p =~ s/:/\//g;
    return GetUrl($ZimRootUrl . File::Spec->catfile($p,$id),"",0,1);
}

sub ZimLocalExp {
    my $arg = shift;
    my ($exp,$cond1,$cond2,$cond3,$cond4) = split(/\s*,\s*/,$arg);
    my $result = '';
    if($cond4) {
        $cond1 = 1 unless($cond1);
        $cond2 = 1 unless($cond2);
        $cond3 = "0$cond3" if($cond3);
        foreach my $i ($cond1 .. $cond2) {
            $result .= '<li>' . ZimLocalUrl(sprintf('%s%' . $cond3 . 'd%s',$exp || "",$i,$cond4 || "")) . '</li>';
        }
    }
    else {
        my $p = _GetDirectory($OpenPageName);
        my $pnl = length($p);
        my $pl = length($PageDir);
        my $exp = File::Spec->rel2abs($exp,$p);
      #  $result = '<span>' . $exp . '</span>';
		my @directory;
		my @files;
		my $dirname = basename($p);
        foreach(bsd_glob($exp)) {
       #     $result .='<span>' . $_ . '</span>';
            next if(m/(?:^\.+|\/\.+)$/);
            if($cond1) {
                if($cond1 eq '-d') {
                    next unless(-d $_);
                }
                elsif($cond1 eq '-f') {
                    next unless(-f $_);
                }
            }
            next if($cond2 && ! m/$cond2/);
            next if($cond3 && m/$cond3/);
			my $safename = $_;
			#$safename =~ s/ /%20/g;
            if( -d $_ ) {
				push @directories,$safename;
            }
			elsif(/([^\/]+)\.txt$/) {
				if($1 and ($dirname eq $1 || 'content' eq $1)) {
					next;
				}
				push @txts,$safename;
			}
            else {
				push @files,$safename;
            }
		}
		
		foreach(@directories) {
            my $page_name = substr($_,$pl);
            my $text = $page_name;
			$text =~ s/(?:\/+$|^.*\/+)//;
            $page_name =~ s/\//:/g;
            $page_name =~ s/(?:^\:+|\:+$)//;
            $result .= '<li>' . GetPageOrEditLink($page_name,$text,0,0) . '</li>'; 
		}
		foreach(@txts) {
            my $page_name = substr($_,$pl);
			$page_name =~ s/\//:/g;
            $page_name =~ s/(?:^\:+|\:+$)//g;
            my $text = $page_name;
			$text =~ s/.*://;
			$result .= '<li>' . GetPageOrEditLink($page_name,"&lt;$text&gt;",0,0) . '<li>';
		}
		foreach(@files) {
            my $page_name = substr($_,$pl);
            my $text = $page_name;
			$text =~ s/(?:\/+$|^.*\/+)//;
            $result .= '<li>' . GetLocalUrl($page_name,$text,($cond1 && $cond1 eq '-img') ? 1:undef) . '</li>';
		}
    }
    return undef unless($result);
    return '<ol>' . $result . '</ol>';
}

sub ZimSupportRule {
    if (m/\G<\/?code>/cg) {
        return undef;
    }
    elsif (m/\G(\[\[\s*(\.|\:)?([^ \t\[\]\|]+[^\|\[\]]+)\s*(\|\s*([^\]\[]+))?\s*\]\])/cg) {
        Dirty($1);
        my $pos = $2;
        my $page_name = $3;
        my $link_text = $5 || NormalToFree($page_name);
        my $prefix = "";
        if($pos eq '.' ) {
            $prefix = $OpenPageName . ":";
        }
        elsif($pos eq ':') {
            $prefix = "";
        }
        else {
            $prefix = $OpenPageName;
            $prefix =~ s/[^:]+$//;
        }
        $page_name = $prefix . $page_name;
        print GetPageOrEditLink($page_name, $link_text, 0, 0);
        return '';
    }
    elsif(m/\G\[localexp\:\s*([^\]\[]+)\s*\]/cg) {
        return ZimLocalExp($1);
    }
    elsif(m/\G\[local\:([^\s\]\[]*[^\[\]]+)\]/cg) {
        return ZimLocalUrl($1);

    }
    elsif (m/\G(\{\{\s*(\.|\:)?([^ \t\[\]\{\}\|]+[^\|\[\]\{\}]+)\s*(\|\s*([^\{\}\]\[]+))?\s*\}\})/cg) {
        my $pos = $2;
        my $page_name = $3;
        my $link_text = $5 || NormalToFree($page_name);
        my $prefix = "";
        if($pos eq '.' ) {
            $prefix = $OpenPageName;
            $prefix =~ s/[^:]+$//;
        }
        elsif($pos eq ':') {
            $prefix = "";
        }
        else {
            $prefix = $OpenPageName . ":";
        }
        $page_name = $prefix . $page_name;
        $page_name =~ s/[\:\/]+/\//g;
        $url = $ZimRootUrl . "/$page_name";
        return GetUrl($url,$link_text,0,1);
    }
    elsif(m/\G======\s*([^\n]+)\s*======\s*\n/cg) {
        return $q->span({-class=>'post_title'},$1) . $q->br();
    }
    elsif(m/\G((?:Created|Updated)\s+[^\n]+)\n/cg) {
        return $q->span({-class=>'footer'}, $1) . $q->br();
    }
    
=comment

    elsif(m/\G\/\/([^\n\/]+)\/\//cg) {
        return $q->i($1);
    }
    elsif(m/\G__([^\n]+)__/cg) {
        return $q->u($1);
    }
    elsif (m/\G\n\s*\n/cg) {
        return $q->br() . $q->br();
    }
    elsif (m/\G\s*\n/cg) {
        return $q->br();
    }
    
=cut

    else {
        return undef;
    }

}
1;
