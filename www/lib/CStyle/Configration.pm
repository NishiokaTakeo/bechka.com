package CStyle::Configration ;

BEGIN{
eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
};
use strict;
#$BEGIN{
#eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
#};use lib qw(/home/bechka/www/lib) ;

##########################################################
# データ宣言
##########################################################

# DB関係
our $gv_dbname				= 'bechka' ;
our $gv_dbhost 				= 'localhost' ;
our $gv_dbuser				= 'bechka' ;
our $gv_password			= 'bechpass' ;
our $template			= '/home/bechka/www/html' ;	
our $gv_errorLogPath 		= '/home/bechka/logs/trace.log' ;
#our $gv_libPath 		= '/public_html/lib' ;
our $is_debug 		= '0' ;
our $DBAccess;
my $Company_Address		= 'info@cluster-style.com' ;

sub get_temp_path{
	return $CStyle::Configration::template ;
}

=pod
sub New{

  my $class = shift(@_);
  
  my $self = {
		SmtpServer				=> 'localhost' ,
		CompanyAddress			=> 'info@cluster-style.com' ,
		Domain					=> 'cluster-style.com'  ,
		smtp_auth_id			=> 'nishioka@cluster-style.com'  ,
		smtp_auth_pass			=> '#Gamk3b.' ,
		_template_dir			=> '/home/cs/www/cluster-style.com/template/'
		
  };
  
  return bless $self,$class;
}
=cut
sub get_negative_symbol{
	CStyle::Common::print_log('I',"START") ;
	return 'N' ;
}

sub get_positive_symbol{
	CStyle::Common::print_log('I',"START") ;
	return 'P' ;
}

1;
