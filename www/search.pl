package Search;

BEGIN{
eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
};
use strict;
use utf8;
use CGI;
use HTML::Template ;
#use lib qw(/var/www/cluster-style.com/domains/shippaishare.cluster-style.com/public_html/lib) ;
use CStyle::Common ;
use CStyle::Configration ;
use Data::Dumper;
use CStyle::DBAccess ;

our $html = 'search.html' ;
my $タイトル = '検索結果｜Bechka 失敗した。を共有しよう！' ;
my $ヘッダ説明 = 'あなたの知りたい他人の失敗体験がここにあります。様々なキーワードからあなたの知りたい「失敗した。」を探すことが出来ます。' ;
my $ヘッダキーワード = 'Bechka,失敗,体験' ;


my $param = (new CGI)->Vars;

$param=CStyle::Common->add_utf8_flg($param);

my $キーワード = $param->{'キーワード'} ;

if(@ARGV){
	$キーワード = $ARGV[0] ;
}

&main($キーワード);

sub main($キーワード){
	CStyle::Common::print_log('I',"START") ;
	
	my $キーワード = shift ;
	my $DBA = CStyle::DBAccess->new ;
	
	$DBA->connect(1);
	
	my $limit = '20';
	
	$キーワード =~ s/^\s+//gi;
	$キーワード =~ s/\s+$//gi;
	$キーワード =~ s/\s+/ /gi;
	my @キーワーズ = split(/\s/,$キーワード) ;
	CStyle::Common::print_log("count = ". scalar @キーワーズ );
	if( $キーワード =~ m/\s+/){
		push @キーワーズ,$キーワード;
	}
	CStyle::Common::print_log("count = ". scalar @キーワーズ );
	my @data;
	if( scalar @キーワーズ > 0 ){
		
		my @除外ID ;
		my $プレースホルダー = '' ;
		my @param ;
		foreach my $word (@キーワーズ){
			next if (!$word) ;
			$プレースホルダー .= ',?' ;
			push @param,$word ;
		}
		
		$プレースホルダー = substr($プレースホルダー,1) ;
	
		#タグから取得
		my $pre_data = $DBA->sqlraw('select 体験id,登録日 from v_体験rタグ名 where タグ名 in ('.$プレースホルダー.') group by 体験id, 登録日 order by 登録日 limit '. $limit , \@param );
		@param = () ;
		$プレースホルダー = '' ;
		
		if( ref($pre_data) eq 'ARRAY' && scalar @$pre_data > 0){
			foreach my $row (@$pre_data){
				next if (!$row) ;
				$プレースホルダー .= ',?' ;
				push @param ,$row->{'体験id'} ;
				push @除外ID ,$row->{'体験id'} ;
			}
			$pre_data = undef ;
			$プレースホルダー = substr($プレースホルダー,1) ;
			
			my $pre_data = $DBA->sqlraw('select * from 体験 where id in ('. $プレースホルダー .')' , \@param );
			
			#表示内容に格納し、共通変数を初期化
			foreach my $row (@$pre_data){
				push @data,$row;
			}
			
			$プレースホルダー = '' ;
			@param = () ;
		}
		
		$pre_data = undef;
					
		#表示件数に満たない場合は「タイトル」とマッチする体験を取得
		my $表示に満たない数 = $limit - (scalar @data) ;
		if( $表示に満たない数 > 0 ){
			
			foreach my $タグ (@キーワーズ){
				next if (!$タグ) ;
				$プレースホルダー .= 'or タイトル like ? ' ; 
					CStyle::Common::print_log('\%'.$タグ.'\%');
				push @param , '%'.$タグ.'%';
			}
			
			my $除外IDのSQL = '' ;
			if( scalar @除外ID > 0){
				my $id = $除外ID[0];
				$除外IDのSQL = 'and not id in (' .$id ;
				foreach my $id (@除外ID){
					$除外IDのSQL .= ',' . $id ;
				}
				$除外IDのSQL .= ') ' ;
			}
			
			$プレースホルダー = substr($プレースホルダー,2) ;
			
			my $pre_data = $DBA->sqlraw('select * from 体験 where '. $プレースホルダー .' ' . $除外IDのSQL . ' limit '. $表示に満たない数 ,\@param );	

			#表示内容に格納し、共通変数を初期化
			foreach my $row (@$pre_data){
				push @data,$row;
				push @除外ID ,$row->{'id'} ;
			}
			$pre_data = undef;
			$プレースホルダー = '' ;
			@param = () ;
			
			#再計算し、表示件数に満たない場合は「内容」とマッチする体験を取得
			$表示に満たない数 = $limit - (scalar @data) ;
			if( $表示に満たない数 > 0 ){
			
				foreach my $タグ (@キーワーズ){
					$プレースホルダー .= 'or 内容 like ? ' ; 
				push @param , '%'.$タグ.'%';
				}

				my $除外IDのSQL = '' ;
				if( scalar @除外ID > 0){
					my $id = $除外ID[0];
					$除外IDのSQL = 'and not id in (' .$id ;
					foreach my $id (@除外ID){
						$除外IDのSQL .= ',' . $id ;
					}
					$除外IDのSQL .= ') ' ;
				}
			
				$プレースホルダー = substr($プレースホルダー,2) ;

				my $pre_data = $DBA->sqlraw('select * from 体験 where '. $プレースホルダー .' ' . $除外IDのSQL . ' limit '. $表示に満たない数 ,\@param );	

				foreach my $row (@$pre_data){
					push @data,$row;
				}
				
				#それでも足らない場合はあきらめる
			}
		}
		
	}else{
	
		my $pre = $DBA->select('体験','*','','order by 登録日 desc limit ' . $limit);
		@data = @$pre;
	}
	
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
		'検索一覧'=> \@data 
	}) ;
	
	CStyle::Common::print_log("hit".scalar @data.":::" . Dumper(@data));	
	my $out = CStyle::Common->template_output($template_param,$html);

	CStyle::Common::PrintHeader;
	$CStyle::Configration::is_debug ? return $out : print $out ;
}
