#!/usr/bin/perl

# This tool scans all the entries in the JV-LD database to see
# if they are functional or not

use strict;
use warnings;
use IO::Socket::PortState qw(check_ports);
use DBI;

# No changes below here
my $CurHost="";
my $CurPort=0;
my $CurId=0;
my $CurStatus="";
my $timeout=5;
my $VERSION="1.0";
my $UpOrDown="";
my $DB_Owner="";
my $DB_Pswd="";
my $DB_Name="";
my $DB_Prefix="";
my $DB_Table="";
my $dbh;
my $CONF_FILE="/root/bbs-check-status/config.ini";

# Read in configuration options
open(CONF, "<$CONF_FILE") || die("Unable to read config file '$CONF_FILE'");
while(<CONF>)
{
	chop;
	my ($FIELD_TYPE, $FIELD_VALUE) = split (/	/, $_);
	#print("Type is $FIELD_TYPE\n");
	if ($FIELD_TYPE eq "DB_User")
	{
		$DB_Owner = $FIELD_VALUE;
	}
	elsif ($FIELD_TYPE eq "DB_Pswd")
	{
		$DB_Pswd = $FIELD_VALUE;
	}
	elsif ($FIELD_TYPE eq "DB_DBName")
	{
		$DB_Name = $FIELD_VALUE;
	}
	elsif ($FIELD_TYPE eq "DB_DBtblpfx")
	{
		$DB_Prefix = $FIELD_VALUE;
	}
}
close(CONF);

# Marks the BBS state and check time
sub MarkBBS
{
	my($day, $month, $year)=(localtime)[3,4,5];
	$year += 1900;
	$month += 1;
	$month = substr("0".$month, -2);
	$day = substr("0".$day, -2);
	my $timeString="$year-$month-$day";
	# Field8 = date in "0000-00-00"
	# Field9 = status in "Active/Unreachable" format
	$dbh->do("UPDATE $DB_Table SET Field8 = ?, Field9 = ? WHERE id = ?",
		undef,
		$timeString,
		$CurStatus,
		$CurId);
}

# Checks to see if the BBS is up
sub CheckBBS
{
	my %port_hash = (
		tcp => {
			$CurPort => {},
		}
	);

	my $host_hr = check_ports($CurHost, $timeout, \%port_hash);
	$CurStatus = $host_hr->{tcp}{$CurPort}{open} ? "Active" : "Unreachable";
	print "$CurHost : $CurPort - $CurStatus\n";
	MarkBBS();
}

print("BBS Check Status ($VERSION)\n");
print("=============================\n");

### The database handle
$dbh = DBI->connect ("DBI:mysql:database=$DB_Name:host=localhost",
                           $DB_Owner,
                           $DB_Pswd) 
                           or die "Can't connect to database: $DBI::errstr\n";

$DB_Table = $DB_Prefix . "jvld_links";

#print ("Table is '$DB_Table'\n");

### The statement handle
my $sth = $dbh->prepare("SELECT id, partner_url, field1, field2 FROM $DB_Table");

$sth->execute or die $dbh->errstr;

my $rows_found = $sth->rows;

while (my $row = $sth->fetchrow_hashref)
{
	$CurId = $row->{'id'};
	$CurHost = $row->{'field1'};
	$CurPort = $row->{'field2'};
	CheckBBS();
}

exit(0);
