package CStyle::Common ;

BEGIN{
eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
};
use strict;
#use lib qw(/home/bechka/www/lib) ;
use CStyle::Configration ;
use Date::Calc qw(:all) ;
use DBI ;
use utf8;
use HTML::Template ;

##########################################################
# データ宣言
##########################################################

##########################################################
# サブルーチン
##########################################################

#####################################
# ヘッダーを出力
# なし
# なし
sub PrintHeader{
	CStyle::Common::print_log('I',"START") ;
	
	return if ( $CStyle::Configration::is_debug ) ;
	print "Content-Type: text/html; Charset=UTF-8\n\n" ;
}

sub print($){
	my $val = shift ;
	
	if ( $CStyle::Configration::is_debug ) {
		return $val ;
	}else{
		print $val ;
	}
}

#####################################
# データベースに接続
# なし
# データベースハンドル
sub DBConnect{
	return DBI->connect("DBI:Pg:dbname=".$CStyle::Configration::gv_dbname.";host=".$CStyle::Configration::gv_dbhost.";port=5432",$CStyle::Configration::gv_dbuser,$CStyle::Configration::gv_password,{ RaiseError => 1 ,AutoCommit => 0}) || CStyle::Common::OutPutLog('CStyle::Configration->DBConnect\t'.$DBI::errstr);
	
}

#####################################
# ログを出力
# ログ出力テキスト
# なし
=pod
sub OutPutLog{
# パラメータ
#my $pvi_self 			= shift(@_) ;
my $pvi_errortext 	= shift(@_) ;

# データ宣言
my $lvi_now = &GetDay ;

utf8::encode($pvi_errortext) if( utf8::is_utf8($pvi_errortext)) ;

# ログ出力
open(OUT,">> ".$CStyle::Configration::gv_errorLogPath);
print OUT $lvi_now."\t";
print OUT $pvi_errortext. "\n";
close(OUT);
}
=cut

sub GetDay{
	# パラメータ
	my $lvi_now = '' ;
	
	# データ宣言
	$lvi_now = sprintf("%04d-%02d-%02d %02d:%02d:%02d",Today_and_Now()) ;
	
	return $lvi_now ;
}

#####################################
# dnsシリアル値を取得
# なし
# シリアル値
sub GetSerial{
	my @lai_localtime = () ;
	my $lvi_serial		= '' ;
	
	@lai_localtime = localtime() ;
	$lvi_serial = sprintf("%04d%02d%02d%02d",$lai_localtime[5] + 1900 , $lai_localtime[4] + 1 , $lai_localtime[3] , $lai_localtime[2]) ;
	return $lvi_serial ;
}	

#####################################
# システムエラー
# ログ内容
# なし
sub print_log{

	# パラメータ
	my $status = shift ;
	my $errortext = shift ;
	my $arg = shift ;
	
	if ( $CStyle::Configration::is_debug && $status eq 'E' ) {
		#return ;
	}
	
	# データ宣言
	my $lvi_now = &GetDay ;
	my @caller = caller(1) ;
	
	utf8::encode($status) if( utf8::is_utf8($status));
	utf8::encode($errortext)  if( utf8::is_utf8($errortext));
	utf8::encode($arg) if( utf8::is_utf8($arg));
	 
	# ログ出力
	open(OUT,">> ".$CStyle::Configration::gv_errorLogPath);
	print OUT $lvi_now."\t";
	print OUT $status . "\t";
	print OUT $caller[3]. "\t" ;
	print OUT $errortext. "\t";
	print OUT $arg  . "\n";
	close(OUT);
	
	return 1;
}

#-------------------------------------------------------------------------#
# sql禁止文字の置き換え
# 引数 ： 変換文字列
# 戻り値 : String
#-------------------------------------------------------------------------#
sub escape($$){
	
	my $class	= shift(@_) ;
	my $val		= shift(@_) ;
	
	$val =~ s/\\/\\\\/g;
	$val =~ s/&/&amp;/g; # &
	$val =~ s/\"/&quot;/g; #"
	$val =~ s/\'/&#39;/g; # '
	$val =~ s/</&lt;/g; # <
	$val =~ s/>/&gt;/g; # >

	return($val);

}

#-------------------------------------------------------------------------#
# sql禁止文字の置き換えの逆変換
# 引数 ： 変換文字列
# 戻り値 : String
#-------------------------------------------------------------------------#
sub rvs_escape($$){
	my $class	= shift(@_) ;
	my $val		= shift(@_) ;
	
	$val =~ s/&amp;/&/g; # &
	$val =~ s/&quot;/\"/g; #"
	$val =~ s/&#39;/\'/g; # '
	$val =~ s/&lt;/</g; # <
	$val =~ s/&gt;/>/g; # >

	return($val);

}

#-------------------------------------------------------------------------#
# sql禁止文字の置き換えの逆変換
# 引数 ： 変換文字列
# 戻り値 : String
#-------------------------------------------------------------------------#
sub get_cnt_string($$){
	my $class	= shift(@_) ;
	my $val		= shift(@_) ;
	
	my $cnt_moji = 0 ;	
	my $zenkaku = $val;	
	
	$zenkaku =~ s/[a-z0-9]//gi ;
	$cnt_moji = length($val) - length($zenkaku);
	$cnt_moji = $cnt_moji + (length($zenkaku) / 3) ;
	
	return($cnt_moji);
}

sub add_utf8_flg($){
	my $this = shift;
	my $val = shift;
	
	CStyle::Common::print_log('I',"START") ;
	
	#CStyle::Common::print_log('I',"REF ",ref($val)) ;
	
	if(ref($val) eq ''){
		utf8::decode($val) ;
		#CStyle::Common::print_log('I',"ADD FLG :".utf8::is_utf8($val),$val) ;
		return $val ;
		
	}elsif(ref($val) eq 'ARRAY'){
	
		for(my $i = 0; $i < scalar @$val;$i++){
			#if( ref($val->[$i]) eq 'ARRAY'){
#				$val->[$i] = CStyle::Common->add_utf8_flg($val->[$i]);
				#next;
			#}elsif(ref($val->[$i]) eq 'HASH'){
#				$val->[$i] = CStyle::Common->add_utf8_flg($val->[$i]);
				#next;
			#}
			my $v = $val->[$i] ;
			$val->[$i] = CStyle::Common->add_utf8_flg($v);
			#utf8::decode($val->[$i]) ;
			#CStyle::Common::print_log('I',"ADD FLG :".utf8::is_utf8($val->[$i]),$val->[$i]) ;
		}
		return $val ;
		
	}elsif(ref($val) eq 'HASH'){
		my %new = () ;
		my @keys = keys(%$val) ;
		
		foreach my $key (@keys){
			#if( ref($val->{$key}) eq 'ARRAY'){
#				$val->{$key} = CStyle::Common->add_utf8_flg($val->{$key});
				#next;
			#}elsif(ref($val->{$key}) eq 'HASH'){
#				$val->{$key} = CStyle::Common->add_utf8_flg($val->{$key});
				#next;
			#}

			my $v = $val->{$key} ;
			$v = CStyle::Common->add_utf8_flg($v);
			#utf8::decode($v) ;
			
			#CStyle::Common::print_log('I',"ADD FLG :".utf8::is_utf8($v),$v) ;
			$key = CStyle::Common->add_utf8_flg($key);
			#utf8::decode($key) ;
			#CStyle::Common::print_log('I',"ADD FLG :".utf8::is_utf8($key),$key) ;
			$new{$key} = $v;
		}
		
		return \%new;
	
	}
	
	return undef ;
}

sub delete_utf8_flg($){
	my $this = shift;
	my $val = shift;
	
	CStyle::Common::print_log('I',"START") ;
	#CStyle::Common::print_log('I',"REF ",ref($val)) ;
	if(ref($val) eq ''){
		utf8::encode($val) if utf8::is_utf8($val) ;
		#CStyle::Common::print_log('I',"DELL FLG ",$val) ;
		return $val ;
		
	}elsif(ref($val) eq 'ARRAY'){
	
		for(my $i = 0; $i < scalar @$val;$i++){
			#if( ref($val->[$i]) eq 'ARRAY' || ref($val->[$i]) eq 'HASH' ){
				#$val->[$i] = CStyle::Common->delete_utf8_flg($val->[$i]);
				#next;
			#}
			my $v = $val->[$i] ;
			$v = CStyle::Common->delete_utf8_flg($v);
			$val->[$i] = $v;
			#utf8::encode($val->[$i]) if utf8::is_utf8($val->[$i]) ;
			
			#CStyle::Common::print_log('I',"DELL FLG ",$val->[$i]) ;
		}
		return $val ;
		
	}elsif(ref($val) eq 'HASH'){
		my %new = () ;
		my @keys = keys(%$val) ;
		
		foreach my $key (@keys){
				
			#if( ref($val->{$key}) eq 'ARRAY' || ref($val->{$key}) eq 'HASH'){
				#$val->{$key} = CStyle::Common->delete_utf8_flg($val->{$key});
				#next;
			#}
		
			my $v = $val->{$key} ;
			$v = CStyle::Common->delete_utf8_flg($v) ;
			
			#utf8::encode($v) if utf8::is_utf8($v) ;
			
			#CStyle::Common::print_log('I',"DELL FLG ",$v) ;
			#utf8::encode($key) if utf8::is_utf8($key) ;
			#CStyle::Common::print_log('I',"DELL FLG ",$key) ;
			#$new{$key} = $v ;
			$key = CStyle::Common->delete_utf8_flg($key) ;
			$new{$key} = $v ;
		}
		
		return \%new;
	
	}
	
	return undef ;
}


sub template_output{
	CStyle::Common::print_log('I',"START") ;
		
	my $this = shift;
	my $param = shift;
	my $html = shift;
	
	my $Template = HTML::Template->new(	'filename' => $html ,
																	'path' => [CStyle::Configration::get_temp_path] ,
																	'die_on_bad_params' => 0,
																	'loop_context_vars' => 1,
																	'global_vars' => 1 ,
																	);

	$Template->param( $param ) ;
	
	my $out = $Template->output;
	
	return $out;
	
}

sub response_error_page{
	CStyle::Common::print_log('I',"START") ;
	
	my $this = shift;
	my $message = shift ;
	my $html = shift;
	
	my $out = CStyle::Common->template_output({'message' => $message},$html) ;

	#CStyle::Common::PrintHeader;
	return $out ;
}

sub valid_comment_type{
	my $this = shift ;
	my $コメント種別 = shift;
	
	if( $コメント種別 eq CStyle::Configration::get_negative_symbol || $コメント種別 eq CStyle::Configration::get_positive_symbol ){
		return 1;
	}else{
		return undef;
	}
}

1;
