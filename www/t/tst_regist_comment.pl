use strict ;
use utf8 ;
use lib qw(../lib) ;
use CStyle::Common;
use CStyle::Configration;
use CStyle::DBAccess;
use Test::More qw(no_plan) ;
use FindBin;
use Data::Dumper;
use DBI;

$CStyle::Configration::is_debug = 1 ;

my $dbaccess = new CStyle::DBAccess() ;
$dbaccess->set_is_test(1);
$dbaccess->connect;

require '../regist_comment.pl' ;

open STDERR ,">> $CStyle::Configration::gv_errorLogPath";


$dbaccess->create_temp_table('__体験','体験','DELETE ROWS','','');
$dbaccess->create_temp_table('__コメント','コメント','DELETE ROWS','','');

$dbaccess->insert("体験","タイトル,内容",["たいと","ないよう"]) ;
my $curval=$dbaccess->currval("体験_seq") ;

#必須チェック
{	
	is( RegistComment::main("",'N','コメント') , 1, 'ID必須チェック　エラー' );
	is( RegistComment::main($curval,'','コメント') , 1, 'コメント種別　必須チェック　エラー' );
	is( RegistComment::main($curval,'N','') , 1, 'コメント　必須チェック　エラー' );
	
	
	
}

#存在idチェック
{
	is( RegistComment::main($curval+1,'N','コメント') , 2, '存在しないID　エラー' );
}

#コメント種別チェック
{	
	is( RegistComment::main($curval,'NN','こめんと') , 3, '存在しないコメント種別　エラー' );
}


#データ登録チェック
{
	RegistComment::main($curval,'N','こめんと') ;
	my $curval2=$dbaccess->currval("コメント_seq") ;
	my $data = $dbaccess->select("コメント",'体験id,内容,pn区分,登録者',{'id'=> $curval2 ,'体験id' => $curval} );
	is_deeply($data->[0],{ '体験id' => $curval , '内容' => 'こめんと', 'pn区分' => 'N','登録者' => ''},'コメント登録　成功') ;
}

$dbaccess->disconnect;