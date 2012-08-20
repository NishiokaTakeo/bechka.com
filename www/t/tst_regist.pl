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


require '../regist.pl' ;

open STDERR ,">> $CStyle::Configration::gv_errorLogPath";

#必須チェック
{

	is( &main("","内容２","たぐぅ") , 1, 'タイトル必須チェック失敗' );

	is( &main("たいとる２","","たぐぅ") , 1, '内容必須チェック失敗' );

	is( &main("たいとる２","内容２","") , 1, 'タグ必須チェック失敗' );

}

$dbaccess->create_temp_table('__体験','体験','DELETE ROWS','','');
$dbaccess->create_temp_table('__タグ','タグ','DELETE ROWS','','');
$dbaccess->create_temp_table('__体験rタグ','体験rタグ','DELETE ROWS','','');

#単数タグ
{

	ok(!&main("たいとる２","内容２","たぐぅ"),"単数　タグ　登録OK") ;
	my $data = $dbaccess->select('体験','id,タイトル,内容','','') ;
	my $ok_data={'id' => $data->[0]->{'id'} ,'タイトル' => 'たいとる２','内容' => '内容２'} ;
	#print Dumper($data);#print Dumper($ok_data);
	is_deeply( $data->[0] , $ok_data,"体験データ登録　成功");

	my $data2 = $dbaccess->select('タグ','id,タグ名','','') ;
	my $ok_data2 = {'id'	=> $data2->[0]->{'id'} ,'タグ名' => 'たぐぅ'} ;
	#print Dumper($data2); print Dumper($ok_data2);
	is_deeply( $data2->[0] , $ok_data2,"タグデータ登録　成功");

	my $data3 = $dbaccess->select('体験rタグ','体験id,タグid','','') ;
	my $ok_data3={'体験id'	=> $data->[0]->{'id'} ,'タグid'	=> $data2->[0]->{'id'} } ;
	#print Dumper($data3); print Dumper($ok_data3);
	is_deeply( $data3->[0] , $ok_data3,"体験rタグ 登録　成功");
}

$dbaccess->commit;

#複数タグのテストを追加
{

	ok(!&main("たいとる２","内容２","たぐぅ たぐぅ１　たぐぅ２  　たぐぅ３　 　たぐぅ４　"),"複数タグ　登録OK") ;
	my $data = $dbaccess->select('体験','id,タイトル,内容','','') ;

	is_deeply(
		 $data->[0] , {
			'id' => $data->[0]->{'id'}
			,'タイトル' => 'たいとる２'
			,'内容' => '内容２'
		}
	,"体験テーブル　体験データ　成功") ;

	my $data2 = $dbaccess->select('タグ','id,タグ名','','') ;

	is_deeply(
		$data2->[0] , {
			'id'	=> $data2->[0]->{'id'}
			,'タグ名' => 'たぐぅ'
		}
	,"タグテーブル 複数タグ登録　1件目　成功");

	is_deeply(
		$data2->[1] , {
			'id'	=> $data2->[1]->{'id'}
			,'タグ名' => 'たぐぅ１'
		}
	,"タグテーブル 複数タグ登録　２件目　成功");

	is_deeply(
		$data2->[2] , {
			'id'	=> $data2->[2]->{'id'}
			,'タグ名' => 'たぐぅ２'
		}
	,"タグテーブル 複数タグ登録　３件目　成功");

	is_deeply(
		$data2->[3] , {
			'id'	=> $data2->[3]->{'id'}
			,'タグ名' => 'たぐぅ３'
		}
	,"タグテーブル 複数タグ登録　４件目　成功");

	is_deeply(
		$data2->[4] , {
			'id'	=> $data2->[4]->{'id'}
			,'タグ名' => 'たぐぅ４'
		}
	,"タグテーブル 複数タグ登録　５件目　成功");

}
$dbaccess->commit;
$dbaccess->disconnect;