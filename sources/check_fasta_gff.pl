#!/usr/local/bin/perl

use strict;
use warnings;

################################################################################

############
# PACKAGES #
############

use Cwd;
use Getopt::Long;
use List::Util qw[min max];
use List::Compare;

################################################################################

#############
# FUNCTIONS #
#############

sub usage {

	print <<EOF;

Usage:
	check_fasta_gff.pl -d DESCRIPTION -g GFF [-o OUTDIR] [-v]
	check_fasta_gff.pl -h

	check_fasta_gff.pl --description DESCRIPTION --gff GFF [--outdir OUTDIR] [--verbose]
	check_fasta_gff.pl --help

Required arguments:
	-d | --description : description FASTA file (seqid + seqlength)
	-g | --gff         : GFF file

Optional arguments:
	-o | --outdir      : output directory

Help:
	-h | --help        : print this help
	-v | --verbose     : activate VERBOSE

Description:

	This script needs 2 input files:
	- a 2-column-description file containing the name and the length of each seqid from a FASTA file
	- a GFF file

	It checks if seqids from the FASTA file are in the GFF file too.
	It also checks if the length of each seqid is concordant between FASTA and GFF file

EOF

	exit;

}

################################################################################

############
# DEFAULTS #
############

my $description = "NOTDEFINED";
my $gff         = "NOTDEFINED";
my $outdir      = getcwd();
my $verbose     = 0;
my $help        = 0;

################################################################################

###########
# OPTIONS #
###########

GetOptions (
	"d|description=s" => \$description, # file
	"g|gff=s"         => \$gff,         # file
	"o|outdir=s"      => \$outdir,      # file
	"v|verbose"       => \$verbose,     # flag
	"h|help"          => \$help,        # flag
) or die ("Error in command line arguments\n");

################################################################################

if( $help || $description eq "NOTDEFINED" || $gff eq "NOTDEFINED" ) {
	usage();
}

################################################################################

################
# START SCRIPT #
################

print STDERR "\n# BEGIN check_fasta_gff.pl\n";

################################################################################

# Initialize FASTA and GFF seqid hashes
my %fasta_seqids ; # key : seqid ; value : fasta_length
my %gff_seqids   ; # key : seqid ; value : gff_length


################################################################################

# Read description FASTA file
if ( $verbose ) {
	print STDERR "\t[VERBOSE] ---> Read description FASTA file\n";
	print STDERR "\t[VERBOSE] ---> Process each line\n";
	print STDERR "\t[VERBOSE] ---> Get sequence ID and sequence length\n";
	print STDERR "\t[VERBOSE] ---> Add them to the FASTA seqid hash\n";
}

if ( open( my $FH_desc, '<', $description ) ) {

	# Process each line
	while ( my $row = <$FH_desc> ) {

		# Get sequence ID and sequence length
		chomp $row;
		my @column       = split "\t", $row;
		my $fasta_seqid  = $column[0];
		my $fasta_length = $column[1];

		# Add them to the FASTA seqid hash
		$fasta_seqids{$fasta_seqid} = $fasta_length;

	}

} else {
	warn "Could not open file '$description' $!";
}

################################################################################

# Read description GFF file
if ( $verbose ) {
	print STDERR "\t[VERBOSE] ---> Read description FASTA file\n";
	print STDERR "\t[VERBOSE] ---> Process each line\n";
	print STDERR "\t[VERBOSE] ---> Avoid commented lines\n";
	print STDERR "\t[VERBOSE] ---> Get sequence ID and sequence start and end positions\n";
	print STDERR "\t[VERBOSE] ---> Get the maximal position\n";
	print STDERR "\t[VERBOSE] ---> If sequence ID length IS NOT defined YET\n";
	print STDERR "\t[VERBOSE] ---> Add sequence ID and max to the GFF hash\n";
	print STDERR "\t[VERBOSE] ---> Else, if sequence ID length IS ALREADY defined\n";
	print STDERR "\t[VERBOSE] ---> Get the maximal position between ALREADY DEFINED max and the new max value\n";
	print STDERR "\t[VERBOSE] ---> Add sequence ID and new max to the GFF hash\n";
}

if ( open( my $FH_gff, '<', $gff ) ) {

	# Process each line
	while ( my $row = <$FH_gff>) {

		# Avoid commented lines
		if ( $row !~ /^#/ ) {

			# Get sequence ID and sequence start and end positions
			chomp $row;
			my @column    = split "\t", $row;
			my $gff_seqid = $column[0];
			my $gff_start = $column[3];
			my $gff_end   = $column[4];

			# Get the maximal position
			my $max       = max($gff_start, $gff_end);

			# If sequence ID length IS NOT defined YET
			if ( ! defined $gff_seqids{$gff_seqid} ){

				# Add sequence ID and max to the GFF hash
				$gff_seqids{$gff_seqid} = $max;

			# Else, if sequence ID length IS ALREADY defined
			} else {


				# Get the maximal position between ALREADY DEFINED max and the new max value
				my $new_max = max( $gff_seqids{$gff_seqid}, $max );

				# Add sequence ID and new max to the GFF hash
				$gff_seqids{$gff_seqid} = $new_max;

			}
		}
	}
} else {
	warn "Could not open file '$gff' $!";
}

################################################################################

# Get seqid number in FASTA and GFF
if ( $verbose ) { print STDERR "\t[VERBOSE] ---> Get seqid number in FASTA and GFF\n";}
my $fasta_seqids_num = keys(%fasta_seqids) ;
my $gff_seqids_num   = keys(%gff_seqids)   ;

# Compare seqids from FASTA and GFF
if ( $verbose ) { print STDERR "\t[VERBOSE] ---> Compare seqids from FASTA and GFF\n";}
my $comparaison = List::Compare->new( [ keys %fasta_seqids ], [ keys %gff_seqids ] );

# Get common, specific to FASTA, and specific to GFF seqids
if ( $verbose ) { print STDERR "\t[VERBOSE] ---> Get common, specific to FASTA, and specific to GFF seqids\n";}
my @common_seqids    = $comparaison->get_intersection;
my @seqid_only_fasta = $comparaison->get_unique;
my @seqid_only_gff   = $comparaison->get_complement;

# Get common, specific to FASTA, and specific to GFF seqid number
if ( $verbose ) { print STDERR "\t[VERBOSE] ---> Get common, specific to FASTA, and specific to GFF seqid number\n";}
my $common_seqids_num    = @common_seqids;
my $seqid_only_fasta_num = @seqid_only_fasta;
my $seqid_only_gff_num   = @seqid_only_gff;

# Initialize OK/NON OK lenth common seqid counter
if ( $verbose ) { print STDERR "\t[VERBOSE] ---> Initialize OK/NON OK lenth common seqid counter\n";}
my $length_ok_common_seqid_num     = 0;
my $length_non_ok_common_seqid_num = 0;

# Initialize output files
if ( $verbose ) { print STDERR "\t[VERBOSE] ---> Initialize output files\n";}
my $seqid_common_ok     = "$outdir/seqids_in_common_concordant.desc";
my $seqid_common_non_ok = "$outdir/seqids_in_common_discordant.desc";
my $seqid_fasta_only    = "$outdir/seqids_in_fasta_only.desc";
my $seqid_gff_only      = "$outdir/seqids_in_gff_only.desc";

# Delete files if exist
if ( $verbose ) { print STDERR "\t[VERBOSE] ---> Delete files if exist\n";}
if (-e $seqid_common_ok)    { unlink $seqid_common_ok     ; }
if (-e $seqid_common_non_ok){ unlink $seqid_common_non_ok ; }
if (-e $seqid_fasta_only)   { unlink $seqid_fasta_only    ; }
if (-e $seqid_gff_only)     { unlink $seqid_gff_only      ; }

################################################################################

# If common seqid number is GREATER THAN zero
if ( $verbose ) {
	print STDERR "\t[VERBOSE] ---> If common seqid number is GREATER THAN zero\n";
	print STDERR "\t[VERBOSE] ---> Process each common seqid\n";
	print STDERR "\t[VERBOSE] ---> Get sequence length from FASTA and GFF\n";
	print STDERR "\t[VERBOSE] ---> If sequence length from GFF is LOWER or EQUAL to sequence length from FASTA\n";
	print STDERR "\t[VERBOSE] ---> Print in seqid_common_good file\n";
	print STDERR "\t[VERBOSE] ---> Else, if sequence length from GFF is GREATER than sequence length from FASTA\n";
	print STDERR "\t[VERBOSE] ---> Print in seqid_common_bad file\n";
}

if ( $common_seqids_num > 0 ){

	# Process each common seqid
	foreach my $seqid (@common_seqids){

		# Get sequence length from FASTA and GFF
		my $seqid_length_fasta = $fasta_seqids{$seqid};
		my $seqid_length_gff   = $gff_seqids{$seqid};

		# If sequence length from GFF is LOWER or EQUAL to sequence length from FASTA
		if ( $seqid_length_gff <= $seqid_length_fasta ) {

			$length_ok_common_seqid_num++;

			# Print in seqid_common_good file
			open( my $FH_seqid_common_ok, '>>', $seqid_common_ok ) or die "Could not open file '$seqid_common_ok' $!";
			print $FH_seqid_common_ok $seqid."\t".$seqid_length_fasta."\t".$seqid_length_gff."\n";
			close $FH_seqid_common_ok;

		# Else, if sequence length from GFF is GREATER than sequence length from FASTA
		} else {

			$length_non_ok_common_seqid_num++;

			# Print in seqid_common_bad file
			open( my $FH_seqid_common_non_ok, '>>', $seqid_common_non_ok ) or die "Could not open file '$seqid_common_non_ok' $!";
			print $FH_seqid_common_non_ok $seqid."\t".$seqid_length_fasta."\t".$seqid_length_gff."\n";
			close $FH_seqid_common_non_ok;

		}
	}

}

################################################################################

# If FASTA specific seqid number is GREATER THAN zero
if ( $verbose ) {
	print STDERR "\t[VERBOSE] ---> If FASTA specific seqid number is GREATER THAN zero\n";
	print STDERR "\t[VERBOSE] ---> Process each GFF specific seqid\n";
	print STDERR "\t[VERBOSE] ---> Get sequence length from GFF\n";
	print STDERR "\t[VERBOSE] ---> Print in seqid_gff_only file\n";
}

if ( $seqid_only_fasta_num > 0 ){

	# Process each FASTA specific seqid
	open( my $FH_seqid_fasta_only, '>>', $seqid_fasta_only ) or die "Could not open file '$seqid_fasta_only' $!";
	foreach my $seqid (@seqid_only_fasta){

		# Get sequence length from FASTA
		my $seqid_length_fasta = $fasta_seqids{$seqid};

		# Print in seqid_fasta_only file
		print $FH_seqid_fasta_only $seqid."\t".$seqid_length_fasta."\n";

	}
	close $FH_seqid_fasta_only;
}

################################################################################

# If GFF specific seqid number is GREATER THAN zero
if ( $verbose ) {
	print STDERR "\t[VERBOSE] ---> If GFF specific seqid number is GREATER THAN zero\n";
	print STDERR "\t[VERBOSE] ---> Process each GFF specific seqid\n";
	print STDERR "\t[VERBOSE] ---> Get sequence length from GFF\n";
	print STDERR "\t[VERBOSE] ---> Print in seqid_gff_only file\n";
}

if ( $seqid_only_gff_num > 0 ){

	# Process each GFF specific seqid
	open(my $FH_seqid_gff_only, '>>', $seqid_gff_only) or die "Could not open file '$seqid_gff_only' $!";
	foreach my $seqid (@seqid_only_gff){

		# Get sequence length from GFF
		my $seqid_length_gff = $gff_seqids{$seqid};

		# Print in seqid_gff_only file
		print $FH_seqid_gff_only $seqid."\t".$seqid_length_gff."\n";

	}
	close $FH_seqid_gff_only;
}

################################################################################

# Verbose prints
if ( $verbose ){
	print STDERR "\t[VERBOSE] ---> seqids in FASTA      : ".$fasta_seqids_num."\n";
	print STDERR "\t[VERBOSE] ---> seqids in GFF        : ".$gff_seqids_num."\n";
	print STDERR "\t[VERBOSE] ---> seqids in FASTA only : ".$seqid_only_fasta_num."\n";
	print STDERR "\t[VERBOSE] ---> seqids in GFF only   : ".$seqid_only_gff_num."\n";
	print STDERR "\t[VERBOSE] ---> seqids in common     : ".$common_seqids_num."\n";
	print STDERR "\t[VERBOSE]\t---> concordant length : ".$length_ok_common_seqid_num."\n";
	print STDERR "\t[VERBOSE]\t---> discordant length : ".$length_non_ok_common_seqid_num."\n";
}

################################################################################

##############
# END SCRIPT #
##############

print STDERR "# END check_fasta_gff.pl\n\n";;
