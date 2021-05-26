#! /usr/bin/env perl
use strict;
use warnings;
use Getopt::Std;
use POSIX qw(tmpnam);
use Sys::Hostname;

my $CONVERT_BIOM;

my $HOST = hostname();

if($HOST =~ /sciappv01/){
    $CONVERT_BIOM = "/usr/bin/convert_biom.py";
}
elsif($HOST =~ /Users-MacBook/){
        $CONVERT_BIOM = "/usr/local/bin/biom";
}else{
    $CONVERT_BIOM = "/usr/local/bin/biom";
}

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

##########
# convert qiime otu table
##########
sub convert_otu_table{
    my ($otu_table,$out,$uclust_ref, $taxFile) = @_;
    
    my $tmpFile;
    # convert biom to classic OTU table format; biom-format package 

    if($otu_table =~ /\.biom$/){
	$tmpFile = tmpnam();
        my $cmd;
        if($CONVERT_BIOM =~/convert_biom/){ 
	  $cmd = $CONVERT_BIOM . " -i $otu_table -o $tmpFile -b --header_key taxonomy";
        }else{
	  	  print STDERR "converting ...\n";
            $cmd = $CONVERT_BIOM . " convert -i $otu_table -o $tmpFile --to-tsv --header-key taxonomy";
        } 
	unless(system($cmd) == 0){
	    print STDERR "ERROR converting file $otu_table\n";
	    return;
	}
	$otu_table = $tmpFile;
    }


    my %species = ();

    # if otus were generated using uclust_ref
    if($uclust_ref){
      print STDERR "UCLUST ...";
	# get matching reference sequences
	print STDERR "Parsing file $otu_table ...";
	die unless open(OT,"<$otu_table");
	my $line;
	my %matching = ();
	while($line = <OT>){
	    	next if $line =~ /^\s*\#OTU/;
		next if $line =~ /^\s*$/;
		next if $line =~ /^\s*\#/;
		chomp($line);

		my @fields = split(/\s*\t\s*/,$line);
		my $otu = shift @fields;

		# check if OTU was generated based on matching reference
		# sequence
		if(! ($otu =~ /^None\d/)){
		    $matching{$otu} = 1;
		}

	}
	close(OT);
	print STDERR " Done.\n";

	if(-e $tmpFile){unlink($tmpFile);}

	# parse reference fasta file and get species of matching
	# reference sequences
	my $sub_ref = sub{
	    my ($name) = @_;

	    my @fields = split(/\s+/,$name);
	    my $id = $fields[0];

	    return 1 unless defined $matching{$id};

	    my $genus = $fields[1] || "";
	    my $sp = $fields[2] || "";

	    $species{$id} = "$genus $sp";

	    return 1;
	};

	die unless parse_fasta($uclust_ref,$sub_ref);

	%matching = ();
    }

    print STDERR "READING $otu_table\n";
    
    die "ERROR: Could not open file otu_table $otu_table: $!\n" unless open(TA,"<$otu_table");
    die "ERROR: Could not open file out $out: $!\n" unless open(CA,">$out");

    my $line;

    # get header
    my %taxHash;
    my $taxFlag = 0;   
    my @header; 
    while($line = <TA>){

	next unless $line =~ /^\s*\#OTU/;

	chomp($line);
	@header = split(/\t/,$line);
	shift @header;
        if($header[-1] =~/taxonomy/i){
            pop @header;
            $taxFlag = 1;
        }
	print CA "OTU,Header,", join(',',@header),"\n";
	last;
    }

    my @ranks = ('k','p','c','o','f','g','s');
    my %taxCounts;
    # get taxa counts
    my @total;
    while($line = <TA>){
	next if $line =~ /^\s*$/;
	next if $line =~ /^\s*\#/;
	chomp($line);

	my @fields = split(/\s*\t\s*/,$line);

	my $otu = shift @fields;
	my $taxa ="";

	$taxFlag = 1;
	#for printing unique taxa and avoiding empty taxa
	if( $taxFlag ){
	    $taxa = pop @fields;
	    if($taxa =~/^\"(.+)\"$/){
		$taxa = $1;
	    }
	    my @cla= split ';', $taxa;
	    my $genus;
	    for (my $i = 0; $i < @fields; $i++){
		$total[$i]+=$fields[$i];
	    }
	    foreach my $rank_taxon (@cla){
		if($rank_taxon =~ /([sgfpcdok])__(.+)/){
		    my ($rank, $name) = ($1,$2);
		    $genus = $name if ($rank eq 'g');
		    $name = $genus."_".$name if ($rank eq 's');
		    if($rank eq 'g' || $rank eq 's'){
			unless(defined $genus ){
			    print STDERR $taxa."\n";
			}
		    }
		    if(exists $taxCounts{$rank}{$name}){
			my $runner = 0;
			my @val = @{$taxCounts{$rank}{$name}};
			for (my $i = 0; $i < @fields; $i++){
			    $val[$i]+= $fields[$i];
			}
			$taxCounts{$rank}{$name}=\@val;
		    }else{
			$taxCounts{$rank}{$name}= \@fields;
		    }
		}
	    }
	    
	    #ignore levels without classification, eg k__Bacteria; p__Firmicutes; c__Clostridia; o__; f__; g__; s__
	    while($taxa =~ /(.+);\s{0,1}[sgfpcdok]__$/){
		$taxa = $1;
	    }
	    $taxHash{$taxa}=1;
	}
	my $id;
	my $id_set = 0;
	if($uclust_ref){
	    if(! ($otu =~ /^None/)){
		my $spec = $species{$otu};
		die "ERROR: no species for $otu ($uclust_ref)\n" unless $spec;
		$id = "$spec $otu";
		$id_set =1;
	    }
	}

	if(! $id_set){
	my @tmp = split(/\;/,$taxa);
	shift @tmp if($tmp[0] =~/Root/);  #based on RDP classification rank root is noted
	if(@tmp == 1){  #k__Bacteria
	    $taxa = $tmp[0];
	    $taxa =~s/^\s//g;
	    if($taxa !~ /[kpcofgs]\_\_/){
		$taxa = "k__$taxa";
	    }
	}elsif(@tmp == 2){ #k__Bacteria; p__Firmicutes
	    $taxa = $tmp[1];
	    $taxa =~s/^\s//g;
	    if($taxa !~ /[kpcofgs]\_\_/){
		$taxa = "p__$taxa";
	    }
	}elsif(@tmp > 2){
	    shift @tmp;
	    

	    my $phylum = shift @tmp;
	    my $last = pop @tmp;
	    $last =~s/^\s//g;
	    $phylum =~s/^\s//g;
	    while($last =~ /[kpcofgs]\_\_$/ &&  @tmp > 0 ){
		$last = pop @tmp;
	    }
	    if($last =~/s__/){
		my $genus = pop @tmp;
		$genus =~s/^\s//g;
		$last = $genus.'__'.$last;
	    }else{
		if($last !~ /[kpcofgs]\_\_/){
		    if(@tmp+2 ==7){
			my $genus = pop @tmp;
			$genus =~s/^\s//g;
			$last = "g__".$genus."__s__$last";
		    }else{
			$last = $ranks[(@tmp+2)]."__$last";
		    }
		}
	    }
	    if($phylum =~ /[kpcofgs]\_\_/){
		$taxa = "$phylum; $last";
	    }else{
		$taxa = "p__$phylum; $last";
	    }	   
	    
	}
	$id = "$taxa $otu";
	$id =~s/denovo//g;
	}
	print CA "OTU,$id," , join(',',@fields) , "\n";
    }
    my %ranksAbbreviation = (
	's' => 'species',
	'd'=> 'domain',
	'p' => 'phylum',
	'c' => 'class',
	'o' => 'order',
	'f' => 'family',
	'g' => 'genus',
	'r' => 'rootrank',
	'k' => 'superkingdom');
    foreach my $rank (keys %taxCounts){
	print CA "\n$ranksAbbreviation{$rank},Header,", join(',',@header),"\n";
	my @sum;
	map {push @sum, 0} (@header);
	foreach my $taxon (keys %{$taxCounts{$rank}}){
	    my @vals = @{$taxCounts{$rank}{$taxon}};
	    for(my $i = 0 ; $i < @vals; $i++){
		$sum[$i] += $vals[$i]; 
	    }
	    print CA $ranksAbbreviation{$rank}.",".$taxon.",".(join ",",@vals)."\n"; 
	    
	}
	my @unknown=();
	for(my $i = 0 ; $i < @total; $i++){
	    push @unknown , ($total[$i] -  $sum[$i]); 
	}
	print CA $ranksAbbreviation{$rank}.",Unclassified,".(join ",",@unknown)."\n";
    }
    close(TA);
    close(CA);

    if($taxFlag && defined($taxFile)){
	open(TAXOUT, ">".$taxFile);

	my %levelsFile;
	my $hierarchyString ="";
	foreach my $hierarchy (keys %taxHash){
	    my @taxa = split "; ", $hierarchy;
	    my @list = ('rootRank__Root');
	    my $parent = 'r';
	    my $parentTaxon = 'Root';
	    my $i = 0;
	    foreach my $taxon (@taxa){
		next if($taxon =~/root/i);
		next if $taxon =~/Unclassified/i;
		if($taxon =~ /([sdpcofgk])\_\_(.*)/){
		    if($1 eq 's'){
			push @list, $ranksAbbreviation{$1}."__$parentTaxon ".$2;
		    }else{
			push @list, $ranksAbbreviation{$1}."__".$2;
		    }

		    $levelsFile{$parent}{$1}++;
		    $parent = $1;
		    $parentTaxon = $2;
		}else{
		    if($ranks[$i] eq 's'){
			push @list, $ranksAbbreviation{$ranks[$i]}."__$parentTaxon $taxon";
		    }else{
			push @list, $ranksAbbreviation{$ranks[$i]}."__$taxon";
		    }
		    $levelsFile{$parent}{$ranks[$i]}++;
		    $parent = $ranks[$i];
		    $parentTaxon = $taxon;
		    $i++;
		}
	    }
	    $hierarchyString .= join("\t", @list)."\n";
	}
	my $levelCurrent = 'r';
	my @header = ('rootRank');
	while(exists $levelsFile{$levelCurrent}){
	    my @children = (keys %{$levelsFile{$levelCurrent}});
	    if(@children == 1){
		push(@header, $ranksAbbreviation{$children[0]});
		$levelCurrent = $children[0];;
	    }
	}
	print TAXOUT "#", (join "\t", @header), "\n";
	print TAXOUT $hierarchyString;
	close TAXOUT;
    }

    

    return 1;
}

##########
# convert qiime mapping file
##########
sub convert_mapping{
    my ($mapping,$out) = @_;

    die "ERROR: Could not open file $mapping: $!\n" unless open(MA,"<$mapping");
    die "ERROR: Could not open file $out: $!\n" unless open(AN,">$out");

    print AN "Sample,Label,Individual,Group,Time,Include\n";
    my $line;

    my $i = 0;    

    while($line = <MA>){
	$i++;
	next if $line =~ /^\s*$/;
	chomp($line);
	$line =~ s/\s*$//;

	my @fields = split(/\s*\t\s*/,$line);

	if(@fields < 5){
	    print STDERR "ERROR: wrong line format line $i\n";
	    return;
	}
	pop @fields;

	my $env = "";
	while(@fields > 4){
	    $env .= "," . pop @fields;
	}
	print AN "Sample,Label,Individual,Group,Secondary Group,Include$env\n";
	last;
    }

    my $indiv = 1;
    while($line = <MA>){
	$i++;
	next if $line =~ /^\s*$/;
	next if $line =~ /^\s*\#/;
	chomp($line);
	$line =~ s/\s*$//;

	my @fields = split(/\s*\t\s*/,$line);

	if(@fields < 5){
	    print STDERR "ERROR: wrong line format line $i\n";
	    return;
	}

	my $sample = $fields[0];
	my $descr = pop @fields;

	my $env = "";
	while(@fields > 4){
	    $env .= "," . pop @fields;
	}
	
	# sampleID, label, subject, group, secondary group, Response, Include
	print AN "$sample,$sample,$indiv,$descr,1,1$env\n";
	$indiv++;
    }

    close(MA);
    close(AN);

    print "Successfully converted file!\n";
 
    return 1;
}

##########
# convert assign_taxonomy.pl output
##########
sub convert_assign_tax{
    my ($assignment,$out) = @_;

    my $format = 0;

    die "ERROR: Could not open file $assignment: $!\n" unless open(MA,"<$assignment");
    my $line;
    while($line = <MA>){
	if($line =~ /;k\_\_/){
	    $format = 2;
	    last;
	}
	if($line =~ /^\d+\s+/){
	    $format = 1;
	}
    }
    close(MA);
	
    die "ERROR: Could not open file $assignment: $!\n" unless open(MA,"<$assignment");
    
    my %counts = ();
    my %samples = ();

    my %total = ();
    my %assigned = ();

    my %rl = (
	"k__" => 0,
	"p__" => 1,
	"c__" => 2,
	"o__" => 3,
	"f__" => 4,
	"g__" => 5,
	"s__" => 6,
	);



    while($line = <MA>){
	next if $line =~ /^\s*$/;
	next if $line =~ /^\s*\#/;
	chomp($line);

	my @fields = split(/\s+/,$line);
	my $sample = $format ? $fields[1] : $fields[0];
	
	my $conf = pop @fields;
	my $taxa = pop @fields;
	$taxa =~ s/^Root;//;


	my @tmp = split(/\_/,$sample);
	pop @tmp;
	$sample = join('_',@tmp);

	$samples{$sample} = 1;

	$total{$sample}++;

	my @ta = split(';',$taxa);

	my $level = 0;

	if(@ta > 7){
	    die "ERROR: $taxa\n";
	}



	if($format == 2){
	    shift @ta;
	    
	    foreach my $t (@ta){
		die "ERROR: wrong format for taxa: $t\n" unless $t =~ s/^(\w\_\_)//;

		my $ra = $1;
		die "ERROR: unknown rank: $ra\n" unless exists $rl{$ra};
		$level = $rl{$ra};
		$counts{$level}{$t}{$sample}++;
		$assigned{$level}{$sample}++;
	    }
	}
	else{
	    my $genus = "";
	    foreach my $t (@ta){
		next if($t =~/^[kpcofgs]\_\_$/);
		$t =~ s/[kpcofgs]\_\_//;
		$genus = $t if($level==5);
		if($level == 6){
		    $counts{$level}{$genus."_".$t}{$sample}++;
		}else{
		    $counts{$level}{$t}{$sample}++;
		}
		$assigned{$level}{$sample}++;
		$level++;
	    }
	}
    }

    close(MA);


    my %ranks = (
	0 => 'Domain',
	1 => 'Phylum',
	2 => 'Class',
	3 => 'Order',
	4 => 'Family',
	5 => 'Genus',
	6 => 'Species'
	);


    my @samples = keys %samples;
    my $samples = join(',',@samples);

    die "ERROR: Could not open file $out: $!\n" unless open(AN,">$out");

    foreach my $level (sort {$a <=> $b} keys %counts){

	my $rank = $ranks{$level};

	die "ERROR: No rank for level $level\n" unless $rank;

	print AN "$rank,Header,$samples\n";

	foreach my $taxa (keys %{$counts{$level}}){
	    $taxa = "${rank}_$taxa" if(lc($taxa) eq "unclassified");

	    print AN "$rank,$taxa";

	    foreach my $sample (@samples){
		my $count = $counts{$level}{$taxa}{$sample} || 0;
		print AN ",$count";
	    }
	    print AN "\n";
	}
	# add unclassified
	print AN "$rank,Unclassified";

	foreach my $sample (@samples){
	    my $tot = $total{$sample};
	    die unless $tot;
	    my $classified = $assigned{$level}{$sample} || 0;

	    my $unclassified = $tot - $classified;
	    print AN ",$unclassified";
	}

	print AN "\n\n";
    }

    close(AN);

    return 1;
}


sub convertMothurOTU{
    my ($otutable,$out) = @_;

    my $format = 0;

    die "ERROR: Could not open file $otutable: $!\n" unless open(MO,"<$otutable");
    die "ERROR: Could not open file $out: $!\n" unless open(AN,">$out");
    my $line;
    my %counts;
    my @otus;
    while($line = <MO>){
	chomp ($line);
	if($line =~ /^label/){
	    my @col = split /\t+/, $line;
	    shift @col;shift @col; shift @col;
	    @otus = @col;
	}elsif($line =~/^0\.03/){
	    die if(@otus == 0);
	    my @col = split /\t+/,$line;
	    shift @col; 
	    my $sample = shift @col; shift @col;
	    foreach my $otu (@otus){
		$counts{$sample}{$otu}= shift @col;
	    }
	}
    }
    my @samples = keys %counts;
    print AN "OTU, Header,".(join ',',@samples)."\n";
    foreach my $otu (@otus){
	print AN "OTU,$otu";
	foreach my $s (@samples){
	    print AN ",$counts{$s}{$otu}";
	}
	print AN "\n";
    }
    close (AN);
    close(MO);
    return 1;
}

##########
# parse fasta file
##########
sub parse_fasta{
    my $file = shift @_;
    my $subref = shift @_;
    my @args = @_;

    print STDERR "Parsing file $file ... ";
    unless(open (FASTA, "<$file")){
	print STDERR "ERROR: parse_fasta: Could not open $file:$!\n";
	return;
    }

    my ($name,$sequence);

    # read each line in fasta file and process entrys
    #
    my $line;

    while ($line = <FASTA>) {
	chomp($line);
	next if $line =~ /^\s*$/;
	next if $line =~ /^\s*\#/;

	$line =~ s/\s+$//;

	# check if line contains new fasta header
	if ($line =~ /^>\s*(.+)/) {

	    # process fasta sequence
	    if ($name) {
		&$subref($name,$sequence,@args) or return;
	    }
	    # new entry in fasta file read, therfor set sequence to empty string
	    $name = $1;
	    $sequence = "";
	}
	# line contains DNA sequence, append to $sequence
	else {
	    $sequence .= $line;
	}
    }

    # process fasta sequence
    if ($name) {
	&$subref($name,$sequence,@args) or return;
    }
    close (FASTA);
    print STDERR " Done.\n";

    return 1;
}


##
# usage message
##
sub usage{
    print <<USAGE;

  $0

  Convert QIIME otu table or biom file to calypso counts file:
  ===============================================

  $0 -o [options] <otu_table>  <output>

 where:
  <otu_table> QIIME OTU table. OTU tables are generated
              with the QIIME script pick_otu_table.py
  <output>    file name for the output of $0

 Options:
  -r <fasta> ucluct reference sequences if OTUs were picked with uclust
  -c <taxonomy> file name for the output of taxonomic lineages
  Example: $0 -o otus/otu_table.txt   calypso.csv


  Convert QIIME assign_taxonomy.py output to calypso counts file:
  ===============================================================

  $0 -t <tax_assignments>  <output>

 where:
  <tax_assigments> assign_taxonomy.py output file
   <output>         output file name

  Example: $0 -t rdp22_assigned_taxonomy/seqs_tax_assignments.txt   calypso.csv




  Convert QIIME mapping file to calypso annotation file:
  ======================================================

  $0 -m <mapping_file> <output>

 where:
  <maping_file> QIIME mapipng file
  <output>      name of output file

  Example: $0 -m mapping.txt   calypso.annotation.csv

  Example mapping file:
  ----------------------
  #SampleID       BarcodeSequence LinkerPrimerSequence Group  Description
  Sample49        CAGTACGT        acgggcggtgtgtRc normal        control
  Sample50        CATAGCAT        acgggcggtgtgtRc normal        control
  Sample51        CGAGATGT        acgggcggtgtgtRc normal        control
  Sample55        AGAGATGAT       acgggcggtgtgtRc diabetic        fat
  Sample56        AGATCGTAT       acgggcggtgtgtRc diabetic        fat
  Sample57        AGATGACGT       acgggcggtgtgtRc diabetic        fat

  For more details on QIIME mapping files see: http://www.qiime.org/tutorials/tutorial.html

USAGE

}


##
# Get parameters
##
our($opt_v,$opt_h,$opt_o,$opt_m,$opt_t,$opt_r,$opt_u,$opt_c);

getopts("vhomc:tr:");

unless(@ARGV){
    usage;
    exit 1;
}



my @files = @ARGV;
if($opt_h){
    usage;
    exit;
}
elsif($opt_o){
   check_args(2);
    my ($otu_table,$out) = @ARGV;
    die unless dos2linux($otu_table);
    my $taxFile;
    if($opt_c){
	$taxFile =$opt_c;
    }
    my $uclust_param = 0;
    if($opt_r){
	$uclust_param = 1;
    }
    exit 1 unless convert_otu_table($otu_table,$out,$uclust_param, $taxFile);
   exit 0;
 }
elsif($opt_t){
    check_args(2);
    my ($assignment,$out) = @ARGV;
    die unless dos2linux($assignment);
    exit 1 unless convert_assign_tax($assignment,$out);
    exit 0;
  }
elsif($opt_m){
    check_args(2);
    my ($mapping,$out) = @ARGV;
    die unless dos2linux($mapping);
    exit 1 unless convert_mapping($mapping,$out);
    exit 0;
}elsif($opt_u){
    check_args(2);
    my ($otu_table, $out) = @ARGV;
    die unless dos2linux($otu_table);
    exit 1 unless convertMothurOTU($otu_table, $out);
    exit 0;
}
else{
    usage;
}
