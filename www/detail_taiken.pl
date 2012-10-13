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
my $タイトル = "%s |「失敗した」を共有するBechka" ;
my $ヘッダ説明 = '%s・・・' ;
my $ヘッダキーワード = '%s,失敗共有,Bechka' ;


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

	#タグ名ちょっとこの辺テスト
	my $複数タグ名 = $DBA->sqlraw('select タグ名 from タグ as t inner join 体験rタグ as r on t.id = r.タグid where r.体験id = ? and  t.削除フラグ= \'f\' and r.削除フラグ = \'f\'  ',[$data->[0]->{'id'}]);
	my @タグ;
	if( ref($複数タグ名) eq 'ARRAY' && scalar @$複数タグ名 > 0){
		for(my $j = 0 ; $j < scalar @$複数タグ名; $j++){
			push @タグ,$複数タグ名->[$j]->{'タグ名'} ;
		}
		#$data2->[$i]->{'タグ'} = join(',',@タグ) ;
	}
	
	#head情報を設定
	$タイトル = sprintf($タイトル, $data->[0]->{'タイトル'} ) ;
	$ヘッダ説明 = sprintf($ヘッダ説明 , substr($data->[0]->{'内容'}, 0, 50) );
	$ヘッダ説明 =~ s/<br \/>//gi;
	$ヘッダキーワード =sprintf($ヘッダキーワード, join(',',@タグ));
	
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
