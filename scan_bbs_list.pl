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
my $timeout=5;
my $VERSION="0.1a";
my $UpOrDown="";
my $DB_Owner="root";
my $DB_Pswd="wssx34x!";
my $DB_Name="joomla";
my $DB_Prefix="slm86_";

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

sub table_exists {
    my $db = shift;
    my $table = shift;
    my @tables = $db->tables('','','','TABLE');
    if (@tables) {
        for (@tables) {
            next unless $_;
            return 1 if $_ eq $table
        }
    }
    else {
        eval {
            local $db->{PrintError} = 0;
            local $db->{RaiseError} = 1;
            $db->do(qq{SELECT * FROM $table WHERE 1 = 0 });
        };
        return 1 unless $@;
    }
    return 0;
}

print("BBS Check Status ($VERSION)\n");
print("=============================\n");

$CurHost="amigacity.xyz";
$CurPort=23;
CheckBBS();

### The database handle
my $dbh = DBI->connect ("DBI:mysql:database=$DB_Name:host=localhost",
                           $DB_Owner,
                           $DB_Pswd) 
                           or die "Can't connect to database: $DBI::errstr\n";

if (table_exists($dbh, $DB_Prefix . "jvld_links"))
{
    print "it's there!\n";
}
else
{
    print "table not found!\n";
	exit(1);
}

### The statement handle
my $sth = $dbh->prepare( "SELECT id, name FROM megaliths" );


exit(0);
