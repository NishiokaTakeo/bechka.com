package AccessRankList;

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
use CStyle::Utils;

our $html = 'access_rank_list.html' ;
my $タイトル = '新着一覧｜Bechka 失敗した。を共有しよう！' ;
my $ヘッダ説明 = 'あなたの知りたい他人の失敗体験がここにあります。様々なキーワードからあなたの知りたい「失敗した。」を探すことが出来ます。' ;
my $ヘッダキーワード = 'Bechka,失敗,体験' ;

&main();

sub main(){
	CStyle::Common::print_log('I',"START") ;
	
	my $param = (new CGI)->Vars;
	$param=CStyle::Common->add_utf8_flg($param);

	my $DBA = CStyle::DBAccess->new ;
	
	$DBA->connect(1);
	
	my $limit = 20;
	my $page_limit = 10 ;
	
	#体験最大件数を取得
	my $count = $DBA->select('v_人気体験','count(id)',undef,undef) || 0;
	my $maxcount = 0 ;
	if( ref($count) eq 'ARRAY' && scalar @$count > 0){
		$maxcount = $count->[0]->{'count'} ;
	}

	#現在のページを取得
	my $page = $param->{'page'} || 1;
		
	#ページリンク作成
	my ($back_link,$page_link,$next_link) = CStyle::Utils::make_pager($page,$page_limit,$maxcount,$limit);

	#取得するデータのオフセットを算出
	my $offset = 0;
	if( $page <= 0 ){
	  $offset = 0;
	}else{
	  $offset = ( $page -1 ) * $limit ;
	}
	
	# 体験を取得 offset limit 
	my $predata = $DBA->select('v_人気体験','*','','offset ' . $offset . ' limit ' . $limit);

	my @data = @$predata;
	if( scalar @data > 0 ){

		for(my $i = 0 ; $i < scalar @data; $i++){

			#タグ名ちょっとこの辺テスト
			my $複数タグ名 = $DBA->sqlraw('select タグ名 from タグ as t inner join 体験rタグ as r on t.id = r.タグid where r.体験id = ? and  t.削除フラグ= \'f\' and r.削除フラグ = \'f\'  ',[$data[$i]->{'id'}]);


			if( ref($複数タグ名) eq 'ARRAY' && scalar @$複数タグ名 > 0){
				my @タグ;
				for(my $j = 0 ; $j < scalar @$複数タグ名; $j++){
					push @タグ,$複数タグ名->[$j]->{'タグ名'} ;

				}

				$data[$i]->{'タグ'} = join(' ',@タグ) ;
			}

			#コメント数を取得
			my $count = $DBA->select('コメント','count(id)',{'体験id' => $data[$i]->{'id'} ,'pn区分' => 'P' },'');
			if( ref($count) eq 'ARRAY' && scalar @$count > 0){
				$data[$i]->{'pコメント'} = $count->[0]->{'count'} ;
			}

			$count = $DBA->select('コメント','count(id)',{'体験id' => $data[$i]->{'id'} ,'pn区分' => 'N' },'');
			if( ref($count) eq 'ARRAY' && scalar @$count > 0){
				$data[$i]->{'nコメント'} = $count->[0]->{'count'} ;
			}
		}
	}
	$DBA->disconnect;
	
	my $template_param=CStyle::Common->delete_utf8_flg({
		'タイトル' => $タイトル,
		'ヘッダ説明' => $ヘッダ説明,
		'ヘッダキーワード' => $ヘッダキーワード,	
		'検索一覧'=> \@data ,
		'戻るページ' => $back_link ,
		'次のページ' => $next_link ,
		'ページ一覧' => $page_link
	}) ;
	
	#CStyle::Common::print_log("hit".scalar @data.":::" . Dumper(@data));	
	my $out = CStyle::Common->template_output($template_param,$html);

	CStyle::Common::PrintHeader;
	$CStyle::Configration::is_debug ? return $out : print $out ;
}
