#!/usr/bin/perl -w
use strict;
use vars qw($RssLicense $RssCacheHours @RcDays $TempDir $LockDir $DataDir
$KeepDir $PageDir $RcOldFile $IndexFile $BannedContent $NoEditFile $BannedHosts
$ConfigFile $FullUrl $SiteName $HomePage $LogoUrl $RcDefault $RssDir
$IndentLimit $RecentTop $RecentLink $EditAllowed $UseDiff $KeepDays $KeepMajor
$EmbedWiki $BracketText $UseConfig $UseLookup $AdminPass $EditPass $NetworkFile
$BracketWiki $FreeLinks $WikiLinks $SummaryHours $FreeLinkPattern $RCName
$RunCGI $ShowEdits $LinkPattern $RssExclude $InterLinkPattern $MaxPost $UseGrep
$UrlPattern $UrlProtocols $ImageExtensions $InterSitePattern $FS $CookieName
$SiteBase $StyleSheet $NotFoundPg $FooterNote $NewText $EditNote $HttpCharset
$UserGotoBar $VisitorFile $RcFile %Smilies %SpecialDays $InterWikiMoniker
$SiteDescription $RssImageUrl $ReadMe $RssRights $BannedCanRead $SurgeProtection
$TopLinkBar $LanguageLimit $SurgeProtectionTime $SurgeProtectionViews
$DeletedPage %Languages $InterMap $ValidatorLink %LockOnCreation @CssList
$RssStyleSheet %CookieParameters @UserGotoBarPages $NewComment $HtmlHeaders
$StyleSheetPage $ConfigPage $ScriptName $CommentsPrefix @UploadTypes
$AllNetworkFiles $UsePathInfo $UploadAllowed $LastUpdate $PageCluster
%PlainTextPages $RssInterwikiTranslate $UseCache $Counter $ModuleDir
$FullUrlPattern $SummaryDefaultLength $FreeInterLinkPattern
%InvisibleCookieParameters %AdminPages $UseQuestionmark $JournalLimit
$LockExpiration $RssStrip %LockExpires @IndexOptions @Debugging $DocumentHeader
%HtmlEnvironmentContainers @MyAdminCode @MyFooters @MyInitVariables @MyMacros
@MyMaintenance @MyRules);

# Internal variables:
use vars qw(%Page %InterSite %IndexHash %Translate %OldCookie $FootnoteNumber
$OpenPageName @IndexList $Message $q $Now %RecentVisitors @HtmlStack
@HtmlAttrStack $ReplaceForm %MyInc $CollectingJournal $bol $WikiDescription
$PrintedHeader %Locks $Fragment @Blocks @Flags $Today @KnownLocks
$ModulesDescription %Action %RuleOrder %Includes %RssInterwikiTranslate);

use lib $ModuleDir;
use MyPlace::OddmuseMod;
use MyPlace::OddmuseMod::Debug;
use MyPlace::OddmuseMod::Utils;
use MyPlace::OddmuseMod::Hook;
use MyPlace::OddmuseMod::IO;
use MyPlace::OddmuseMod::PageId;
use MyPlace::OddmuseMod::Page;
use MyPlace::OddmuseMod::Data;
use MyPlace::OddmuseMod::Style;
#my $mod = new MyPlace::OddmuseMod;
$Action{'dump'} = sub {
	use Data::Dumper;
	print "<pre>\n" .  Data::Dumper->Dump([\%OddMuse::,\@_],[qw/*main *args/]),"\n</pre>\n";
}
#$mod->init(\%main::);
