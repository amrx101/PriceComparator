
#!/usr/bin/perl -w
use CGI qw(:standard);
# Include standard HTML and CGI functions
use CGI::Carp qw(fatalsToBrowser);
require "se1.pl";
print header;
# Send error messages to browser
require "login.pl";
#require "select.pl";
require "new.pl";
my $dbh = &connect_db();
#
print start_html(-title=>"Price Comparator", -bgcolor=>"#00CCFF");
HTML HEAD
# cgi equivalent of
print h1("Perl Project");
if (param())
# If true, the form has already been filled out.
{
&display_form();
$who = param("myname");
my @str = ();
if(length($who) > 0)
{
@str = &getfrombook($dbh,$who);
print "<table border = 1>";
print "<tr>";
print "<th> Flipkart </th>";
print "<th> Infibeam </th>";
print "</tr>";
print "<tr>";
print "<td> $str[0] </td>";
print "<td> $str[1] </td>";
print "</tr>";
print "</table>";
}
}
else
{
#print "u are here\n";
# Else, first time so present form.
&display_form();
}
print end_html;
sub display_form()
{
print start_form();
print p("Enter Author",textfield("myname"));
print p(submit("Submit form"));#, reset("Clear form"));
print end_form();
}
