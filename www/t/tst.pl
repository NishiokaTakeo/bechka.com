use strict ;
use utf8 ;
use lib qw(/var/www/cluster-style.com/domains/shippaishare.cluster-style.com/public_html/lib) ;
use CStyle::Common;
use CStyle::DBAccess;
#use Test::More qw(no_plan) ;
use Data::Dumper;

#open STDERR ,">> $CStyle::Configration::gv_errorLogPath";

my $dbh = DBI->connect(
			"DBI:Pg:dbname=".$CStyle::Configration::gv_dbname.";host=".$CStyle::Configration::gv_dbhost.";port=5432"
			,$CStyle::Configration::gv_dbuser
			,$CStyle::Configration::gv_password
			,{ RaiseError => 1 ,AutoCommit => 0}
		);

	$dbh->do("create temp table _体験 ()  inherits (体験) on commit DELETE ROWS") ;
	$dbh->do("insert into _体験 (タイトル,内容) values('たいとる3','ないよう3');") ;
	$dbh->do("insert into _体験 (タイトル,内容) values('たいとる','ないよう');") ;
	$dbh->do("insert into _体験 (タイトル,内容) values('たいとる2','ないよう2');") ;
	
	my $sth = $dbh->prepare("select * from 体験 ;");
	$sth->execute();
	while( my $data = $sth->fetchrow_hashref ){
		print Dumper($data);
	}


$dbh->commit;
$dbh->disconnect();
exit;






$CStyle::Configration::is_debug = 1 ;
  
	my $dbaccess = CStyle::DBAccess->new() ;
	$dbaccess->set_is_test(1);	
	$CStyle::Configration::DBAccess = $dbaccess;	
	$dbaccess->connect();	
	
	
#	$dbaccess->create_temp_table('__体験','体験','DELETE ROWS','');
my $inc =0;
++ $inc ;
		ok( $dbaccess->create_temp_table('__体験'.$inc,'体験','DELETE ROWS','') ,'継承指定　コミット指定 成功' ) ;
	$dbaccess->disconnect();	