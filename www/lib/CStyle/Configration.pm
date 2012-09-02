package CStyle::Configration ;

BEGIN{
eval("use lib qw($ENV{DOCUMENT_ROOT}lib);");
};
use strict;

##########################################################
# データ宣言
##########################################################

# DB関係
our $USER_PATH      = &get_user_path($ENV{DOCUMENT_ROOT});
our $DOCUMENT_ROOT  = $USER_PATH. '/www/' ;
our $LOGS_ROOT      = $USER_PATH. '/logs/' ;
our $DOMAIN			= $ENV{HTTP_HOST} ;
our $gv_dbname      = 'bechka' ;
our $gv_dbhost      = 'localhost' ;
our $gv_dbuser      = 'bechka' ;
our $gv_password    = 'bechpass' ;
our $template       = $DOCUMENT_ROOT . 'html' ;	
our $gv_errorLogPath	= $LOGS_ROOT . '/trace.log' ;
#our $gv_libPath 		= '/public_html/lib' ;
our $is_debug 		= '0' ;

sub get_temp_path{
	return $CStyle::Configration::template ;
}

sub get_negative_symbol{
	CStyle::Common::print_log('I',"START") ;
	return 'N' ;
}

sub get_positive_symbol{
	CStyle::Common::print_log('I',"START") ;
	return 'P' ;
}

sub get_user_path {   
    my $doc_root = shift ;

    my @dirs = split('/',$doc_root) ;
    pop(@dirs);

    return join('/',@dirs) ;
}

1;