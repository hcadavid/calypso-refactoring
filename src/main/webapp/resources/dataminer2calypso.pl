#! /usr/bin/env perl
use strict;
use warnings;
use Getopt::Std;
use POSIX qw(tmpnam);
use Sys::Hostname;

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
# convert dos to linux format
##########
sub dos2linux{
    my ($filename) = @_;

   rename("$filename","$filename.bak");
    open INPUT, "$filename.bak";
    open OUTPUT, ">$filename";
    
    while( <INPUT> ) {
	s/\r\n$/\n/;     # convert CR LF to LF
	s/\x0D/\x0A/g;
	print OUTPUT $_;
    }
    
    close INPUT;
    close OUTPUT;
    unlink("$filename.bak");
    return 1;
}


##
# usage message
##
sub usage{
    print <<USAGE;

  $0 -o [options] <dataminer>  <calypso> <sep>

USAGE

}


##
# Get parameters
##
our($opt_v,$opt_h);

getopts("vh");

unless(@ARGV){
    usage;
    exit 1;
}



if($opt_h){
    usage;
    exit;
}

check_args(3);
my ($dataminer,$out,$sep) = @ARGV;

die unless dos2linux($dataminer);

die "ERROR: Could not open $dataminer: $!\n" unless open(DA,"<$dataminer");
die "ERROR: Could not open $out: $!\n" unless open(OUT,">$out");

my $line;

while($line = <DA>){
    next if $line =~ /^\s*$/;
    next if $line =~ /^\s*\#/;
    chomp($line);

    my @fields = split(/$sep/,$line);

    shift @fields;

    print OUT "default,Header,",join(",",@fields),"\n";
    last;
}

while($line = <DA>){
    next if $line =~ /^\s*$/;
    next if $line =~ /^\s*\#/;
    chomp($line);

    my @fields = split(/$sep/,$line);
    print OUT "default,",join(",",@fields),"\n";
}
close(DA);
close(OUT);
