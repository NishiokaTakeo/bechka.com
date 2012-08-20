#package Regist;
BEGIN{
eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
};

use strict ;
use utf8 ;
#use lib qw(/var/www/cluster-style.com/domains/shippaishare.cluster-style.com/public_html/lib) ;
use CStyle::Common;
use CGI ;
#use Data::Dumper ;
use CStyle::DBAccess ;

my $CGI = new CGI ;
my $DBA = CStyle::DBAccess->new ;

my $param = $CGI->Vars;

$param=CStyle::Common->add_utf8_flg($param);

my $title = $param->{"タイトル"} ;
my $naiyou = $param->{"内容"} ;
my $tag = $param->{"タグ"} ;

if(@ARGV){
	$title = $ARGV[0] ;
	$naiyou = $ARGV[1] ;
	$tag = $ARGV[2] ;
}

&main($title,$naiyou,$tag);


#
#
#リターンパラメータ（エラー時は0以上）
sub main($$$){
	CStyle::Common::print_log('I',"START") ;
	
	my $title		=shift;
	my $naiyou	=shift;
	my $tag		=shift;
	
	CStyle::Common->PrintHeader ;

	if(! &check($title , $naiyou, $tag)  ){
	
		$CStyle::Configration::is_debug ? return 1 : print 1 ;
		return ; 
	}

	$DBA->connect(1);
	
	$DBA->insert('体験','タイトル,内容,登録者',[$title,$naiyou,$ENV{'REMOTE_ADDR'}]) ;

	my $taiken_id = $DBA->currval('体験_seq') ;

	$tag =~ s/\s+/ /gi;

	my @tags = split(/\s/,$tag) ;

	while( ( my $t = shift(@tags) )){

		my $select = $DBA->select('タグ','id',{'タグ名' => $t });
		$select = $select->[0];
		my $tag_id;
		if(ref($select) eq 'HASH'){
			$tag_id = $select->{'id'} ;
		}

			unless( $tag_id > 0 ){
				$DBA->insert('タグ','タグ名',[$t]);
				$tag_id = $DBA->currval('タグ_seq') ;
			}

			$DBA->insert('体験rタグ','体験id,タグid',[$taiken_id,$tag_id]);
	}

	$CStyle::Configration::is_debug ? return "" : print "" ;
}

sub check($$$){
	CStyle::Common::print_log('I',"START") ;
		
	my $title = shift(@_) ;
	my $naiyou = shift(@_) ;
	my $tag = shift(@_) ;

	if( !$title  || !$naiyou || !$tag ){
		return '' ;
	}

	return 1 ;
}

1;
