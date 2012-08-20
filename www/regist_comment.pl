package RegistComment;

BEGIN{
eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
};
use strict;
use utf8;
use CGI;
#use lib qw(/var/www/cluster-style.com/domains/shippaishare.cluster-style.com/public_html/lib) ;
use CStyle::Common ;
use CStyle::Configration ;
use Data::Dumper;
use CStyle::DBAccess ;
CStyle::Common::print_log('I','START') ;

our $html = 'detail_taiken.html' ;
my $タイトル = '共有する｜Bechka 失敗した。を共有しよう！' ;
my $ヘッダ説明 = 'Bechkaはあなたの失敗体験を他人に共有する事で成功に近づける近道をサポートします。' ;
my $ヘッダキーワード = 'Bechka,失敗,体験' ;


my $param = (new CGI)->Vars;

$param=CStyle::Common->add_utf8_flg($param);

my $comment = $param->{'comment'} ;
my $type = $param->{'type'} ;
my $id = $param->{'id'} ;

if(@ARGV){
	$id = $ARGV[0] ;
	$type = $ARGV[1] ;
	$comment = $ARGV[2] ;
}

CStyle::Common::print_log('I',$id) ;
CStyle::Common::print_log('I',$type) ;
CStyle::Common::print_log('I',$comment) ;
&main($id,$type,$comment);

sub main{
	CStyle::Common::print_log('I',"START") ;

	my $体験ID = shift ;
	my $コメント種別 = shift ;
	my $コメント = shift ;
	
	CStyle::Common::PrintHeader;	
	
	if( !&check($体験ID,$コメント種別,$コメント)){
		$CStyle::Configration::is_debug ? 
			return 1 : 
			print 1;
			#CStyle::Common->response_error_page("そのページは削除されたか存在しないページです。","error_page.html") ;			
		return;
	}

	my $DBA = CStyle::DBAccess->new ;
	$DBA->connect(1);

	my $data = $DBA->select('体験','*',{'id'=>$体験ID});
	if( !$data || scalar @$data <= 0 ){
		$CStyle::Configration::is_debug ? 
			return 2 :
			print 2;
			#CStyle::Common->response_error_page("そのページは削除されたか存在しないページです。","error_page.html") ;	
			
		return;
	}

	if( !CStyle::Common->valid_comment_type($コメント種別) ){
		$CStyle::Configration::is_debug ? 
			return 3 :
			print 3;
			#CStyle::Common->response_error_page("そのページは削除されたか存在しないページです。","error_page.html") ;		
		return;
	}
	
	$DBA->insert('コメント','体験id,内容,pn区分,登録者',[$体験ID,$コメント,$コメント種別, $ENV{'REMOTE_ADDR'}]);
	
	$DBA->disconnect;

	$data=CStyle::Common->delete_utf8_flg($data) ;
	

	$CStyle::Configration::is_debug ? return '' : print '' ;	
}

sub check($){
	CStyle::Common::print_log('I',"START") ;

	my $体験ID = shift(@_) ;
	my $コメント種別 = shift(@_) ;
	my $コメント = shift(@_) ;

	
	if( !$体験ID || !$コメント種別 || !$コメント ){
		return '' ;
	}

	return 1 ;
}
