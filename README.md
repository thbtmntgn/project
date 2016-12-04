# README

## .bash_bioinfo

A file containing bioinformatic shell aliases and functions

Available here : https://github.com/thbtmntgn/bash_bioinfo

### Dependencies

- samtools

## Script 1 : check_fasta_gff.sh

Check concordance between a fasta file and its affiliated GFF file :
- compare sequence IDs
- compare sequence lengths (FASTA vs. GFF)
- compare sequence lengths (minimal sequence length)

Output files (optional files between []):
- a corrected FASTA file
- a corrected GFF file
- a file containing sequence IDS from corrected FASTA and GFF file
- [a file containing the concordant sequence IDs (same length in FASTA and GFF)]
- [a file containing the discordant sequence IDs (different length in FASTA and GFF)]
- [a file containing the 'lower than minimal sequence length' concordant sequence IDs]
- [a file containing the sequence IDs present in FASTA file only]
- [a file containing the sequence IDs present in GFF file only]

### Usage

Usage:
- check_fasta_gff.sh -f FASTA_FILE -g GFF_FILE -o OUTDIR [-m MIN_SEQ_LENGTH] [-c] [-v]
- check_fasta_gff.sh -h

Required arguments :
- -f file.fasta
- -g file.gff
- -o output directory

Options :
- -m minimum sequence length        [by default : 1]
- -c if files are compressed (gzip) [by default : not compressed]
- -v to activate verbose mode       [by default : not activated]

Help :
- -h to print this help

### Dependencies :
	- .bash_bioinfo (from https://github.com/thbtmntgn/bash_bioinfo) [no installation needed, handled in the script]
	- check_fasta_gff.pl

## Script 2 : check_fasta_gff.pl

### Usage

Usage :
- check_fasta_gff.pl -d DESCRIPTION_FASTA_FILE -g GFF_FILE -o OUTDIR [-v]
- check_fasta_gff.pl --description DESCRIPTION_FASTA_FILE --gff GFF_FILE --outdir OUTDIR [--verbose]
- check_fasta_gff.pl -h
- check_fasta_gff.pl --help

Options :
- -d | --description : description FASTA file (seqid + seqlength)
- -g | --gff         : GFF file
- -o | --outdir      : output directory
- -v | --verbose     : activate verbose mode
- -h | --help        : print this help

### Dependencies

Perl packages :
- _Getopt::Long_
- _List::Util qw[min max]_
- _List::Compare_
