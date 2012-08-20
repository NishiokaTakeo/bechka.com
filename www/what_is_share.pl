package WhatIsShare;

BEGIN{
eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
};

use strict;
use utf8;
use CGI;
use CStyle::Common ;
use CStyle::Configration ;

my $タイトル = '私たちについて｜Bechka 失敗した。を共有しよう！' ;
my $ヘッダ説明 = '「失敗した。」を共有するBechka。私たちBechkaの活動を知ってください。' ;
my $ヘッダキーワード = 'Bechka,失敗,体験' ;


our $html = 'what_is_share.html' ;
#
&main();

sub main{
	CStyle::Common::print_log('I',"START") ;

	#my $DBA = CStyle::DBAccess->new ;
	#$DBA->connect(1);
	#$DBA->disconnect();
	my $template_param=CStyle::Common->delete_utf8_flg({
		'タイトル' => $タイトル,
		'ヘッダ説明' => $ヘッダ説明,
		'ヘッダキーワード' => $ヘッダキーワード,
	}) ;
	
	my $out = CStyle::Common->template_output($template_param,$html);

	CStyle::Common::PrintHeader;
	$CStyle::Configration::is_debug ? return $out : print $out ;
}


