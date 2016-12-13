# README

## Description

## Dependencies

- Softwares:
	- _samtools_

- Perl packages:
	- _Getopt::Long_
	- _List::Util qw[min max]_
	- _List::Compare_

## Intall

1. `git clone` [https://github.com/thbtmntgn/project](https://github.com/thbtmntgn/project)
2. `cd projet/sources/`
3. Use script(s)
	- `bash check_fasta_gff.sh` for example

## Scripts

### Script 1 : check_fasta_gff.sh

#### Description

- Check concordance between a FASTA file and its affiliated GFF file :
	- compare sequence IDs
	- compare sequence lengths (FASTA vs. GFF)
	- compare sequence lengths (minimal sequence length)

- Output files (optional files between []):
	- a corrected FASTA file
	- a corrected GFF file
	- a file containing sequence IDS from corrected FASTA and GFF file
	- [a file containing the concordant sequence IDs (same length in FASTA and GFF)]
	- [a file containing the discordant sequence IDs (different length in FASTA and GFF)]
	- [a file containing the 'lower than minimal sequence length' concordant sequence IDs]
	- [a file containing the sequence IDs present in FASTA file only]
	- [a file containing the sequence IDs present in GFF file only]

#### Usage

- `check_fasta_gff.sh -f FASTA_FILE -g GFF_FILE -o OUTDIR [-m MIN_SEQ_LENGTH] [-c] [-v]`
- `check_fasta_gff.sh -h`

- Required options :
	- **-f** file.fasta
	- **-g** file.gff
	- **-o** output directory

- Optionnal options :
	- **-m** minimum sequence length        [by default : 1]
	- **-c** if files are compressed (gzip) [by default : not compressed]

- Help :
	- **-v** to activate verbose mode       [by default : not activated]
	- **-h** to print this help

### Script 2 : check_fasta_gff.pl

#### Description

- This script needs 2 input files :
	- a 2-column-description file containing the name and the length of each seqid from a FASTA file
	- a GFF file

- It checks if seqids from the FASTA file are in the GFF file too.
- It also checks if the length of each seqid is concordant between FASTA and GFF file

#### Usage

- `check_fasta_gff.pl -d DESCRIPTION_FASTA_FILE -g GFF_FILE -o OUTDIR [-v]`
- `check_fasta_gff.pl --description DESCRIPTION_FASTA_FILE --gff GFF_FILE --outdir OUTDIR [--verbose]`
- `check_fasta_gff.pl -h`
- `check_fasta_gff.pl --help`

- Required options:
	- **-d** | **--description** : description FASTA file (seqid + seqlength)
	- **-g** | **--gff**         : GFF file
	- **-o** | **--outdir**      : output directory

- Help:
	- **-v** | **--verbose**     : activate verbose mode
	- **-h** | **--help**        : print this help

### Script 3 : extract_info_from_fasta_gff.sh

#### Description

- This scripts needs 2 input files:
	- a FASTA file
	- a GFF file

- It checks and compare seqid names and seqids length from FASTA and GFF to:
	- focus on seqids in common between FASTA and GFF file
	- discard discordant seqids a.k.a seqids with different length in FASTA and GFF file
	- discard 'too short' seqids based on -m option

#### Usage

- `extract_info_from_fasta_gff.sh -f FASTA_FILE -g GFF_FILE -o OUTDIR [-p PREFIX] [-v]``
- `extract_info_from_fasta_gff.sh [-h]`

- Required options:
	- **-f** : FASTA file
	- **-g** : GFF file
	- **-o** : output directory

- Optionnal options:
	- **-p** : 'PREFIX' to get feature ID from column 9 [by default : 'ID']

- Help :
	- **-v** : to activate verbose mode                 [by default : not activated]
	- **-h** : print this help"

### Script 4 : extract_info_from_gff.pl

#### Description

- Extract information from a GFF file.
- Only 'gene' and 'exon' features are handled.
- The following informations are extracted :
	- chromosome/sequence ID
 	- strand orientation
	- start position
	- end position
	- feature type ('gene' or 'exon' only)
	- feature ID (based on -p|--prefix option, by default : 'ID')

#### Usage

- Required options:
	- **-g** | **--gff**     : GFF file
	- **-p** | **--prefix**  : PREFIX to select the field used in attributes GFF column 9 to identify features
	- **-o** | **--outdir**  : output directory

- Help:
	- **-v** | **--verbose** : activate verbose mode
	- **-h** | **--help**    : print this help

### .bash_bioinfo

#### Description

- A file containing bioinformatic shell aliases and functions
- Available here : [https://github.com/thbtmntgn/bash_bioinfo](https://github.com/thbtmntgn/bash_bioinfo)
