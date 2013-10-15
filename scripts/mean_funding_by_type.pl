#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
use Text::CSV;

=cut
0 'Funder Name',
1 'Funder State',
2 'Grantee Name',
3 'Grantee City',
4 'Grantee State',
5 'Year(s)',
6 'Grant Amount',
7 'Types(s) of Support',
8 'Description'
=cut

my %types_categories = (
  'Scholarship funds' => 'program',
  'Conferences/seminars' => 'other',
  'Faculty/staff development' => 'capacity building',
  'Program evaluation' => 'capacity building',
  'Advocacy' => 'program',
  'Research' => 'program',
  'Publication' => 'program',
  'Continuing support' => 'general operating',
  'Electronic media/online services' => 'capacity building',
  'Seed money' => 'capacity building',
  'Building/renovation' => 'capital',
  'Capital campaigns' => 'capital',
  'Curriculum development' => 'program',
  'Awards/prizes/competitions' => 'other',
  'Management development/capacity building' => 'capacity building',
  'Program development' => 'program',
  'Income development' => 'capital',
  'General/operating support' => 'general operating',
  'Matching/challenge support' => 'other',
  'Computer technology' => 'capital',
  '' => 'general operating',
);

my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
  or die "Cannot use CSV: ".Text::CSV->error_diag ();

my $infile = shift(@ARGV) || die "Need infile.\n";
die "$infile does not exist" unless -e $infile;

open my $fh, "<:encoding(utf8)", $infile or die "$infile: $!";

my $headers = $csv->getline( $fh );

my %granters = ( );
my %grant_buckets = ( );

while ( my $row = $csv->getline( $fh ) ) {
  my $grant_maker = $row->[0];

  $granters{$grant_maker} ||= { };

  my $grant_ammount = $row->[6];
  $grant_ammount =~ s/\D//g; 

  my $funding_type = $row->[7];
  if ($funding_type =~ /;/) {
    ($funding_type) = $funding_type =~ /^([^;]*);.*$/;
  }

  my $grant_bucket = $types_categories{$funding_type};
  $grant_buckets{$grant_bucket} = 1;
  $granters{$grant_maker}->{$grant_bucket} += $grant_ammount;
  $granters{$grant_maker}->{$grant_bucket."_count"}++;
}

print "grant_maker,".join(',', sort keys %grant_buckets)."\n";;

foreach my $grant_maker (sort keys %granters) {
  my @columns = $grant_maker;
  foreach my $bucket (sort keys %grant_buckets) {
    if ($granters{$grant_maker}->{$bucket}) {
      push(@columns, $granters{$grant_maker}->{$bucket}/$granters{$grant_maker}->{$bucket."_count"} || 0);
    }
    else {
      push(@columns, 0);
    }
  }
  $csv->combine(@columns);
  print $csv->string()."\n";
}

