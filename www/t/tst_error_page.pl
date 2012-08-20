use strict ;
use utf8 ;
use lib qw(../lib) ;
use CStyle::Common;
use CStyle::Configration;
use Test::More qw(no_plan) ;

$CStyle::Configration::is_debug = 1 ;

require '../error_page.pl' ;

$ErrorPage::html = 'tst_error_page.html';
open STDERR ,">> $CStyle::Configration::gv_errorLogPath";

#必須チェック
{	
	my $ok1= "メッセージ" ;
	my $ok2= "" ;
	utf8::encode($ok1);	
	utf8::encode($ok2);
	is(ErrorPage::main("メッセージ"),$ok1,'メッセージ表示　成功') ;
	
	is(ErrorPage::main(""),$ok2,'空メッセージ表示　成功') ;
}

