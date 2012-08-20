use strict ;
use utf8 ;
use lib qw(/var/www/cluster-style.com/domains/shippaishare.cluster-style.com/public_html/lib) ;
use CStyle::Common;
use CStyle::DBAccess;
use Test::More qw(no_plan) ;
use Data::Dumper;

open STDERR ,">> $CStyle::Configration::gv_errorLogPath";
$CStyle::Configration::is_debug = 1 ;

my $dbaccess = CStyle::DBAccess->new ;
$dbaccess->set_is_test(1);
$dbaccess->connect(1);

my $inc = 0;
#{
#my $dbaccess = CStyle::DBAccess->new(1) ;
#print "\n",$dbaccess->{'_is_test'} ,"\n";
#print "\n",$dbaccess->_get_is_test ,"\n";
#}
#exit;

#インスタンス
{
	#my $dbaccess = CStyle::DBAccess->new ;
	isa_ok($dbaccess,'CStyle::DBAccess') ;
}

#接続
{
	my $save = $CStyle::Configration::gv_dbname ;
	$CStyle::Configration::is_debug = 0 ;
	#失敗
	$CStyle::Configration::gv_dbname = "die" ;
	my $dbaccess0 = CStyle::DBAccess->new ;
	$dbaccess0->set_is_test(1);
	ok(!$dbaccess0->connect(),"connect(1) failure") ;

	#成功
	$CStyle::Configration::gv_dbname = $save ;
	my $dbaccess2 = CStyle::DBAccess->new ;
	$dbaccess2->set_is_test(1);
	ok($dbaccess2->connect(1),"connect(1) success") ;

	$dbaccess2->disconnect(1);
	$CStyle::Configration::is_debug = 0 ;	
}
 
#insert
{
	$dbaccess->create_temp_table('__体験','体験','DELETE ROWS','');

	ok( !$dbaccess->insert('','タイトル,内容',['てすとたいとる','てすとないよう']) ,'table name NG' ) ;
	ok( !$dbaccess->insert('体験','',['てすとたいとる','てすとないよう']) ,'columns NG' ) ;
	ok( !$dbaccess->insert('体験','タイトル,内容','てすとたいとる') ,'value NG' ) ;

	
	ok( !$dbaccess->insert('体験1','タイトル,内容',['てすとたいとる','てすとないよう']) ,'dbh NG' );
	#$dbaccess->commit;
	
	ok( !$dbaccess->insert('体験\'','タイトル,内容',['てすとたいとる','てすとないよう']) ,'table name quote NG' );
	ok( !$dbaccess->insert('体験','タイトル\',内容',['てすとたいとる','てすとないよう']) ,'column quote NG' );

	
	ok( $dbaccess->insert('体験','タイトル,内容',['てすとたいとる\'','てすとないよう']) ,'insert + quote OK' );
	ok( $dbaccess->insert('体験','タイトル,内容',['てすとたいとる','てすとないよう']) ,'insert OK' );
	#$dbaccess->commit;
	
	
	#my $dbaccess2 = CStyle::DBAccess->new() ;
	#$dbaccess2->set_is_test(1);
	
	#$dbaccess2->connect(1);	
	++ $inc ;
	ok(!$dbaccess->insert('体験'.$inc,'タイトル,内容',['てすとたいとる','てすとないよう']),'一次テーブル未作成の為 失敗');
	
	$dbaccess->create_temp_table('__体験'.$inc,'体験','DELETE ROWS') ;
	ok( $dbaccess->insert('体験'.$inc,'タイトル,内容',['てすとたいとる','てすとないよう']) ,'一次テーブル作成の為 成功' );
	#$dbaccess2->disconnect(1);	
}

#currval
{
	#my $dbaccess = CStyle::DBAccess->new ;
	#$dbaccess->connect(1);

	ok( !$dbaccess->currval('') ,'table name NG' ) ;

	ok( !$dbaccess->currval('aaa\'') ,'table name quote NG' ) ;

	ok( !$dbaccess->currval('体験1_seq') ,'currval exec NG' ) ;

	#$dbaccess->connect(1);
	
	$dbaccess->insert('体験','タイトル,内容',['てすとたいとる','てすとないよう']) ;
	ok( $dbaccess->currval('体験_seq') ,'currval success' ) ;

	#$dbaccess->disconnect(1);
}
#select
{
	#my $dbaccess = CStyle::DBAccess->new ;
	#$dbaccess->connect(1);
	
	ok( !$dbaccess->select('','タイトル,内容',['タイトル' => 'タイトル']) ,'table name NG' ) ;
	ok( !$dbaccess->select('体験','',['タイトル' => 'タイトル']) ,'column NG' ) ;
	ok( !$dbaccess->select('体験','タイトル,内容',['タイトル','内容']) ,'where NG' ) ;

	#$dbaccess->disconnect ;
	ok( !$dbaccess->select('体験','タイトル,内容',['タイトル' => 'タイトル']) ,'dbh NG' ) ;

	#$dbaccess->connect(1);
	ok( !$dbaccess->select('体験\'','*',['タイトル' => 'タイトル']) ,'table name quote NG' );
	ok( !$dbaccess->select('体験','\'*',['タイトル' => 'タイトル']) ,'column quote NG' );
	ok( !$dbaccess->select('体験','*',['タイト\'ル' => 'タイトル']) ,'where key quote NG' );
	ok( !$dbaccess->select('体験','*',['タイト\'ル' => 'タイトル'],'\'') ,'where key quote NG' );

	ok( !$dbaccess->select('体験1','*',['タイトル' => 'タイトル']) ,'exec NG' );

	ok( $dbaccess->select('体験','*',{'タイトル' => 'タイトル','内容' => '内容'}) ,'select *  OK' );
	ok( $dbaccess->select('体験','id,タイトル,内容,カテゴリid,登録者,登録日,削除フラグ',{'タイトル' => 'タイトル','内容' => '内容'}) ,'select column OK' );

	ok( scalar @{$dbaccess->select('体験','id,タイトル,内容,カテゴリid,登録者,登録日,削除フラグ',{'タイトル' => 'タイトルaaaa','内容' => '内容'})} <= 0 ,'select not match no data  OK' );
	ok( scalar @{$dbaccess->select('体験','id,タイトル,内容,カテゴリid,登録者,登録日,削除フラグ',{'タイトル' => 'タイトルaaaa','内容' => '内容\''})} <= 0 ,'select not match quote OK' );

	my $session = localtime ;
	$dbaccess->insert('体験','タイトル,内容',[$session,'てすとないよう']);
	my $id = $dbaccess->currval('体験_seq');
	eq_hash( $dbaccess->select('体験','id,タイトル,内容,カテゴリid,登録者,削除フラグ',{'id'=>$id,'タイトル' => $session,'内容' => 'てすとないよう','カテゴリid'=>0,'登録者'=>$ENV{'REMOTE_ADDR'},'削除フラグ'=>'f'}) ,'select hash OK' );

	eq_hash( $dbaccess->select('体験','id,タイトル,内容,カテゴリid,登録者,削除フラグ',{'id'=>$id,'タイトル' => $session,'内容' => 'てすとないよう','カテゴリid'=>0,'登録者'=>$ENV{'REMOTE_ADDR'},'削除フラグ'=>'f'}) ,'select hash OK' );

	ok( $dbaccess->select('体験','id,タイトル,内容,カテゴリid,登録者,削除フラグ',undef,'limit 1'),'select where区なし 成功' );
	
	#$dbaccess->disconnect(1);
	
	#my $dbaccess2 = CStyle::DBAccess->new() ;
	#$dbaccess2->set_is_test(1);
	
	#$dbaccess2->connect(1);	
	++$inc;
	ok( !$dbaccess->select('体験' . $inc ,'*','') ,'一次テーブル未作成の為 失敗' ) ;
	
	#$dbaccess->connect(1);	
	$dbaccess->create_temp_table('__体験'. $inc,'体験','PRESERVE ROWS');
	ok( $dbaccess->select('体験'. $inc,'*','') ,'一次テーブル作成の為 成功' ) ;
	#$dbaccess->disconnect(1);
}

#複数行
{
	$dbaccess->set_autocommit(0);
	$dbaccess->insert('体験','タイトル,内容',['たいとる1','ないよう1']) || print "ERR1\n";
	$dbaccess->insert('体験','タイトル,内容',['たいとる2','ないよう2'])  || print "ERR2\n";
	$dbaccess->insert('体験','タイトル,内容',['たいとる3','ないよう3'])  || print "ERR3\n";
	my $data = $dbaccess->select('体験','タイトル,内容','') ;
	
	my $okdata1 = {'タイトル' =>'たいとる1' , '内容' =>'ないよう1'};
	#print "\n",Dumper($data->[0]),"\n";
	#print "\n",Dumper($okdata1),"\n";
	#exit;
	is_deeply($data->[0],{'タイトル' =>'たいとる1' , '内容' =>'ないよう1'},'複数select　1件目成功');
	is_deeply($data->[1],{'タイトル' =>'たいとる2' , '内容' =>'ないよう2'},'複数select　2件目成功');
	is_deeply($data->[2],{'タイトル' =>'たいとる3' , '内容' =>'ないよう3'},'複数select　3件目成功');
	
	#print Dumper($data);
	$dbaccess->commit;
	$dbaccess->set_autocommit(1);
}

#create temp table
{
	#my $dbaccess = CStyle::DBAccess->new ;
	#$dbaccess->connect(1);

	ok( !$dbaccess->create_temp_table('','体験','','') ,'テーブル名空白' ) ;
	ok( !$dbaccess->create_temp_table('__体験','','','') ,'継承名空白' ) ;

	ok( !$dbaccess->create_temp_table('体験','','','','') ,'テーブル命名エラー' ) ;

	ok( !$dbaccess->create_temp_table('__体験','','','',['aaaaa']) ,'列名指定' ) ;

	ok( !$dbaccess->create_temp_table('__体験\'','','','','') ,'テーブル名エスケープ' ) ;
	ok( !$dbaccess->create_temp_table('__体験','','','\'','') ,'継承　エスケープ' ) ;
	ok( !$dbaccess->create_temp_table('__体験','','','','\'') ,'コミット　エスケープ' ) ;
	
	ok( !$dbaccess->create_temp_table('__体験','体験1','','','') ,'継承元存在無 失敗' ) ;
	
	#$dbaccess->connect(1);
	++$inc ;
	ok( $dbaccess->create_temp_table('__体験'.$inc,'体験','','') ,'継承指定 成功' ) ;
	++$inc ;
	ok( $dbaccess->create_temp_table('__体験'.$inc,'体験','DELETE ROWS','') ,'継承指定　コミット指定 成功' ) ;
	
	#$dbaccess->disconnect ;
	
	#my $dbaccess2 = CStyle::DBAccess->new() ;
	#$dbaccess2->set_is_test(1);
	#$dbaccess2->connect(1);	
	++ $inc ;
	$dbaccess->create_temp_table('__体験'.$inc,'体験','PRESERVE ROWS');
	ok( $dbaccess->select('体験'.$inc,'*','') ,'一時テーブルに読み込み　成功' ) ;
}



#sqlraw
{
	$dbaccess->commit;
	$dbaccess->set_autocommit(0);
	
	$dbaccess->insert('体験','タイトル,内容',['てすとたいとる','てすとないよう']) ;
	$dbaccess->insert('体験','タイトル,内容',['てすとたいとる1','てすとないよう1']) ;	
	$dbaccess->insert('体験','タイトル,内容',['てすとたいとる2','てすとないよう2']) ;	
	$dbaccess->insert('体験','タイトル,内容',['てす4とたいとる3','てすとないよう3']) ;	
	
	#sqlrawの場合はそのままのselect文になる為
	ok( !$dbaccess->sqlraw('',['る1','てす4']) ,'SQL文なし エラー' ) ;
	ok( !$dbaccess->sqlraw('select * from __体験','') ,'パラメータ無し エラー' ) ; # パラメータ無しはselectメソッドを使え
	
	my $bk = $dbaccess->_get_dbh;
	$dbaccess->_set_dbh('') ;
	ok(!$dbaccess->sqlraw('select * from __体験 where 1 = %s ',['1']),'dbh無し エラー' );
	$dbaccess->_set_dbh($bk) ;
	
	my $ok = [{'タイトル' => 'てすとたいとる2'}] ;
	my $res = $dbaccess->sqlraw("select タイトル from __体験 where タイトル like ?",['%とる2%']) ;
	is_deeply($res,$ok,'select取得　成功' );
	
	my $ok2 = [{'タイトル' => 'てすとたいとる2'},{'タイトル' => 'てす4とたいとる3'}] ;#配列の順番が変わるとエラーになるから注意
	my $res2 = $dbaccess->sqlraw("select タイトル from __体験 where タイトル like ? or 内容 like ?",['%とる2%','%よう3%']) ;
	is_deeply($res2,$ok2,'select 複数条件 取得　成功' );	
}

$dbaccess->disconnect(1);	
