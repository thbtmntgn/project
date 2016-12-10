#!/usr/local/bin/bash
set -u

############
# FUNTIONS #
############

function USAGE() {

	echo -e "\n########################################\n# BEGIN $( basename ${0} ) #\n########################################\n"

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

EOF

	echo -e "\n######################################\n# END $( basename ${0} ) #\n######################################\n"

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

echo -e "\n########################################\n# BEGIN $( basename ${0} ) #\n########################################\n"

################################################################################

# Verbose prints
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Verbose mode is activated"                              ; fi
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Your FASTA file is                 : ${FASTA_FULLNAME}" ; fi
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Your GFF file is                   : ${GFF_FULLNAME}"   ; fi
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Your output directory is           : ${OUTDIR}"         ; fi
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Prefix used to identify feature is : ${PREFIX}"         ; fi

################################################################################

# If bash_bioinfo already cloned : remove it and clone it again to get the most recent one from Github
if [[ -d "bash_bioinfo" ]] ; then
	CMD1="rm -rf bash_bioinfo/"
	CMD2="git clone 'https://github.com/thbtmntgn/bash_bioinfo' 2> /dev/null"
	CMD3="source 'bash_bioinfo/.bash_bioinfo'"
	if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Remove bash_bioinfo/ directory\n\t---> Commande : ${CMD1}\n" ; fi
	eval ${CMD1}
	if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Get .bash_bioinfo from Github\n\t---> Commande : ${CMD2}" ; fi
	eval ${CMD2}
	if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Source .bash_bioinfo\n\t---> Commande : ${CMD3}\n" ; fi
	eval ${CMD3}
else
	CMD1="git clone 'https://github.com/thbtmntgn/bash_bioinfo' 2> /dev/null "
	CMD2="source 'bash_bioinfo/.bash_bioinfo'"
	if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Get .bash_bioinfo from Github\n\t---> Commande : ${CMD1}" ; fi
	eval ${CMD1}
	if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Source .bash_bioinfo\n\t---> Commande : ${CMD2}\n" ; fi
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

POSITION=1

fadesc ${FASTA_PATH} | cut -f1 > ${OUTDIR}/seqids.list

while read SEQID
do

	faget ${FASTA_PATH} <( echo ${SEQID} ) | grep -v ">" | grep -o . | while read NUCLEOTIDE ; do echo -e "${SEQID}\t${POSITION}\t${NUCLEOTIDE}" >> ${OUTDIR}/info_from_fasta.tsv ; POSITION=$(( ${POSITION} + 1 )) ; done
		# faget : get sequence corresponding to SEQID
		# grep -v ">" : discard header line
		# grep -o . : character by character
		# while read NUCLEOTIDE ... : print line "seqid + position + nucleotide"

done < ${OUTDIR}/seqids.list

rm ${OUTDIR}/seqids.list

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
	perl extract_info_from_gff.pl --gff ${GFF_PATH} --outdir ${OUTDIR} --prefix ${PREFIX} --verbose
else
	perl extract_info_from_gff.pl --gff ${GFF_PATH} --outdir ${OUTDIR} --prefix ${PREFIX}
fi

################################################################################

##############
# END SCRIPT #
##############

echo -e "\n######################################\n# END $( basename ${0} ) #\n######################################\n"
