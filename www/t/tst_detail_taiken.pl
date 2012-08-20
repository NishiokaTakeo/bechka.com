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

require '../detail_taiken.pl' ;

$DetailTaiken::html = 'tst_detail_taiken.html';
open STDERR ,">> $CStyle::Configration::gv_errorLogPath";

	
#必須チェック
{	
	is( DetailTaiken::main("") , 1, 'IDチェック　エラー' );
}

$dbaccess->create_temp_table('__体験','体験','DELETE ROWS','','');
$dbaccess->create_temp_table('__タグ','タグ','DELETE ROWS','','');
$dbaccess->create_temp_table('__体験rタグ','体験rタグ','DELETE ROWS','','');
$dbaccess->create_temp_table('__コメント','コメント','DELETE ROWS','','');
$dbaccess->create_temp_table('__体験アクセスログ','体験アクセスログ','DELETE ROWS','','');
		
#データなし	
{
	my $ret = DetailTaiken::main(1);
	$ret = &seikei($ret);

	my $ok_data= '<div><span>データなし</span><span>コメントがまだありません。一番乗りはどうですか？</span><span>コメントがまだありません。一番乗りはどうですか？</span></div>' ;
	utf8::encode($ok_data);
	is($ret , $ok_data,'データ０件　成功');
}

#1件
{
	$dbaccess->insert('体験','タイトル,内容',['タイトルだよ!','内容だよ?'])  || die("ERR");
	my $data = $dbaccess->select('体験','*') || die("ERR");
	my $seq = $dbaccess->currval('体験_seq') || die("ERR");
	
	$dbaccess->insert('コメント','体験id,内容,pn区分',[$seq,'ネガティブコメント','N'])  || die("ERR");
	my $seq2 = $dbaccess->currval('コメント_seq') || die("ERR");
	$dbaccess->insert('コメント','体験id,内容,pn区分',[$seq,'ポジティブコメント','P'])  || die("ERR");
	my $seq3 = $dbaccess->currval('コメント_seq') || die("ERR");

	my $ret = DetailTaiken::main($seq);

	my $data = $dbaccess->select('体験アクセスログ','体験ID,アクセス者','','order by id limit 1') || die("ERR");
	is(scalar @$data, 1,'アクセスログ　成功');
	
	$ret = &seikei($ret);
	my $ok_data = "<div><div>タイトルだよ!</div><div>内容だよ?</div><span>$seq2</span><span>ネガティブコメント</span><span>$seq3</span><span>ポジティブコメント</span></div>" ;
	utf8::encode($ok_data);
	is($ret , $ok_data,'データ1件　成功');	
		
}



sub seikei{
	my $ret = shift;

	my $sp = '　';
	utf8::encode($sp);
	
	$ret =~ s/^(\s+)//gi;
	$ret =~ s/(\s+)$//gi;
	$ret =~ s/>(\s+)</></gi;
	$ret =~ s/$sp+//gi;
	$ret =~ s/\r\n/\n/gi;
	$ret =~ s/\r/\n/gi;
	$ret =~ s/\n//gi;	
	
	return $ret ;
}
$dbaccess->disconnect;