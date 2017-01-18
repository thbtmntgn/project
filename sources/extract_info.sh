#!/usr/local/bin/bash
set -u

############
# FUNTIONS #
############

function USAGE() {

	echo -e "\n#########################\n# BEGIN $( basename ${0} ) #\n#########################\n"

	printf "Usage:\n\t%s -f FASTA_FILE -g GFF_FILE -o OUTDIR [-p PREFIX] [-v]\n" $( basename ${0} )
	printf "\t%s [-h]\n\n" $( basename ${0} )

	cat <<EOF

	Required options:
		-f : FASTA file
		-g : GFF file
		-o : output directory

	Optionnal options:
		-p : 'PREFIX' to get feature ID from column 9 [by default : 'ID']

	Help :"
		-v : to activate verbose mode                 [by default : not activated]
		-h : print this help"

Description:

	This scripts needs 2 input files:
	- a FASTA file
	- a GFF file

	It checks and compare seqid names and seqids length from FASTA and GFF to:
	- focus on seqids in common between FASTA and GFF file
	- discard discordant seqids a.k.a seqids with different length in FASTA and GFF file
	- discard 'too short' seqids based on -m option

EOF

	echo -e "\n#######################\n# END $( basename ${0} ) #\n#######################\n"

	exit ${1:-0}

}

#####################
# BY DEFAULT VALUES #
#####################

FASTA_PATH="NOTDEFINED"
GFF_PATH="NOTDEFINED"
OUTDIR="NOTDEFINED"
PREFIX="ID"
VERBOSE="NO"

##################
# OPTION PARSING #
##################

while getopts ":vhf:g:p:o:" OPTION
do
	case ${OPTION} in
		f)
			FASTA_PATH=${OPTARG}
			FASTA_FULLNAME=$( basename ${FASTA_PATH} )
			FASTA_NAME=${FASTA_FULLNAME%%.*}
			FASTA_EXTENSION=${FASTA_FULLNAME#*.}
			;;
		g)
			GFF_PATH=${OPTARG}
			GFF_FULLNAME=$( basename ${GFF_PATH} )
			GFF_NAME=${GFF_FULLNAME%%.*}
			GFF_EXTENSION=${GFF_FULLNAME#*.}
			;;
		p)
			PREFIX=${OPTARG}
			;;
		o)
			OUTDIR=${OPTARG}
			mkdir -p ${OUTDIR}
			#-p option
				# Create intermediate directories as required.
				# With this option specified, no error will be reported if a directory given as an operand already exists.
			;;
		v)
			VERBOSE="YES"
			;;
		h)
			USAGE
			;;
		:)
			echo -e "Error: option -${OPTARG} requires an argument."
			exit 1
			;;
		\?)
			echo -e "Error : invalid option -${OPTARG}"
			exit 1
			;;
	esac
done

#################
# VERIFICATIONS #
#################

# Check if needed parameters are defined
if [[ ${FASTA_PATH} == "NOTDEFINED" || ${GFF_PATH} == "NOTDEFINED" || ${OUTDIR} == "NOTDEFINED" ]] ; then
	USAGE
	exit 1
fi

################################################################################

################
# BEGIN SCRIPT #
################

echo -e "\n#########################\n# BEGIN $( basename ${0} ) #\n#########################\n"

################################################################################

# Verbose prints
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Verbose mode is activated"                              ; fi
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Your FASTA file is                 : ${FASTA_FULLNAME}" ; fi
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Your GFF file is                   : ${GFF_FULLNAME}"   ; fi
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Your output directory is           : ${OUTDIR}"         ; fi
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Prefix used to identify feature is : ${PREFIX}\n"         ; fi

################################################################################

# If bash_bioinfo already cloned : remove it and clone it again to get the most recent one from Github
if [[ -d "bash_bioinfo" ]] ; then
	CMD1="rm -rf bash_bioinfo/"
	CMD2="git clone 'https://github.com/thbtmntgn/bash_bioinfo' 2> /dev/null"
	CMD3="source 'bash_bioinfo/.bash_bioinfo'"
	if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Remove bash_bioinfo/ directory\n\t---> Commande : ${CMD1}\n" ; fi
	eval ${CMD1}
	if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Get .bash_bioinfo from Github\n\t---> Commande : ${CMD2}\n" ; fi
	eval ${CMD2}
	if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Source .bash_bioinfo\n\t---> Commande : ${CMD3}" ; fi
	eval ${CMD3}
else
	CMD1="git clone 'https://github.com/thbtmntgn/bash_bioinfo' 2> /dev/null "
	CMD2="source 'bash_bioinfo/.bash_bioinfo'"
	if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Get .bash_bioinfo from Github\n\t---> Commande : ${CMD1}\n" ; fi
	eval ${CMD1}
	if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Source .bash_bioinfo\n\t---> Commande : ${CMD2}" ; fi
	eval ${CMD2}
fi

################################################################################

# Info grom FASTA
	# Première table (FASTA) :
	# chromosome/sequence ID
	# position
	# nucléotide (+)
	# codon (+)       [vide à la création, basé sur position exon]
	# acide aminé (+) [vide à la création, basé sur codon (+)]
	# nucléotide (-)  [vide à la création]
	# codon (-)       [vide à la création, basé sur position exon]
	# acide aminé (-) [vide à la création, basé sur codon (-)]

if [[ ${VERBOSE} == "YES" ]] ; then
	CMD="perl extract_info_from_fasta.pl --fasta ${FASTA_PATH} --outdir ${OUTDIR} --verbose"
	echo "${CMD}"
	eval ${CMD}
else
	CMD="perl extract_info_from_fasta.pl --fasta ${FASTA_PATH} --outdir ${OUTDIR}"
	eval ${CMD}
fi

################################################################################

# Info grom GFF
	# Deuxième table (GFF) :
	# chromosome/sequence ID
	# brin
	# position start
	# position end
	# type (gene ou exon)
	# feature ID (premier champ colonne 9 ou champ indiqué par user)

if [[ ${VERBOSE} == "YES" ]] ; then
	CMD="perl extract_info_from_gff.pl --gff ${GFF_PATH} --outdir ${OUTDIR} --prefix ${PREFIX} --verbose"
	echo "${CMD}"
	eval ${CMD}
else
	CMD="perl extract_info_from_gff.pl --gff ${GFF_PATH} --outdir ${OUTDIR} --prefix ${PREFIX}"
	eval ${CMD}
fi

################################################################################

# Calculated fields
# codon (+)       [vide à la création, basé sur position exon]
# acide aminé (+) [vide à la création, basé sur codon (+)]
# nucléotide (-)  [vide à la création]
# codon (-)       [vide à la création, basé sur position exon]
# acide aminé (-) [vide à la création, basé sur codon (-)]

if [[ ${VERBOSE} == "YES" ]] ; then
	CMD="perl calculated_fields.pl --fasta ${OUTDIR}/info_from_fasta_incomplete.tsv --cds ${OUTDIR}/info_from_cds.tsv --outdir ${OUTDIR} --verbose"
	echo "${CMD}"
	eval ${CMD}
else
	CMD="perl calculated_fields.pl --fasta ${OUTDIR}/info_from_fasta_incomplete.tsv --cds ${OUTDIR}/info_from_cds.tsv --outdir ${OUTDIR}"
	eval ${CMD}
fi

##############
# END SCRIPT #
##############

echo -e "\n#######################\n# END $( basename ${0} ) #\n#######################\n"
