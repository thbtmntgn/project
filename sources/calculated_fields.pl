#!/usr/local/bin/perl

use strict;
use warnings;

################################################################################

############
# PACKAGES #
############

use Getopt::Long;
use Data::Dumper;

################################################################################

#############
# FUNCTIONS #
#############

sub usage {

	print <<EOF;

Usage:

Options:
	-f | --fasta   : extracted information from FASTA file
	-c | --cds     : extracted information from CDS file
	-o | --outdir  : output directory
	-v | --verbose : activate verbose mode
	-h | --help    : print this help

EOF

}

sub complement {

	my $nuc = shift;
	$nuc =~ tr/ATGCUatgcuNnYyRrSsWwKkMmBbDdHhVv/TACGAtacgaNnRrYySsWwMmKkVvHhDdBb/;
	return $nuc;

}

sub codon {

	my $seqid    = shift;
	my $strand   = shift;
	my $pos      = shift;
	my $href_cds = shift;
	my $href_pos = shift;

	my $start_pos;
	my $end_pos;
	my $phase = "-1";
	my $codon;

	foreach my $start_pos_cds ( keys %{ %$href_cds{$seqid}->{$strand} } ){

		$start_pos = $start_pos_cds;

		my @table = keys %{ %$href_cds{$seqid}->{$strand}->{$start_pos} } ;
		$end_pos = $table[0];

		# If $pos greater than $start_pos AND $pos lower than $ned_pos
		if ( $pos >= $start_pos && $pos <= $end_pos){

			# Get phase
			$phase = %$href_cds{$seqid}->{$strand}->{$start_pos}->{$end_pos} ;

		}

		if ($phase ne "-1"){
			last;
		}

	}

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
	} elsif ( ($pos - $start_pos) % 3 == 1 ){
		if ($phase == 0){
			$codon = lc(%$href_pos{$seqid}->{$pos-1}).uc(%$href_pos{$seqid}->{$pos}).lc(%$href_pos{$seqid}->{$pos+1});
		} elsif ($phase == 1){
			$codon = uc(%$href_pos{$seqid}->{$pos}).lc(%$href_pos{$seqid}->{$pos+1}).lc(%$href_pos{$seqid}->{$pos+2});
		} elsif ($phase == 2){
			$codon = lc(%$href_pos{$seqid}->{$pos-2}).lc(%$href_pos{$seqid}->{$pos-1}).uc(%$href_pos{$seqid}->{$pos});
		} else {
			$codon = "NA";
		}
	} else { # elsif ( ($pos - $start_pos) % 3 == 2 ){
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
my $outdir  = "NOTDEFINED";
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

if( $help || $fasta eq "NOTDEFINED" || $cds eq "NOTDEFINED" || $outdir eq "NOTDEFINED" ) {
	usage();
}

################################################################################

################
# START SCRIPT #
################

print "\n##############################\n# BEGIN $0 #\n##############################\n\n" ;

################################################################################

my %hash_pos;
my %hash_cds;

if ( $verbose ){ print "[VERBOSE MODE]---> Stored information from CDS file in an hash\n" ; }

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

		$hash_cds{$seqid}{$strand}{$start}{$end} = $phase;

	}

	close( $FH_cds ) ;

} else {
	warn "Could not open file '$cds' $!";
}

if ( $verbose ){ print "[VERBOSE MODE]---> Stored information from FASTA file in an hash\n" ; }

if ( open( my $FH_fasta, '<', $fasta ) ) {

	# Process each line
	while ( my $line = <$FH_fasta> ) {

		chomp $line;

		my @lines    = split "\t", $line;
		my $seqid    = $lines[0] ;
		my $pos      = $lines[1] ;
		my $nuc_plus = $lines[2] ;

		$hash_pos{$seqid}{$pos} = $nuc_plus;

	}

	close( $FH_fasta ) ;

} else {
	warn "Could not open file '$fasta' $!";
}

################################################################################

my $href_pos = \%hash_pos;
my $href_cds = \%hash_cds;

################################################################################

my $outfile_pos = "$outdir/info_from_fasta_complete.tsv";

open( my $FH_pos, '>>', $outfile_pos ) or die "Could not open file '$outfile_pos' $!" ;

if ( $verbose ){ print "[VERBOSE MODE]---> Calculate missing fields\n" ; }

# Process each seqid
foreach my $seqid ( keys %{ $href_pos } ) {

	# Process each position
	foreach my $pos ( keys %{ %$href_pos{$seqid} }) {

		# Nucleotide + and -
		my $nuc_plus    = $href_pos->{$seqid}{$pos}; # Get nucleotide +
		my $nuc_minus   = complement($nuc_plus);     # Get nucleotide -

		# Codon + and -
		my $codon_plus  = codon($seqid, '+', $pos, $href_cds, $href_pos); # Get codon +
		my $codon_minus = codon($seqid, '-', $pos, $href_cds, $href_pos); # Get codon -

		# Amino acid + and -
		my $aa_plus     = amino_acid($codon_plus);  # Get amino acid +
		my $aa_minus    = amino_acid($codon_minus); # Get amino acid -

		# Print line in output file
		print $FH_pos $seqid."\t".$pos."\t".$nuc_plus."\t".$codon_plus."\t".$aa_plus."\t".$nuc_plus."\t".$codon_minus."\t".$aa_minus."\n";

	}
}

close( $FH_pos ) ;

################################################################################

##############
# END SCRIPT #
##############

print "\n############################\n# END $0 #\n############################\n" ;
