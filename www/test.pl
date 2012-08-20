use strict ;

print "\n\n";
BEGIN{
eval("require $ENV{DOCUMENT_ROOT}include/global_const.pl;");
};
print $DOC_ROOT;
#print $ENV{DOCUMENT_ROOT} ;
#print "use lib qw('$ENV{DOCUMENT_ROOT}lib/');";
#eval ("print 'aaaaaa';");
exit;

=pod
use lib qw(/var/www/cluster-style.com/domains/shippaishare.cluster-style.com/public_html/lib) ;
use CStyle::Common;
use CStyle::DBAccess;

{'a'=>1}?print 1:print 0;
exit;
=cut

#use utf8 ;

#my $dbaccess = new CStyle::DBAccess ;
#$dbaccess->connect ;
#$dbaccess->insert('体験',['タイトル','内容','登録者'],['たいけんたいとる','ないよう','192.168.0.0']);



#use lib './lib' ;
#use Test;
#$a ++ ;
#print "\n\n $a";

#open FH , ">> //var/www/cluster-style.com/domains/shippaishare.cluster-style.com/public_html/test.log" ;
#print FH "aaaaa\n";
#close(FH) ;



=pod

use utf8;
use Encode;
my $a = "あ" ;
open FH , ">> /var/www/cluster-style.com/domains/shippaishare.cluster-style.com/public_html/test.log" ;
my $i = "a" ; 
utf8::encode($a) ;
#utf8::upgrade($i) ;
print FH "flg = " . utf8::is_utf8($a) .":::$i $a \n" ;
exit;

#フラグonの状態でフラグを立てる
print FH "flg = " . utf8::is_utf8($a) ."\n" ;
utf8::upgrade($a) ;
print FH "flg = " . utf8::is_utf8($a) ."\n" ;
print FH "てきすと1 = " . $a ."\n\n" ;

#フラグをオフの状態でフラグをオフにすふ
utf8::encode($a) ;
#$a=Eccode::encode_utf8($a) ;
print FH "flg = " . utf8::is_utf8($a) ."\n" ;
utf8::downgrade($a) ;
print FH "flg = " . utf8::is_utf8($a) ."\n" ;
my $txt = "てきすと1 = ";
utf8::encode($txt);
my $n = "\n" ;
utf8::encode($n);
print FH $txt . $a.$n ;

close(FH);
=cut
