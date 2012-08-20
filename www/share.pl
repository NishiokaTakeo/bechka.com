package Share;

BEGIN{
eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
};

use strict;
use utf8;
use CGI;
use CStyle::Common ;
use CStyle::Configration ;
our $html = 'share.html' ;

my $タイトル = '共有する｜Bechka 失敗した。を共有しよう！' ;
my $ヘッダ説明 = 'Bechkaはあなたの失敗体験を他人に共有する事で成功に近づける近道をサポートします。' ;
my $ヘッダキーワード = 'Bechka,失敗,体験' ;


#use CStyle::DBAccess ;
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


