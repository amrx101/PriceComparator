
# ..................Questions 8:3 A.............................
#
#
# ..............................................................
use warnings;
use DBI;
my $driver = "mysql";
my $database = "TESTDB";
my $dsn = "DBI:$driver:database=$database";
my $userid = "root";
my $password = "amit";
my $dbh = DBI -> connect($dsn, $userid, $password) or die "cannot connect to the database $DBI::errstr\n";
# connect to the database
my $qterm = <STDIN>;
chomp($qterm);
sub getfrombook()
{
my ($dbh, $qterm) = (@_);
my $sth = $dbh->prepare("SELECT Title , Price , Domain FROM BOOK WHERE Author REGEXP ?");
$sth -> execute($qterm) or die "cannot execute select $DBI::errstr\n";
my $str = "";
$x = '<br>';
my @list;
my @fk_list;
my @ib_list;
my $str_fk = "";
my $str_ib = "";
my $index_fk = 1;
my $index_ib = 1;
while (my @row = $sth -> fetchrow_array())
{
my($title, $price, $domain) = @row;
if($domain =~m/www\.flipkart\.com/)
{
$str_fk = $str_fk."Result no: ".$index_fk;
$str_fk = $str_fk.$x."Title : ".$title.$x."Price : ".$price.$x.$x;
$index_fk++;
}
if($domain =~m/www\.infibeam\.com/)
{
$str_ib = $str_ib ."Result no ".$index_ib;
$str_ib = $str_ib.$x."Title : ".$title.$x."Price : ".$price.$x.$x;
$index_ib++;
}
}
push(@list,$str_fk);
push(@list,$str_ib);
$sth->finish();
return @list;
}
1;
