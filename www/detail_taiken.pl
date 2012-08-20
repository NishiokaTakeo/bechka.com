package DetailTaiken;

BEGIN{
eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
};

use strict;
use utf8;
use CGI;
use HTML::Template ;
use CStyle::Common ;
use CStyle::Configration ;
use Data::Dumper;
use CStyle::DBAccess ;

our $html = 'detail_taiken.html' ;
my $タイトル = '失敗体験詳細｜Bechka 失敗した。を共有しよう！' ;
my $ヘッダ説明 = 'ここでは、あなたの「失敗した。」を共有することが出来ます。もしかするとあなたの体験が人の人生を変えるかもしれません。' ;
my $ヘッダキーワード = 'Bechka,失敗,体験,投稿' ;


my $param = (new CGI)->Vars;

$param=CStyle::Common->add_utf8_flg($param);

my $体験ID = $param->{'体験ID'} ;

if(@ARGV){
	$体験ID = $ARGV[0] ;
}

&main($体験ID);

sub main{
	CStyle::Common::print_log('I',"START") ;

	my $体験ID = shift ;

	if( !&check($体験ID)){
		$CStyle::Configration::is_debug ? 
			return 1 : 
			CStyle::Common->response_error_page("そのページは削除されたか存在しないページです。","error.html") ;			
		return;
	}

	my $DBA = CStyle::DBAccess->new ;
	$DBA->connect(1);

	my $data = $DBA->select('体験','*',{'id'=>$体験ID});
	my $negative_data = $DBA->select('コメント','*',{'体験id'=>$体験ID,'pn区分' => CStyle::Configration::get_negative_symbol},' order by 登録日 desc limit 10');
	my $positive_data = $DBA->select('コメント','*',{'体験id'=>$体験ID,'pn区分' => CStyle::Configration::get_positive_symbol},' order by 登録日 desc limit 10');
	
	#アクセスログ登録に失敗しても処理続行
	if(! $DBA->insert('体験アクセスログ','体験id,アクセス者',[$体験ID,$ENV{'REMOTE_ADDR'}]) ){
		$CStyle::Configration::is_debug ? 
			return 1 : 
			return undef ;	
	}
	
	#改行をBRに変換する
	for(my $i = 0 ; $i < scalar @$data; $i++){
	  my $n =  $data->[$i]->{'内容'} ;
	  $n =~ s/\n/<br \/>/gi;
	  $data->[$i]->{'内容'}= $ n;
	}

	$DBA->disconnect;

	$data=CStyle::Common->delete_utf8_flg($data) ;
	$negative_data=CStyle::Common->delete_utf8_flg($negative_data) ;
	$positive_data=CStyle::Common->delete_utf8_flg($positive_data) ;

	my $template_param=CStyle::Common->delete_utf8_flg({
		'タイトル' => $タイトル,
		'ヘッダ説明' => $ヘッダ説明,
		'ヘッダキーワード' => $ヘッダキーワード,
		'loop_taiken' => $data ,
		'loop_negative_comment' => $negative_data ,
		'loop_positive_comment' => $positive_data ,		
	}) ;
	
	my $out = CStyle::Common->template_output($template_param,$html);
	#CStyle::Common::print_log('I',"START  ".Dumper($negative_data)) ;
	CStyle::Common::PrintHeader;
	$CStyle::Configration::is_debug ? return $out : print $out ;
}

sub check($){
	CStyle::Common::print_log('I',"START") ;

	my $体験ID = shift(@_) ;

	if( !$体験ID ){
		return '' ;
	}

	return 1 ;
}
