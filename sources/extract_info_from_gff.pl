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

	print "\n##################################\n# BEGIN $0 #\n##################################\n" ;

	print <<EOF;

Usage:

	Required options:
		-g | --gff     : GFF file
		-p | --prefix  : PREFIX to select the field used in attributes GFF column 9 to identify features
		-o | --outdir  : output directory

	Help:
		-v | --verbose : activate verbose mode
		-h | --help    : print this help

Description:

	Extract information from a GFF file.
	Only 'gene' and 'exon' features are handled.
	The following informations are extracted :
	- chromosome/sequence ID
 	- strand orientation
	- start position
	- end position
	- feature type ('gene' or 'exon' only)
	- feature ID (based on -p|--prefix option, by default : 'ID')

EOF

	print "\n################################\n# END $0 #\n################################\n" ;

	exit;

}

################################################################################

############
# DEFAULTS #
############

my $gff     = "NOTDEFINED" ;
my $prefix  = "NOTDEFINED" ;
my $outdir  = "NOTDEFINED" ;
my $verbose = 0            ;
my $help    = 0            ;

################################################################################

###########
# OPTIONS #
###########

GetOptions (
	"g|gff=s"    => \$gff,     # file
	"o|outdir=s" => \$outdir,  # file
	"p|prefix=s" => \$prefix,  # file
	"v|verbose"  => \$verbose, # flag
	"h|help"     => \$help,    # flag
) or die ("Error in command line arguments\n") ;

################################################################################

if( $help || $gff eq "NOTDEFINED" || $outdir eq "NOTDEFINED" || $prefix eq "NOTDEFINED" ) {
	usage();
}

################################################################################

################
# START SCRIPT #
################

print "\n##################################\n# BEGIN $0 #\n##################################\n\n" ;

################################################################################


if ( $verbose ){
	print "[VERBOSE MODE]---> GFF file        : ".$gff."\n"    ;
	print "[VERBOSE MODE]---> Prefix used     : ".$prefix."\n" ;
	print "[VERBOSE MODE]---> Output diretory : ".$outdir."\n" ;
}

################################################################################

my $outfile_gff = "$outdir/info_from_gff.tsv";
my $outfile_cds = "$outdir/info_from_cds.tsv";

open( my $FH_info_from_gff, '>>', $outfile_gff ) or die "Could not open file '$outfile_gff' $!" ;
open( my $FH_info_from_cds, '>>', $outfile_cds ) or die "Could not open file '$outfile_cds' $!" ;

if ( open( my $FH_gff, '<', $gff ) ) {

	# Process each line
	while ( my $row = <$FH_gff> ) {

		chomp $row;

		if ( $row !~ /^#/ ){
			my @column     = split "\t", $row;
			my $seqid      = $column[0];
			my $source     = $column[1];
			my $type       = $column[2];
			my $start      = $column[3];
			my $end        = $column[4];
			my $score      = $column[5];
			my $strand     = $column[6];
			my $phase      = $column[7];

			my @attributes = split ";", $column[8];
			my %attributes;
			my @attribute;

			foreach my $attribute ( @attributes ) {
				@attribute = split "=", $attribute;
				$attributes{ $attribute[0] } = $attribute[1];
			}

			if ( $type eq "exon" || $type eq "gene" ){
				if ( exists $attributes{$prefix} ){
					print $FH_info_from_gff $seqid."\t".$strand."\t".$start."\t".$end."\t".$type."\t".$attributes{$prefix}."\n";
				} else {
					print STDERR "\n/!\\ '".$prefix."' is a BAD PREFIX ! All features in GFF do not have it ! Try another one ! /!\\\n" ;
					exit ;
				}
			} elsif ( $type eq "CDS" ){
				if ( exists $attributes{$prefix} ){
					print $FH_info_from_cds $seqid."\t".$strand."\t".$start."\t".$end."\t".$phase."\t".$attributes{$prefix}."\n";
				} else {
					print STDERR "\n/!\\ '".$prefix."' is a BAD PREFIX ! All features in GFF do not have it ! Try another one ! /!\\\n" ;
					exit ;
				}
			}
		}
	}

	close( $FH_gff ) ;

} else {
	warn "Could not open file '$gff' $!";
}

close( $FH_info_from_gff ) ;
close( $FH_info_from_cds ) ;

################################################################################

##############
# END SCRIPT #
##############

print "\n################################\n# END $0 #\n################################\n" ;
