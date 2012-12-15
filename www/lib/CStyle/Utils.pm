package CStyle::Utils ;

BEGIN{
eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
};
use strict;
use utf8;

sub ceil($){
  my $val = shift;
  
  $val = ($val > 0 && $val != int($val))? int($val + 1):$val;
  
  return $val;
}

=pod
引数
	$page:現在のページ
	$page_link_num:次へ、戻るリンクの数
	$maxcount:データの総数
	$limit:１画面に表示する件数
  
戻り値
	$back_page：戻るリンクのページ番号
	@pagecount：ページへのリンク情報
	$next_page：次へリンクのページ番号
=cut
sub make_pager($$$$){
	my $page = shift ;
	my $page_link_num = shift;
	my $maxcount = shift;
	my $limit = shift;
	
	my $make_page = 0 ;
	my @pagecount ;

=pod *******************************************
次へ、戻るリンクの作成
=cut *******************************************

	my $back_page = 0 ;
	my $next_page = 0 ;
	if( $page * $limit < $maxcount){

	  # 次へ、戻るリンク生成
	  if( $page <= 1 ){
		$back_page = 0 ;
		$next_page = $page + 1 ;
	  }else{
		$back_page = $page - 1 ;
		$next_page = $page + 1 ;
	  }

	}else{

	  # 戻るリンクのみ生成
	  if( $page <= 1 ){
		$back_page = 0 ;
		$next_page = 0 ;
	  }else{
		$back_page = $page - 1 ;
		$next_page = 0 ;
	  }
	}

	

=pod *******************************************
1,2.3等の次画面リンクの作成
=cut *******************************************

	my $maxpage =  CStyle::Utils::ceil($maxcount/$limit);
	#現在のページが5未満
	if( $page < ($page_link_num/2)){
	  if( $maxpage < $page_link_num){
		for(my $i = 1; $i <=$maxpage;$i++){
		  push @pagecount,{'ページ' => $i};
		}
	  }else{
		for(my $i = 1; $i <=$page_link_num;$i++){
		  push @pagecount,{'ページ' => $i};
		}
	  }
	  
	#現在のページが最後から5以上
	}elsif($page > ($maxpage - $page_link_num/2)){

		if( $maxpage - $page_link_num  <= 0){
		  for(my $i = 1; $i <= $maxpage ;$i++){
			push @pagecount,{'ページ' => $i};
		  }

		}else{
		  for(my $i = $maxpage - $page_link_num + 1; $i <=$maxpage ;$i++){
			push @pagecount,{'ページ' => $i};
		  }
		}
	#それ以外
	}else{
	  my $bk_break = $page + 1 - ($page_link_num/2) ;

	  for(my $i = $bk_break; $i < $page ;$i++){
		push @pagecount,{'ページ' => $i};
	  }

	  push @pagecount,{'ページ' => $page};

	  #次のリンク
	  my $nx_break = $page + ($page_link_num/2) ;
	  for(my $i = $page + 1; $i <= $nx_break ;$i++){
		push @pagecount,{'ページ' => $i};
	  }
	}

	#現在のページの背景を変更する
	if(ref(\@pagecount) eq 'ARRAY'){
	  for (my $i = 0 ; $i <= $#pagecount; $i++){
		if( int($pagecount[$i]->{'ページ'}) == int($page)){
		  $pagecount[$i]->{'クラス'} = 'this';
		  last;
		}
	  }
	}

  return ($back_page,\@pagecount,$next_page);
}

1;
