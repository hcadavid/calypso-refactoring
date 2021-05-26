#! /usr/bin/env perl
use strict;
use warnings;
use Getopt::Std;

sub clean_handler{
    die;
}

########
# check arguments
########
sub check_args{
    my ($n) = @_;

    if(@ARGV!= $n){
	usage();
	print STDERR "ERROR: wrong number of arguments, number of expected arguments: $n\n";
	exit 1;
    }

    return 1;
}

##########
# convert Calypso v2 annotation
##########
sub convert_annotation{
    my ($annot,$out) = @_;

    die "ERROR: Could not open file $annot: $!\n" unless open(MA,"<$annot");
    die "ERROR: Could not open file $out: $!\n" unless open(AN,">$out");


    print AN "Sample,Label,Individual,Group,Secondary Group,Include,Response\n";
    my $line;

    my $i = 0;
    while($line = <MA>){
	$i++;
	next if $line =~ /^\s*$/;
	next if $line =~ /^\s*\#/;
	chomp($line);
	$line =~ s/\s*$//;

	my @fields = split(/\s*,\s*/,$line);

	if(@fields < 7){
	    print STDERR "ERROR: wrong line format line $i\n";
	    return;
	}

	my ($sampple,$label,$pair,$group,$groupS,$response,$include) = @fields;

	# sampleID, label, subject, group, groupS point/location, Include
	print AN "$sampple,$label,$pair,$group,$groupS,$include,$response\n";
    }

    close(MA);
    close(AN);

    print "Successfully converted file.\n";
 
    return 1;
}


##
# usage message
##
sub usage{
    print <<USAGE;

  $0


  Convert Calypso v2 annotation file to Calypso v3 annotation file
  ================================================================

  $0 -m <annotation> <output>

 where:
  <annotation> Calypso v2 annotation file
  <output>     name of output file

  Example: $0 -c calypso2.annot.csv   calypso3.annotation.csv


USAGE

}


##
# Get parameters
##
our($opt_v,$opt_h,$opt_c);

getopts("vhc");

unless(@ARGV){
    usage;
    exit 1;
}


my @files = @ARGV;

if($opt_h){
    usage;
    exit;

}
elsif($opt_c){
    check_args(2);
    my ($annot,$out) = @ARGV;
    exit 1 unless convert_annotation($annot,$out);
    exit 0;
}

else{
    usage;
}
