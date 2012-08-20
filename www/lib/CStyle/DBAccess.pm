package CStyle::DBAccess ;

BEGIN{
eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
};
use strict;
#use lib qw(/home/bechka/www/lib) ;
use utf8;
use DBI ;
use CStyle::Configration ;
use CStyle::Common;
use Data::Dumper;
##########################################################
# コンストラクタ
##########################################################
sub new{
	CStyle::Common::print_log('I',"START") ;
		
	my $class 		= shift(@_) ;
	
	if( $CStyle::Configration::is_debug && ref($CStyle::Configration::DBAccess) eq 'CStyle::DBAccess' ){
		return $CStyle::Configration::DBAccess;
	}	
	my $self = {
		'_dbh' => '',
		'_is_test' => ''		
	};
	return bless $self,$class;
}
##########################################################
# メソッド
##########################################################
sub connect{
	CStyle::Common::print_log('I',"START") ;
	
	my $this = shift;
	my $autocommit = shift ;

	my $dbh = undef ;
	
	return 1 if($this->_get_dbh) ;
	
	if($autocommit){$autocommit=1;}else{$autocommit=0;}
	
	eval{
		$dbh = DBI->connect(
			"DBI:Pg:dbname=".$CStyle::Configration::gv_dbname.";host=".$CStyle::Configration::gv_dbhost.";port=5432"
			,$CStyle::Configration::gv_dbuser
			,$CStyle::Configration::gv_password
			,{ RaiseError => 1 ,AutoCommit => $autocommit}
		);
	};
	if( $@){
		CStyle::Common::print_log('E',$@);
		return undef;
	}
	$this->_set_dbh($dbh) ;
	return 1 ;
}
sub disconnect{
	my $this = shift;
	my $dbh = $this->_get_dbh;
	
	if( $CStyle::Configration::is_debug && ref($CStyle::Configration::DBAccess) eq 'CStyle::DBAccess' ){
		return ;
	}
	
	if( $dbh) {
		$dbh->disconnect;
	}
	
	return 1 ;
}
sub commit{
	my $this = shift ;
	my $dbh = $this->_get_dbh;
	return $dbh->commit;
	#return 1;
}

sub rollback{
	my $this = shift ;
	my $dbh = $this->_get_dbh;
	
	return $dbh->rollback;
}
sub set_autocommit($$){
	my $this = shift ;
	my $flg = shift;
	
	my $dbh = $this->_get_dbh;
	$dbh->{'AutoCommit'} = $flg;
}

sub begin_work{
	my $this = shift ;
	my $dbh = $this->_get_dbh;
	
	return $dbh->begin_work;
}
sub set_is_test{
	my $this = shift;
	$this->{'_is_test'} = shift ;
	$CStyle::Configration::DBAccess = $this;
	return 1;
}

sub _get_is_test{
	my $this = shift;
	return $this->{'_is_test'} ;
}

sub _set_dbh($$){
	my $this = shift ;
	my $dbh = shift;
	
	$this->{'_dbh'} = $dbh ;
}

sub _get_dbh{
	my $this = shift ;
	
	return $this->{'_dbh'} ;
}

sub insert($$$$){
	CStyle::Common::print_log('I',"START") ;
	
	my $this		= shift(@_) ;
	my $tblname	= shift(@_) ;
	my $columns	=shift(@_) ;
	my $values	= shift(@_) ;
	#check type
	if( ref($this) eq '' || $tblname eq '' || $columns eq '' || ref($values) ne 'ARRAY' ){
		CStyle::Common::print_log('E',"argment error","\$this=$this,\$tblname=$tblname,\$columns=$columns,\$values=$values") ;
		return undef ;
	}
	my $dbh = $this->_get_dbh;
	if( ref($dbh) eq '' ){
		CStyle::Common::print_log('E',"null error") ;
		return undef ;
	}
	#check atack
	if( $this->has_quote_val($tblname) ){
		CStyle::Common::print_log('E',"is query is atack",$tblname) ;
		return undef ;
	}
	if( $this->has_quote_val($columns) ){
		CStyle::Common::print_log('E',"is query is atack",$columns) ;
		return undef ;
	}
	#quote
	for ( my $i = 0; $i < scalar @$values ; $i ++){ 
		$values->[$i] = '' if($values->[$i] eq undef) ;
		$values->[$i] = $dbh->quote($values->[$i]) ;
	}
	my $value = join(',', @$values) ;
	if( $this->_get_is_test){
		$tblname = '__' .$tblname ;
	}
	
	my $sql = sprintf( "insert into %s ( %s ) values (%s) ;" , $tblname,$columns , $value) ;
	utf8::encode($sql) if( utf8::is_utf8($sql)) ;
	CStyle::Common::print_log('I',$sql);
	
	#my $sth = $dbh->prepare($sql) ;
		
	# exec sql
	eval{
		$dbh->do($sql) ;
		#$sth->execute;
	};		

	# 例外発生時取得
	if($@){
		CStyle::Common::print_log('E',$sql,$@);
		#$dbh->rollback ;
		#$dbh->disconnect ;
		return undef ;
	}else{
#		$dbh->commit ;
		return 1 ;
	}
}
sub currval($$){
	CStyle::Common::print_log('I',"START") ;
	my $this = shift ;
	my $tblname = shift ;
	if( ref($this) eq '' || $tblname eq ''){
		CStyle::Common::print_log('E',"argment error","\$this=$this,\$tblname=$tblname") ;
		return undef ;
	}
	my $dbh = $this->_get_dbh ;
	if( length($tblname) + 2 < length($dbh->quote($tblname))){
		CStyle::Common::print_log('E',"is query is atack",$tblname) ;
		return undef ;
	}
	$tblname = $dbh->quote($tblname) ;
	my $sql = sprintf( "SELECT currval(%s)" , $tblname) ;
	utf8::encode($sql)  if( utf8::is_utf8($sql)) ;;
	CStyle::Common::print_log('I',$sql) ;
	my $sth = $dbh->prepare($sql) ;
	my $currval = 0 ;
	# sql実行
	eval{
		$sth->execute() ;
	};
	# 例外発生時取得
	if($@){
		CStyle::Common->print_log('E',$sql,$@);
		$sth->finish;
		#$dbh->rollback ;
		#$dbh->disconnect ;
		return undef ;
	}else{
		#$dbh->commit;
		$currval = $sth->fetchrow_array;
		$sth->finish;
		#CStyle::Common::print_log('I',"currval",$currval) ;
		if( $currval == 0){
			return 1 ;
		}
	}
	return $currval;
}



sub sqlraw{
	CStyle::Common::print_log('I',"START") ;
	
	my $this = shift ;
	my $sql = shift ;
	my $param = shift ;
		
	#check param
	if( ref($this) eq '' || $sql eq '' ||  ref($param) ne 'ARRAY'){
		CStyle::Common::print_log('E',"argment error","\$this=$this,\$sql=$sql,\$param=$param") ;
		return undef ;
	}
	
	my $dbh = $this->_get_dbh;
	if( ref($dbh) eq '' ){
		CStyle::Common::print_log('E',"null error") ;
		return undef ;
	}
	
	#quote and check atack
	#my @_param ;
	#if(scalar @$param > 0){
		#foreach my $row (@$param){
			#$row = '' if( $row eq undef ) ;
			#push @_param ,$dbh->quote($row) ;
		#}
	#}
		
	utf8::encode($sql)  if( utf8::is_utf8($sql)) ;
	CStyle::Common->delete_utf8_flg($param);
	
	my $sth = $dbh->prepare($sql) ;
	CStyle::Common::print_log('I',Dumper($param));
	CStyle::Common::print_log('I',$sql );
	
		
	# sql実行
	my @res  ;
	eval{
		$sth->execute(@$param) ;
	} ;
	# 例外発生時取得
	if($@){
		CStyle::Common->print_log('E',$sql,$@);
		return undef ;
	}else{
		#$dbh->commit ;
		my $count = $sth->rows;
		if( $count <= 0 ){
			return \@res;
		}
		 
		while( my $ret = $sth->fetchrow_hashref){
			push(@res,$ret) ;
		}

		CStyle::Common->add_utf8_flg(\@res);
		 
	}
	return \@res;
}

sub select{
	CStyle::Common::print_log('I',"START") ;
	
	my $this = shift ;
	my $tblname = shift ;
	my $columns = shift ;
	my $wheres = shift ;
	my $option = shift ;
	
	#check param
	if( ref($this) eq '' || $tblname eq '' || $columns eq '' || ( $wheres && ref($wheres) ne 'HASH')){
		CStyle::Common::print_log('E',"argment error","\$this=$this,\$tblname=$tblname,\$columns=$columns") ;
		return undef ;
	}
	
	my $dbh = $this->_get_dbh;
	if( ref($dbh) eq '' ){
		CStyle::Common::print_log('E',"null error") ;
		return undef ;
	}
	#check atack
	if( $this->has_quote_val($tblname) ){
		CStyle::Common::print_log('E',"is query is atack",join(',',@$tblname)) ;
		return undef ;
	}
	if( $this->has_quote_val($columns) ){
		CStyle::Common::print_log('E',"is query is atack",$columns) ;
		return undef ;
	}
	my @keys  ;
	if(ref($wheres) eq 'HASH'){
		@keys = keys(%$wheres) ;
		if( $this->has_quote_val(\@keys) ){
			CStyle::Common::print_log('E',"is query is atack",join(',',@keys)) ;
			return undef ;
		}
	}
	if( $this->has_quote_val($option)){
		CStyle::Common::print_log('E',"is query is atack",$option) ;
		return undef ;	
	}
	#quote and check atack
	my $where = ' 1=1 ' ;
	if(scalar @keys > 0){
		foreach my $key (@keys){
			$wheres->{$key} = '' if( $wheres->{$key} eq undef) ;
			$where .= sprintf(' and %s = %s',$key, $dbh->quote($wheres->{$key}) ) ;
		}
	}

	if( $this->_get_is_test){
		$tblname = '__' .$tblname ;
	}
	
	#my $column = join(' , ', @$columns) ;
	my $sql = sprintf( "select %s from %s where %s and 削除フラグ = 'f' %s;" , $columns ,$tblname, $where,$option) ;
	utf8::encode($sql)  if( utf8::is_utf8($sql)) ;
	CStyle::Common::print_log('I',$sql );
	my $sth = $dbh->prepare($sql) ;
	# sql実行
	my @res  ;
	eval{
		$sth->execute() ;
	} ;
	# 例外発生時取得
	if($@){
		CStyle::Common->print_log('E',$sql,$@);
		#$dbh->rollback ;
		#$dbh->disconnect ;
		return undef ;
	}else{
		#$dbh->commit ;
		my $count = $sth->rows;
		if( $count <= 0 ){
			return \@res;
		}
		 
		while( my $ret = $sth->fetchrow_hashref){
			push(@res,$ret) ;
		}

		CStyle::Common->add_utf8_flg(\@res);
		 
	}
	return \@res;
}

sub create_temp_table {
	CStyle::Common::print_log('I',"START") ;
		
	my $this = shift ;
	my $tblname = shift ;
	my $inherits = shift ;
	my $on_commit = shift ;
	my $columns = shift;
	
	#check param
	if( ref($this) eq '' || $tblname eq ''  || $inherits eq ''){
		CStyle::Common::print_log('E',"argment error","\$this=$this,\$tblname=$tblname,\$inherits=$inherits") ;
		return undef ;
	}
	#check format
	unless( $tblname =~ m/^_/){
		CStyle::Common::print_log('E',"format error",$tblname , "temp table must add prefix '_' ") ;
		return undef ;	
	}
	
	#今は必要ないので、とりあえず未対応としてエラー
	if( scalar $columns > 0 ){
		CStyle::Common::print_log('E',"not support argument error","処理未対応") ;
		return undef ;		
	}
	
	my $dbh = $this->_get_dbh;
	if( ref($dbh) eq '' ){
		CStyle::Common::print_log('E',"null error") ;
		return undef ;
	}
	#check atack
	if( $this->has_quote_val($tblname) ){
		CStyle::Common::print_log('E',"is query is atack",join(',',@$tblname)) ;
		return undef ;
	}
	if( $this->has_quote_val($inherits) ){
		CStyle::Common::print_log('E',"is query is atack",$inherits) ;
		return undef ;
	}
	if( $this->has_quote_val($on_commit) ){
		CStyle::Common::print_log('E',"is query is atack",$on_commit) ;
		return undef ;
	}	

	
	my $sql = sprintf("create temp table %s ( ) ",$tblname); 
	$sql .= sprintf(" inherits (%s)",$inherits) if( $inherits) ;
	$sql .= sprintf(" on commit %s",$on_commit) if( $on_commit) ;
	
	utf8::encode($sql)  if( utf8::is_utf8($sql)) ;
	
	CStyle::Common::print_log('I',$sql );
	
	#my $sth = $dbh->prepare($sql) ;
	eval{
		$dbh->do($sql) ;
		#$sth->execute;
	};
	# 例外発生時取得
	if($@){
		CStyle::Common->print_log('E',$sql,$@);
		#$dbh->rollback ;
		#$dbh->disconnect ;
		return undef ;
	}else{
		#$dbh->commit ;
	}
	return 1;
}
sub has_quote_val{
	CStyle::Common::print_log('I',"START") ;
		
	my $this = shift ;
	my $value = shift ;
	my $dbh = $this->_get_dbh;
	
	#CStyle::Common::print_log('I',"ref =",ref($value )) ;
	if( ref($value ) eq ''){
		$value = '' if($value eq undef);
		#CStyle::Common::print_log('I','length($value) + 2 < length($dbh->quote($value))',"value = $value ,quote value = ".$dbh->quote($value)) ;
		
		if( length($value) + 2 < length($dbh->quote($value)) ){
			return 1 ;
		}else{
			return 0;
		}
	}
	if( ref($value ) eq 'ARRAY'){
		#CStyle::Common::print_log('I','length(join(\'\',@$value)) + 2 < length($dbh->quote(join(\'\',@$value)))',"value = ".join('',@$value)." ,quote value = ".$dbh->quote(join('',@$value))) ;
		if( length(join('',@$value)) + 2 < length($dbh->quote(join('',@$value)))){
			return 1 ;
		}else{
			return 0;
		}
	}
}
1;
