Project Report On
Web Price Comparator
By :
Amit Kumar
Btech 2011-2015
NIIT UNIVERSITY
Acknowledgement
This project would not have been completed without the
guidance and suggestions of S. Swami Sir . I am thankful to
Swami Sir to guide me through the entire process.
I would also like to thank my friends especially Venkatesh
Mohta, Aniruddh Changanni , Anmol Porwal and Rohit Kumar
Singh for providing suggestions and feedbacks .
Problem Description:
While purchasing books online everyone wants the bestdeal
for him /her . So one ends up manually comparing the price
of same title on different e-commerce website. The Web
Price Comparator provides the customer with a platform
where they can type in the title of the book and the
comparator displays the price and all other relevant data
from different e – commerce website on a single webpage .
The user can then make his/her decision on comparing the
price. The present version displays prices from 2 websites but
the project is scalable .
The Working :
The Web Price Comparator consists of the following :
1. Screen Scrapper
2. Database Handler
3. User Interface
The Screen Scrapper collects data of the book from the
websites. The data collected is inserted in a database.
The User Interface is a simple HTML page with a form where
the user types in the partial or the complete name of the
author .
The Database Handler takes in the name filled by the user in
the HTML page and uses it as a search key in the database .
The results obtained by the search query in the database is
displayed in the webpage in tabular form where each table is
assigned to a particular e-marketing website.
Learnt About :
1.
2.
3.
4.
5.
6.
Screen Scrapping Techniques
Checksums
Using regex in Mysql qeries
Techniques to avoid redundancy while scrapping
Using CPAN modules.
Web politeness
My Efforts :
The crux of the application is the regular expression used to
extract data from different websites. So the creation of
regular expression was a crucial part.
The project consists of four perl files :
1.
2.
3.
4.
pro_ver3.pl
new.pl
fpro1.pl
login.pl
Pro_ver3.pl is responsible for screen scrapping of the data,
creation of database and the insertion of the data in the
database.
Fpro1.pl is responsible for the user interface. It also takes in
the author name typed in by the end user and uses it as
argument and call methods that searches the database .
Login.pl and new.pl are files responsible for the access and
search in the database once the user submits an author.
Pro_ver3.pl (script)
use strict;
use warnings;
use autodie;
use WWW::Mechanize;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use DBI;
use File::ReadBackwards;
#........................................................................................
#.............................FLIPKART HASH .............................................
our %fkart = ('title' => 'itemprop="name">\n+\s+(.*?)<','price' =>'itemprop="price"\scontent="([0-9]+)','auth'
=>"<a\\shref='\/author\/.+?'>(.+?)<");
#........................................................................................
#.............................INFIBEAM HASH..............................................
our %infibeam = ('title' =>'<h1\sclass="fn"\stitle="(.+?)"','price' =>
"id=.marketplaceStartPrice.\\sname=.+?\\svalue='(.+?)'\\s",'price1' =>"id=.infiPrice.\\s(.+?)>(.+?)<",'auth' =>
'<h2\sclass="simple"><a\shref=".+?">(.+?)<');
# ......................FLIPKART..............................
# this should be in hash/file /list called flipkart
# ............................................................
# .................Array of String ............................
my $seed_flipkart_link ="http://www.flipkart.com/books/pr?q=computer+science&as=on&as-
show=on&otracker=start&sid=bks&as-pos=1_1_ic";
my $domain = "www.flipkart.com";
my $link_regex = 'lu\-title\-wrapper">\n+\s+<a\shref="(\/.+?)\&ref=';
my $seed_regex = 'next"\shref="(\/.+?)"';
my $identifier = 0;
# ................................................................
# ..........................INFIBEAM.......................
my $seed_IB_link ="http://www.infibeam.com/Books/search?q=ComputerScience&page=1";
my $IB_domain = "www.infibeam.com";
my $IB_lnk_reg = '<h2\sclass="simple"><a\shref="(.+?)"';
my $IB_seed_reg ='';
my $IB_identifier = 1;
# ...................................................................................
# new and better implementation of extract link
# uses checksum MD5 to decide whether the link
# has already been parsed or not , better performances
# but cannot guarantee 100% redundancy elimination
sub better_extract_link()
{
open (my $fh,">>verify.txt");
# the inputs to function are entire html file , link extraction regex , the domain name and the identifier
my($src, $regex, $descrp,$identifier,$db_handler) = (@_); # get all the arguments of the function
open (my $FH, ">>md5.txt") or die "cannot open the md5 file \n"; # open md5 checksum file
while($src=~m/$regex/g)
# while there are links in the html file
{
my $str = "http://".$descrp.$1;
# link extracted
my $md5_str = md5_base64($str); # link checksum string
# decide if the extracted link is new
# encrypted checksum is used against a list of
# already encrypted checksum
if(`grep "$md5_str" 'md5.txt'`)
{
# if link has already been visited ,
# then nothing needs to be done
print "link already visited\n"; # print statement temporary , will not be there in the
final version
# of the application along with this very comment
}
else
{
# means link has not been visited
# add checksum string to log file
# call data extraction method
print $FH $md5_str."\n";
print "no match $md5_str\n";
print $fh $str;
&get_content_string($str, $identifier, $db_handler);
}
}
close($fh);
close($FH);
}
# drive_extract_link is the caller
# to extract_link , takes in all 5 parameters of data
# and creates n array of links and then stores those links in file
sub drive_extract_link()
{
my $num =0;
my @arr_links;
my ($file_handle, $param1, $param2, $param3,$param4,$param5,$db_handler) = (@_);
my $num_pag = 2;
print $file_handle $param1."\n";
print "hello world we reached here\n";
while( $num < 65)
{
my $scrappy = WWW::Mechanize->new();
$scrappy->proxy('http','http://172.19.1.14:8080');
$scrappy->get($param1); # seed flipkart url will be passed as argument
my $html_str= $scrappy->content();
if ($param5 == 0) # flipkart
{
print "Are we here or not ?\n";
$param1=&update_seed($html_str,$param4,$param2);
print $file_handle $param1."\n";
print $param1."\n";
}
else
{
$param1 = &update_link1($num_pag,$param1);
print $file_handle $param1."\n";
print $param1."\n";
$num_pag++;
}
&better_extract_link($html_str,$param3,$param2,$param5,$db_handler);
$num++;
}
#close($fh);
}
#...............................PART 2 : Final Data Extraction and insertion into DATAbase .....................................
sub get_content_string ()
{
#print "hello atleast we r here \n";
# inputs : url to be scrapped , identifier : for determination to use which regex of the set
my($url, $identifier, $dbh) = (@_);
HTML of entire webpage as the string
my $scrapper = WWW::Mechanize->new();
# get the
# create Mechanize object
$scrapper->proxy('http','http://172.19.1.14:8080'); # confihure proxy
#print "Fine till here \n";
$scrapper->get($url);
#
print "here is where we get screwed up\n";
my $str = $scrapper->content();
my @array = &extract_data($str,$identifier);
my $index = 0;
#print "Author from array before insertion $array[1]\n";
&db_insertion($url, $dbh, @array);
}
sub db_insertion()
{
#print "inside Db inserton\n";
# input :: database handler object, strings : title, author , price and domain
my ($link, $dbh,$title,$authors,$price,$daomain) = (@_); #scheme1 = dbh and all data in scalars
#print "$authors :::: from db insertion\n";
#print "domain is $daomain\n";
$authors =~s//UNKOWN/;
# my ($dbh,@data) = (@_);
#scheme2 = dbh and a list of data
# prepare for insertion into database
my $sth = $dbh->prepare("INSERT INTO BOOK
(Title, Author, Price, Domain,Link) values (?,?,?,?,?)");
#
$sth ->execute($title, $authors, $price, $daomain,$link) or die " cannot insert to table $DBI::errstr\n";
$sth ->finish();
}
#..................
# extract_data screen scrapes for the data
# to be inserted in the database
sub extract_data()
{
#print "Yup we reached extract data\n";
# inputs : HTML content : string , indicator int :num
# output : list of string
my ($str, $indicator ) = (@_);
my $t_reg; # to store title regex
my $a_reg; # to store auth regex
my $p_reg; # to store price regex
my $p_reg1; # to store price1 regex(only applicable for infibeam products)
my @data_arr; # array to strore all the information extracted
my $ret_str = "";
my $auth_str = "";
if ($indicator == 0)
# we have to extract flipkart data
{
$t_reg = $fkart{'title'};
$a_reg = $fkart{'auth'};
$p_reg = $fkart{'price'};
}
if ($indicator == 1)
# we have to extract infibeam data
{
$t_reg = $infibeam{'title'};
$a_reg = $infibeam{'auth'};
$p_reg = $infibeam{'price'};
$p_reg1 = $infibeam{'price1'};
}
if($str =~m/$t_reg/)
# found title string
{
push (@data_arr, $1);
# push in array
}
while ($str =~m/$a_reg/g) # found author string
{
$auth_str = $auth_str.$1;
#push (@data_arr, $1);
# push in array
#print "The authors must be $auth_str\n";
}
#
print "The authors from extraction $auth_str\n";
push (@data_arr,$auth_str);
if($indicator == 0)
# extract price from flipkart
{
#print "did we reach here atleast?\n";
if($str =~m/$p_reg/)
{
#
print "hello u are inside flipkart price extraction\n";
$ret_str = $ret_str.$1;
$ret_str =~ s/,//g;
push (@data_arr, $ret_str);
#
print "this must print the price of flipkart products $ret_str\n";
}
push(@data_arr, "www.flipkart.com");
}
if ($indicator == 1)
# extract price from infibeam
{
my $infi_price = &infi_price($str,$p_reg,$p_reg1);
push (@data_arr, $infi_price);
push (@data_arr, "www.infibeam.com");
}
#print @data_arr;
return @data_arr;
}
# ......................
# seperate function for infibeam.com price extraction
# bcoz infieam.com displays at most 2 prices for each product
sub infi_price()
{
# input : HTML string , 2 regecs for price extraction
# output : float
my($str, $reg1, $reg2) =(@_);
my $ret_str = "";
if($str =~m/$reg1/)
{
$ret_str = $ret_str.$1;
#
print "FROM REG1 $ret_str\n";
$ret_str =~s/,//g;
#return $1;
return $ret_str;
}
if($str =~m/$reg2/)
{
$ret_str = $ret_str.$2;
$ret_str =~s/,//g;
#
print "FROM REG2 $ret_str;\n";
#return $2;
return $ret_str;
}
}
#...................................................................................
#...........................PART 2 : End Of Data Extraction ........................
sub begin_scrapping()
{
# before all the calls to the drive_extract_link initialize the
# database handler object , make connection to the database and pass
# the database handle object to methods, yup passing the argument
# around , but it is better than making connection everytime an
# update is required.
my $driver = "mysql";
my $database = "TESTDB";
my $dsn = "DBI:$driver:database=$database";
my $userid = "root";
my $password = "amit";
my $dbh = DBI -> connect($dsn, $userid, $password) or die "cannot connect to database
$DBI::errstr\n";
my $flipkart_file = "changes.txt";
open (my $fh, ">>changes.txt") or die "cannot open file \n";
if( -s $flipkart_file)
# links are there in file
{
my $last = File::ReadBackwards->new("$flipkart_file")->readline;
chomp($last);
print "The last line read from the file is $last\n";
&drive_extract_link($fh, $last, $domain,$link_regex, $seed_regex, $identifier, $dbh);
}
else
{
&drive_extract_link($fh, $seed_flipkart_link, $domain,$link_regex, $seed_regex, $identifier,
$dbh);
}
close($fh);
my $infi_file = "infi_links.txt";
open (my $FH,">>infi_links.txt") or die "cannot open file \n";
if( -s $infi_file) # links are there
{
my $last = File::ReadBackwards->new("$infi_file") -> readline;
chomp($last);
print "The last line read from the file is $last \n";
&drive_extract_link($FH, $last, $IB_domain, $IB_lnk_reg, $IB_seed_reg, $IB_identifier,
$dbh);
}
else
{
&drive_extract_link($seed_IB_link, $IB_domain, $IB_lnk_reg, $IB_seed_reg, $IB_identifier,
$dbh);
}
close($FH);
}
&begin_scrapping();
sub update_seed()
{
my($html_src, $seed_regex,$domain1) =(@_);
print "$seed_regex\n";
if($html_src=~m/$seed_regex/)
{
return "http://$domain1$1";
}
}
sub update_link1()
{
my ($num , $IB_lnk) =(@_);
if($IB_lnk =~m/(.+?page=)\d+/)
{
return $1.$num."\n";
}
}
