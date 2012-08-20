package Index;

BEGIN{
eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
};

use strict;
use utf8;
use CGI;
use HTML::Template ;
#use lib qw(/home/bechka/www/lib) ;
use CStyle::Common ;
use CStyle::Configration ;
use Data::Dumper;
use CStyle::DBAccess ;

our $html = 'index.html' ;
my $タイトル = 'Bechka あなたの失敗体験を共有しよう' ;
my $ヘッダ説明 = 'Bechkaはあなたの失敗体験を他人に共有する事で成功に近づける近道をサポートします。' ;
my $ヘッダキーワード = 'Bechka,失敗,体験' ;

&main();

sub main{
	CStyle::Common::print_log('I',"START") ;

	my $DBA = CStyle::DBAccess->new ;
	$DBA->connect(1);

	my $data = $DBA->select('体験','*','','order by 登録日 desc limit 10');
	my $data2 = $DBA->select('v_人気体験','*','','limit 10');
	
	
	
	if(ref($data) eq 'ARRAY' && scalar @$data > 0){
	
		
		for(my $i = 0 ; $i < scalar @$data; $i++){
		
			#タグ名ちょっとこの辺テスト
			my $複数タグ名 = $DBA->sqlraw('select タグ名 from タグ as t inner join 体験rタグ as r on t.id = r.タグid where r.体験id = ? and  t.削除フラグ= \'f\' and r.削除フラグ = \'f\'  ',[$data->[$i]->{'id'}]);
		
		
			if( ref($複数タグ名) eq 'ARRAY' && scalar @$複数タグ名 > 0){
				my @タグ;
				for(my $j = 0 ; $j < scalar @$複数タグ名; $j++){
					push @タグ,$複数タグ名->[$j]->{'タグ名'} ;
				
				}		
				
				$data->[$i]->{'タグ'} = join(' ',@タグ) ;	
			}
			
			#コメント数を取得
			my $count = $DBA->select('コメント','count(id)',{'体験id' => $data->[$i]->{'id'} ,'pn区分' => 'P' },'');
			if( ref($count) eq 'ARRAY' && scalar @$count > 0){
				$data->[$i]->{'pコメント'} = $count->[0]->{'count'} ;
			}
			
			$count = $DBA->select('コメント','count(id)',{'体験id' => $data->[$i]->{'id'} ,'pn区分' => 'N' },'');
			if( ref($count) eq 'ARRAY' && scalar @$count > 0){
				$data->[$i]->{'nコメント'} = $count->[0]->{'count'} ;
			}			
		}
	}
	
	

	if(ref($data2) eq 'ARRAY' && scalar @$data2 > 0){
	
		
		for(my $i = 0 ; $i < scalar @$data2; $i++){
		
			#タグ名ちょっとこの辺テスト
			my $複数タグ名 = $DBA->sqlraw('select タグ名 from タグ as t inner join 体験rタグ as r on t.id = r.タグid where r.体験id = ? and  t.削除フラグ= \'f\' and r.削除フラグ = \'f\'  ',[$data2->[$i]->{'id'}]);
		
		
			if( ref($複数タグ名) eq 'ARRAY' && scalar @$複数タグ名 > 0){
				my @タグ;
				for(my $j = 0 ; $j < scalar @$複数タグ名; $j++){
					push @タグ,$複数タグ名->[$j]->{'タグ名'} ;
				
				}		
				
				$data2->[$i]->{'タグ'} = join(' ',@タグ) ;	
			}
			
			#コメント数を取得
			my $count = $DBA->select('コメント','count(id)',{'体験id' => $data2->[$i]->{'id'} ,'pn区分' => 'P' },'');
			if( ref($count) eq 'ARRAY' && scalar @$count > 0){
				$data2->[$i]->{'pコメント'} = $count->[0]->{'count'} ;
			}
			
			$count = $DBA->select('コメント','count(id)',{'体験id' => $data2->[$i]->{'id'} ,'pn区分' => 'N' },'');
			if( ref($count) eq 'ARRAY' && scalar @$count > 0){
				$data2->[$i]->{'nコメント'} = $count->[0]->{'count'} ;
			}			
		}
	}
	
	#人気タグの取得
	my $人気タグ = $DBA->select('v_人気タグ','*') ;
	if( ref($人気タグ) eq 'ARRAY' && scalar @$人気タグ > 0){
		#タグの範囲(pt)
		my @range = ('8','36') ;
			
		#最大値を取得
		my $最高値 = 0 ;
		for(my $i =0; $i < scalar @$人気タグ ; $i++){
			$最高値 = $人気タグ->[$i]->{'count'} if( $人気タグ->[$i]->{'count'} > $最高値 ) ;
		}
		CStyle::Common::print_log("I","saikou = $最高値") ;
		#タグのptを計算
		
		for(my $i =0; $i < scalar @$人気タグ ; $i++){
			my $フォントサイズ = $range[0] ;
			
			eval{
				#タグクラウドで使うフォントサイズの割合を計算
				my $ptサイズの範囲 = $range[1] - $range[0] ;
				my $人気の割合 = $人気タグ->[$i]->{'count'}/$最高値;
						CStyle::Common::print_log("I","ninki = $人気の割合") ;
				$フォントサイズ = $range[0] + int($ptサイズの範囲 * $人気の割合) ;
				CStyle::Common::print_log("I","saizu = $フォントサイズ") ;
			} ;

			#エラー時は最低サイズに設定			
			if($@){
				$フォントサイズ = $range[0] ;
			}
			
			$人気タグ->[$i]->{'font-size'} = $フォントサイズ ;
		}	
	}
	
	$DBA->disconnect;
	
	
	CStyle::Common::print_log("I",Dumper($人気タグ)) ;
	my $template_param=CStyle::Common->delete_utf8_flg({
		'タイトル' => $タイトル,
		'ヘッダ説明' => $ヘッダ説明,
		'ヘッダキーワード' => $ヘッダキーワード,
		'新着一覧'=> $data ,
		'人気一覧'=> $data2 ,
		'人気タグ一覧' => $人気タグ
	}) ;
	
	CStyle::Common::print_log("I",Dumper($template_param)) ;		
	my $out = CStyle::Common->template_output($template_param,$html);

	CStyle::Common::PrintHeader;
	$CStyle::Configration::is_debug ? return $out : print $out ;
}


