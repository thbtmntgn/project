#!/usr/local/bin/perl

use strict;
use warnings;

################################################################################

############
# PACKAGES #
############

use Cwd;
use Getopt::Long;

################################################################################

#############
# FUNCTIONS #
#############

sub usage {

	print <<EOF;

Usage:
	extract_info_from_fasta.pl -f FASTA [-o OUTDIR] [-v]
	extract_info_from_fasta.pl [-h]

	extract_info_from_fasta.pl --fasta FASTA [--outdir OUTDIR] [--verbose]
	extract_info_from_fasta.pl [--help]

Required arguments:
	-f | --fasta   : FASTA file

Optional arguments:
	-o | --outdir  : output directory      [by default: working directory]

Help:
	-h | --help    : print this help
	-v | --verbose : activate verbose mode [by default: not activated]

Description:

	Extract information from a GFF FASTA.
EOF

	exit;

}

################################################################################

############
# DEFAULTS #
############

my $fasta   = "NOTDEFINED" ;
my $outdir  = getcwd()     ;
my $verbose = 0            ;
my $help    = 0            ;

################################################################################

###########
# OPTIONS #
###########

GetOptions (
	"f|fasta=s"  => \$fasta,   # file
	"o|outdir=s" => \$outdir,  # file
	"v|verbose"  => \$verbose, # flag
	"h|help"     => \$help,    # flag
) or die ("Error in command line arguments\n") ;

################################################################################

if( $help || $fasta eq "NOTDEFINED" ) {
	usage();
}

################################################################################

################
# START SCRIPT #
################

print STDERR "\n# BEGIN extract_info_from_fasta.pl\n" ;

################################################################################

if ( $verbose ){
	print STDERR "\t[VERBOSE] ---> FASTA file      : ".$fasta."\n"    ;
	print STDERR "\t[VERBOSE] ---> Output diretory : ".$outdir."\n" ;
}

################################################################################

my $outfile = "$outdir/info_from_fasta_incomplete.tsv";

my $seqid;
my $pos = 0;
my $last_pos = 0;

open( my $FH_fasta_out, '>>', $outfile ) or die "Could not open file '$outfile' $!" ;

if ( open( my $FH_fasta_in, '<', $fasta ) ) {

	if ( $verbose ){ print STDERR "\t[VERBOSE] ---> Process each sequence\n"; }

	# Process each line
	while ( my $line = <$FH_fasta_in> ) {

		chomp $line;

		if ( $line =~ /^>(\S+)/ ){
			$seqid = $1;
			# print STDERR "\t".$seqid."\n";
			$pos = 1;
		} else {
			foreach my $nuc (split //, $line) {
				print $FH_fasta_out $seqid."\t".$pos."\t".$nuc."\n";
				$pos = $pos + 1;
			}
		}
	}

	close( $FH_fasta_in ) ;

} else {
	warn "Could not open file '$fasta' $!";
}

close( $FH_fasta_out ) ;

################################################################################

##############
# END SCRIPT #
##############

print STDERR "# END extract_info_from_fasta.pl\n\n"; ;
