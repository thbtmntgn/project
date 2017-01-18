#!/usr/local/bin/perl

use strict;
use warnings;

################################################################################

############
# PACKAGES #
############

use Getopt::Long;

################################################################################

#############
# FUNCTIONS #
#############

sub usage {

	print "\n####################################\n# BEGIN $0 #\n####################################\n" ;

	print <<EOF;

Usage:

	Required options:
		-f | --fasta   : FASTA file
		-o | --outdir  : output directory

	Help:
		-v | --verbose : activate verbose mode
		-h | --help    : print this help

Description:

	Extract information from a GFF FASTA.

EOF

	print "\n##################################\n# END $0 #\n##################################\n" ;

	exit;

}

################################################################################

############
# DEFAULTS #
############

my $fasta   = "NOTDEFINED" ;
my $outdir  = "NOTDEFINED" ;
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

if( $help || $fasta eq "NOTDEFINED" || $outdir eq "NOTDEFINED" ) {
	usage();
}

################################################################################

################
# START SCRIPT #
################

print "\n####################################\n# BEGIN $0 #\n####################################\n\n" ;

################################################################################


if ( $verbose ){
	print "[VERBOSE MODE]---> FASTA file      : ".$fasta."\n"    ;
	print "[VERBOSE MODE]---> Output diretory : ".$outdir."\n" ;
}

################################################################################

my $outfile = "$outdir/info_from_fasta_incomplete.tsv";

my $seqid;
my $pos = 0;
my $last_pos = 0;

open( my $FH_fasta, '>>', $outfile ) or die "Could not open file '$outfile' $!" ;

if ( open( my $FH_fasta, '<', $fasta ) ) {

	if ( $verbose ){ print "\n[VERBOSE MODE]---> Process each sequence\n"; }

	# Process each line
	while ( my $line = <$FH_fasta> ) {

		chomp $line;

		if ( $line =~ /^>(\S+)/ ){
			$seqid = $1;
			if ( $verbose ){
				print "\t".$seqid."\n";
			}
			$pos = 1;
		} else {
			foreach my $nuc (split //, $line) {
				# print $seqid."\t".$pos."\t".$nuc."\n";
				print $FH_fasta $seqid."\t".$pos."\t".$nuc."\n";
				$pos = $pos + 1;
			}
		}
	}

	close( $FH_fasta ) ;

} else {
	warn "Could not open file '$fasta' $!";
}

close( $FH_fasta ) ;

################################################################################

##############
# END SCRIPT #
##############

print "\n##################################\n# END $0 #\n##################################\n" ;
