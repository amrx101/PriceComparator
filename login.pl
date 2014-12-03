
use strict;
use warnings;
use DBI;
1;
sub connect_db()
{
my $driver = "mysql";
my $database = "TESTDB";
my $dsn = "DBI:$driver:database=$database";
my $userid = "root";
my $password = "amit";
#print "before connect\n";
my $dbh = DBI -> connect($dsn, $userid, $password) or die "cannot connect to the database
$DBI::errstr\n";
return $dbh;
}
