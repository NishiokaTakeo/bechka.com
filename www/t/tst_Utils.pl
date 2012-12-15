use strict ;
#use utf8 ;
use lib qw(../lib) ;
use CStyle::Common;
use Test::More qw(no_plan) ;
use Data::Dumper;
use CStyle::Utils;

open STDERR ,">> $CStyle::Configration::gv_errorLogPath";

my $inc = 0;

#ceil
{
	my $res = CStyle::Utils::ceil(0) ; 
	is( $res , 0, 'ceil 0チェック' );
	my $res = CStyle::Utils::ceil(2.0) ;
	is($res , 2, 'ceil 2.0チェック' );
	my $res = CStyle::Utils::ceil(2) ;  
	is( $res , 2, 'ceil 2チェック' );
	my $res = CStyle::Utils::ceil(2.1) ;
	is( $res , 3, 'ceil 2.1チェック' );
}



#make_pager
{

	#戻る・進むページ
	my ($res,undef,undef) = CStyle::Utils::make_pager(1,10,10,10)	;
	is_deeply($res,0,'1ページしかない場合の戻る チェック' );	
	my (undef,undef,$res) = CStyle::Utils::make_pager(1,10,10,10)	;
	is_deeply($res,0,'1ページしかない場合の進む チェック' );	

	my ($res,undef,undef) = CStyle::Utils::make_pager(1,10,10,9)	;
	is_deeply($res,0,'1ページ目から戻るリンク チェック' );	
	my (undef,undef,$res) = CStyle::Utils::make_pager(1,10,10,9)	;
	is_deeply($res,2,'1ページ目から2ページ目へ進むリンク チェック' );	

	my ($res,undef,undef) = CStyle::Utils::make_pager(2,10,10,9) ;  
	is_deeply($res,1,'2ページ目から1ページへ戻るリンク チェック' );	

	my ($res,undef,undef) = CStyle::Utils::make_pager(5,10,10,2) ;
	is_deeply($res,4,'最終ページから戻るリンク チェック' );	
	my (undef,undef,$res) = CStyle::Utils::make_pager(5,10,10,2) ;
	is_deeply($res,0,'最終ページから進むリンク チェック' );	


	#次ページのリンク
	my (undef,$res,undef) = CStyle::Utils::make_pager(1,10,10,10)	;  $res = CStyle::Common->delete_utf8_flg($res);	
	is_deeply($res,[ {'クラス' => 'this','ページ' => 1} ],'1ページしかない場合のページリンク チェック' );	

	my (undef,$res,undef) = CStyle::Utils::make_pager(1,10,10,9)	;  $res = CStyle::Common->delete_utf8_flg($res);	
	is_deeply($res,[ {'クラス' => 'this','ページ' => 1},{'ページ' => 2} ],'2ページある場合で現在が1ページの場合のページリンク チェック' );	

	my (undef,$res,undef) = CStyle::Utils::make_pager(4,10,10,2)	;  $res = CStyle::Common->delete_utf8_flg($res);	
	is_deeply($res,[ {'ページ' => 1} ,{'ページ' => 2},{'ページ' => 3},{'クラス' => 'this','ページ' => 4},{'ページ' => 5}],'5ページの場合のページリンク チェック' );	

	my (undef,$res,undef) = CStyle::Utils::make_pager(5,10,10,2)	;  $res = CStyle::Common->delete_utf8_flg($res);	
	is_deeply($res,[ {'ページ' => 1} ,{'ページ' => 2},{'ページ' => 3},{'ページ' => 4},{'クラス' => 'this','ページ' => 5}],'5ページまで、現在5ページの チェック' );

	my (undef,$res,undef) = CStyle::Utils::make_pager(6,10,12,2)	;  $res = CStyle::Common->delete_utf8_flg($res);	
	is_deeply($res,[ {'ページ' => 1} ,{'ページ' => 2},{'ページ' => 3},{'ページ' => 4},{'ページ' => 5},{'クラス' => 'this','ページ' => 6}],'6ページまで、現在6ページの チェック' );

	my (undef,$res,undef) = CStyle::Utils::make_pager(6,10,26,2)	;  $res = CStyle::Common->delete_utf8_flg($res);
	is_deeply($res,[ {'ページ' => 2} ,{'ページ' => 3},{'ページ' => 4},{'ページ' => 5},{'クラス' => 'this','ページ' => 6},{'ページ' => 7},{'ページ' => 8},{'ページ' => 9},{'ページ' => 10},{'ページ' => 11}],'13ページまで、現在6ページ チェック' );

	my (undef,$res,undef) = CStyle::Utils::make_pager(7,10,26,2)	;  $res = CStyle::Common->delete_utf8_flg($res);
	is_deeply($res,[ {'ページ' => 3} ,{'ページ' => 4},{'ページ' => 5},{'ページ' => 6},{'クラス' => 'this','ページ' => 7},{'ページ' => 8},{'ページ' => 9},{'ページ' => 10},{'ページ' => 11},{'ページ' => 12}],'13ページまで、現在7ページ チェック' );

}
