#!/usr/local/bin/perl

use strict;
use warnings;

################################################################################

############
# PACKAGES #
############

use Cwd;
use Getopt::Long;
use Data::Dumper;

################################################################################

#############
# FUNCTIONS #
#############

sub usage {

	print <<EOF;

Usage:
	calculated_fields.pl -f FASTA -c CDS [-o OUTDIR] [-v]
	calculated_fields.pl [-h]

	calculated_fields.pl --fasta FASTA --cds CDS [--outdit OUTDIR] [--verbose]
	calculated_fields.pl [--help]

Required arguments:
	-f | --fasta   : extracted information from FASTA file
	-c | --cds     : extracted information from CDS file

Optional arguments:
	-o | --outdir  : output directory [by default: working directory]

Help:
	-h | --help    : print this help
	-v | --verbose : activate verbose mode

Description:

	This script needs 2 input files :
	- the extracted information from FASTA file
	- the extracted information from CDS from GFF file

	For each position in FASTA file it calculates the following missing fields :
	- the complement nucleotide (on strand -)
	- the codon containing the processed position on strand +
	- the codon containing the processed position on strand -
	- the corresponding amino-acid on strand +
	- the corresponding amino-acid on strand -

EOF

	exit;

}

# complement function
# Input :
#	 - a nucleotide
# Output :
#	- a nucleotide
# Objectif :
#	- get the nucleotide complement
sub complement {

	my $nuc = shift;
	$nuc =~ tr/ATGCUatgcuNnYyRrSsWwKkMmBbDdHhVv/TACGAtacgaNnRrYySsWwMmKkVvHhDdBb/;
	return $nuc;

}

# codon function
# Input :
#	- a seqid
#	- a strand
#	- a position
#	- the hash reference containing information from FASTA
#	- the hash reference containing information from CDS
# Output :
#	- the codon which contains the processed position
sub codon {

	# Read parameters
	my $seqid    = shift;
	my $strand   = shift;
	my $pos      = shift; # Processed position
	my $href_cds = shift;
	my $href_pos = shift;

	# Declare variables
	my $start_pos;
	my $end_pos;
	my $codon;
	my $phase = "-1";

	# Process each CDS start position (from seqid $seqid and strand $strand)
	foreach my $start_pos_cds ( keys %{ %$href_cds{$seqid}->{$strand} } ){

		# Get start position
		$start_pos = $start_pos_cds;

		# Get end position
		my @table = keys %{ %$href_cds{$seqid}->{$strand}->{$start_pos} } ;
		$end_pos = $table[0];

		# If the processed position is between start and end position
		if ( $pos >= $start_pos && $pos <= $end_pos){

			# Get phase
			$phase = %$href_cds{$seqid}->{$strand}->{$start_pos}->{$end_pos} ;

		}

		# If a phase is found : $phase is not equal to -1 anymore
		if ($phase ne "-1"){
			last; # Stop looking for the phase of the processed position
		}

	}

	# From https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md
	# Column 8: "phase"
	# For features of type "CDS", the phase indicates where the feature begins with reference to the reading frame. The phase is one of the integers 0, 1, or 2, indicating the number of bases that should be removed from the beginning of this feature to reach the first base of the next codon. In other words, a phase of "0" indicates that the next codon begins at the first base of the region described by the current line, a phase of "1" indicates that the next codon begins at the second base of this region, and a phase of "2" indicates that the codon begins at the third base of this region. This is NOT to be confused with the frame, which is simply start modulo 3.
	# For forward strand features, phase is counted from the start field. For reverse strand features, phase is counted from the end field.
	# The phase is REQUIRED for all CDS features.

	# TODO : check if it's RIGHT with reverse strand features !

	# If position-start position modulo 3 equal 0
	if ( ($pos - $start_pos) % 3 == 0 ){
		if ($phase == 0){
			$codon = uc(%$href_pos{$seqid}->{$pos}).lc(%$href_pos{$seqid}->{$pos+1}).lc(%$href_pos{$seqid}->{$pos+2});
		} elsif ($phase == 1){
			$codon = lc(%$href_pos{$seqid}->{$pos-2}).lc(%$href_pos{$seqid}->{$pos-1}).uc(%$href_pos{$seqid}->{$pos});
		} elsif ($phase == 2){
			$codon = lc(%$href_pos{$seqid}->{$pos-1}).uc(%$href_pos{$seqid}->{$pos}).lc(%$href_pos{$seqid}->{$pos+1});
		} else {
			$codon = "NA";
		}
	} elsif ( ($pos - $start_pos) % 3 == 1 ){ # If position-start position modulo 3 equal 1
		if ($phase == 0){
			$codon = lc(%$href_pos{$seqid}->{$pos-1}).uc(%$href_pos{$seqid}->{$pos}).lc(%$href_pos{$seqid}->{$pos+1});
		} elsif ($phase == 1){
			$codon = uc(%$href_pos{$seqid}->{$pos}).lc(%$href_pos{$seqid}->{$pos+1}).lc(%$href_pos{$seqid}->{$pos+2});
		} elsif ($phase == 2){
			$codon = lc(%$href_pos{$seqid}->{$pos-2}).lc(%$href_pos{$seqid}->{$pos-1}).uc(%$href_pos{$seqid}->{$pos});
		} else {
			$codon = "NA";
		}
	} else { # If position-start position modulo 3 equal 2
		if ($phase == 0){
			$codon = lc(%$href_pos{$seqid}->{$pos-2}).lc(%$href_pos{$seqid}->{$pos-1}).uc(%$href_pos{$seqid}->{$pos});
		} elsif ($phase == 1){
			$codon = lc(%$href_pos{$seqid}->{$pos-1}).uc(%$href_pos{$seqid}->{$pos}).lc(%$href_pos{$seqid}->{$pos+1});
		} elsif ($phase == 2){
			$codon = uc(%$href_pos{$seqid}->{$pos}).lc(%$href_pos{$seqid}->{$pos+1}).lc(%$href_pos{$seqid}->{$pos+2});
		} else {
			$codon = "NA";
		}
	}

	return $codon;

}

sub amino_acid {

	my $codon = shift;

	$codon = uc $codon;

	my %genetic_code = (
		'TCA' => 'S', # Serine
		'TCC' => 'S', # Serine
		'TCG' => 'S', # Serine
		'TCT' => 'S', # Serine
		'TTC' => 'F', # Phenylalanine
		'TTT' => 'F', # Phenylalanine
		'TTA' => 'L', # Leucine
		'TTG' => 'L', # Leucine
		'TAC' => 'Y', # Tyrosine
		'TAT' => 'Y', # Tyrosine
		'TAA' => '_', # Stop
		'TAG' => '_', # Stop
		'TGC' => 'C', # Cysteine
		'TGT' => 'C', # Cysteine
		'TGA' => '_', # Stop
		'TGG' => 'W', # Tryptophan
		'CTA' => 'L', # Leucine
		'CTC' => 'L', # Leucine
		'CTG' => 'L', # Leucine
		'CTT' => 'L', # Leucine
		'CCA' => 'P', # Proline
		'CCC' => 'P', # Proline
		'CCG' => 'P', # Proline
		'CCT' => 'P', # Proline
		'CAC' => 'H', # Histidine
		'CAT' => 'H', # Histidine
		'CAA' => 'Q', # Glutamine
		'CAG' => 'Q', # Glutamine
		'CGA' => 'R', # Arginine
		'CGC' => 'R', # Arginine
		'CGG' => 'R', # Arginine
		'CGT' => 'R', # Arginine
		'ATA' => 'I', # Isoleucine
		'ATC' => 'I', # Isoleucine
		'ATT' => 'I', # Isoleucine
		'ATG' => 'M', # Methionine
		'ACA' => 'T', # Threonine
		'ACC' => 'T', # Threonine
		'ACG' => 'T', # Threonine
		'ACT' => 'T', # Threonine
		'AAC' => 'N', # Asparagine
		'AAT' => 'N', # Asparagine
		'AAA' => 'K', # Lysine
		'AAG' => 'K', # Lysine
		'AGC' => 'S', # Serine
		'AGT' => 'S', # Serine
		'AGA' => 'R', # Arginine
		'AGG' => 'R', # Arginine
		'GTA' => 'V', # Valine
		'GTC' => 'V', # Valine
		'GTG' => 'V', # Valine
		'GTT' => 'V', # Valine
		'GCA' => 'A', # Alanine
		'GCC' => 'A', # Alanine
		'GCG' => 'A', # Alanine
		'GCT' => 'A', # Alanine
		'GAC' => 'D', # Aspartic Acid
		'GAT' => 'D', # Aspartic Acid
		'GAA' => 'E', # Glutamic Acid
		'GAG' => 'E', # Glutamic Acid
		'GGA' => 'G', # Glycine
		'GGC' => 'G', # Glycine
		'GGG' => 'G', # Glycine
		'GGT' => 'G', # Glycine
	);

	if( exists $genetic_code{$codon} ) {
		return $genetic_code{$codon};
	} else {
		return "NA";
	}

}

################################################################################

############
# DEFAULTS #
############

my $fasta   = "NOTDEFINED";
my $cds     = "NOTDEFINED";
my $outdir  = getcwd();
my $verbose = 0;
my $help    = 0;

################################################################################

###########
# OPTIONS #
###########

GetOptions (
	"f|fasta=s"  => \$fasta,   # file
	"c|cds=s"    => \$cds,     # file
	"o|outdir=s" => \$outdir,  # file
	"v|verbose"  => \$verbose, # flag
	"h|help"     => \$help,    # flag
) or die ("Error in command line arguments\n");

################################################################################

if( $help || $fasta eq "NOTDEFINED" || $cds eq "NOTDEFINED" ) {
	usage();
}

################################################################################

################
# START SCRIPT #
################

print "\n# BEGIN calculated_fields.pl\n";

################################################################################

my %hash_pos;
my %hash_cds;

if ( $verbose ){ print "\t[VERBOSE] ---> Stored information from CDS file in an hash\n" ; }

# Open 'info from CDS' file for reading
if ( open( my $FH_cds, '<', $cds ) ) {

	# Process each line
	while ( my $line = <$FH_cds> ) {

		chomp $line;
		my @lines      = split "\t", $line;
		my $seqid      = $lines[0];
		my $strand     = $lines[1];
		my $start      = $lines[2];
		my $end        = $lines[3];
		my $phase      = $lines[4];
		my $feature_id = $lines[5];

		# Store information into hash_cds (5-level hash)
		$hash_cds{$seqid}{$strand}{$start}{$end} = $phase;

	}

	close( $FH_cds ) ;

} else {
	warn "Could not open file '$cds' $!";
}

if ( $verbose ){ print "\t[VERBOSE] ---> Stored information from FASTA file in an hash\n" ; }

# Open 'info from FASTA' file for reading
if ( open( my $FH_fasta, '<', $fasta ) ) {

	# Process each line
	while ( my $line = <$FH_fasta> ) {

		chomp $line;
		my @lines    = split "\t", $line;
		my $seqid    = $lines[0] ;
		my $pos      = $lines[1] ;
		my $nuc_plus = $lines[2] ;

		# Store information into hash_pos (2-level hash)
		$hash_pos{$seqid}{$pos} = $nuc_plus;

	}

	close( $FH_fasta ) ;

} else {
	warn "Could not open file '$fasta' $!";
}

################################################################################

# Handle hash_cds and hash_pos with hash reference now
my $href_pos = \%hash_pos;
my $href_cds = \%hash_cds;

################################################################################

my $outfile = "$outdir/info_from_fasta_complete.tsv";

# Open output file for writing
open( my $FH_pos, '>>', $outfile ) or die "Could not open file '$outfile' $!" ;

if ( $verbose ){ print "\t[VERBOSE] ---> Calculate missing fields\n" ; }

# Process each seqid
foreach my $seqid ( keys %{ $href_pos } ) {

	# Process each position
	foreach my $pos ( keys %{ %$href_pos{$seqid} }) {

		# Get nucleotide + and -
		my $nuc_plus    = $href_pos->{$seqid}{$pos};
		my $nuc_minus   = complement($nuc_plus)    ;

		# Get codon + and -
		my $codon_plus  = codon($seqid, '+', $pos, $href_cds, $href_pos);
		my $codon_minus = codon($seqid, '-', $pos, $href_cds, $href_pos);

		# Get amino acid + and -
		my $aa_plus     = amino_acid($codon_plus) ;
		my $aa_minus    = amino_acid($codon_minus);

		# Print line in output file
		print $FH_pos $seqid."\t".$pos."\t".$nuc_plus."\t".$codon_plus."\t".$aa_plus."\t".$nuc_minus."\t".$codon_minus."\t".$aa_minus."\n";

	}
}

close( $FH_pos ) ;

################################################################################

##############
# END SCRIPT #
##############

print "# END calculated_fields.pl\n\n";;
