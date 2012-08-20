package ErrorPage;

BEGIN{
eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
};
use strict ;
use utf8 ;
#use lib qw(/var/www/cluster-style.com/domains/shippaishare.cluster-style.com/public_html/lib) ;
use CStyle::Common;
use CGI ;
my $CGI = new CGI ;
my $html = 'error_page.html';
my $タイトル = 'ごめんなさい。｜Bechka 失敗した。を共有しよう！' ;
my $ヘッダ説明 = '重要なメッセージがあります。Bechkaはあなたの失敗体験を他人に共有する事で成功に近づける近道をサポートします。' ;
my $ヘッダキーワード = 'Bechka,失敗,体験' ;


my $param = $CGI->Vars;

$param=CStyle::Common->add_utf8_flg($param);

my $message = $param->{"メッセージ"} ;

if(@ARGV){
	$message = $ARGV[0] ;
}

&main($message);


#
#概要：エラーメッセージを表示させる画面を表示
#リターンパラメータ（エラー時は0以上）
sub main($){
	CStyle::Common::print_log('I',"START") ;
	
	my $message		=shift;

	CStyle::Common->PrintHeader ;
	
	my $out = CStyle::Common->response_error_page($message,$html) ;
		
	$out=CStyle::Common->delete_utf8_flg($out) ;
	
	$CStyle::Configration::is_debug ? return $out : print $out ;
}


1;
