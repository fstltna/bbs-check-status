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
my $timeout=5;
my $VERSION="0.1a";
my $UpOrDown="";
my $DB_Owner="";
my $DB_Pswd="";
my $DB_Name="";
my $DB_Prefix="";

my $CONF_FILE="/root/bbs-check-status/config.ini";

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
	my $UpOrDown = $host_hr->{tcp}{$CurPort}{open} ? "up" : "down";
	print "$CurHost : $CurPort - $UpOrDown\n";
	MarkBBS();
}

print("BBS Check Status ($VERSION)\n");
print("=============================\n");

### The database handle
my $dbh = DBI->connect ("DBI:mysql:database=$DB_Name:host=localhost",
                           $DB_Owner,
                           $DB_Pswd) 
                           or die "Can't connect to database: $DBI::errstr\n";

my $DB_Table = $DB_Prefix . "jvld_links";

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
