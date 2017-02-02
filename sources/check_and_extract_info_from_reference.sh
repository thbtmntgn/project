#!/usr/local/bin/bash
set -u

############
# FUNTIONS #
############

function USAGE() {

	printf "Usage:\n\t%s -f FASTA -g GFF -d DB_NAME [-o DIRECTORY] [-m LENGTH] [-p PREFIX] [-c] [-v]\n" $( basename ${0} )
	printf "\t%s -h\n\n" $( basename ${0} )

	cat <<EOF

Required arguments :
	-f : FASTA file
	-g : GFF file
	-d : database name

Optional arguments:
	-c : if files are compressed (gzip)                     [by default: not compressed]
	-m : minimum sequence length                            [by default: 1]
	-o : output directory                                   [by default: working directory]
	-p : 'PREFIX' to extract the feature ID in GFF column 9 [by default : 'ID']

Help :"
	-h print this help
	-v to activate verbose mode                             [by default : not activated]

Description:

	TO BE COMPLETED!
EOF

	exit ${1:-0}

}

#####################
# BY DEFAULT VALUES #
#####################

FASTA_PATH="NOTDEFINED"
GFF_PATH="NOTDEFINED"

OUTDIR=$( pwd )
PREFIX="ID"
MIN_LENGTH=1
COMPRESSED="NO"
VERBOSE="NO"

##################
# OPTION PARSING #
##################

while getopts ":vhcf:g:o:m:p:" OPTION
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
		m)
			MIN_LENGTH=${OPTARG}
			;;
		c)
			COMPRESSED="YES"
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
if [[ ${FASTA_PATH} == "NOTDEFINED" || ${GFF_PATH} == "NOTDEFINED" ]] ; then
	USAGE
	exit 1
fi

################################################################################

################
# BEGIN SCRIPT #
################

echo -e "\n# BEGIN $( basename ${0} )"

################################################################################

################################################################################
#
# check_fasta_gff.sh
#
################################################################################

if [[ ${VERBOSE} == "NO" ]] ; then
	if [[ ${COMPRESSED} == "NO" ]] ; then
		CMD="check_fasta_gff.sh -f ${FASTA_PATH} -g ${GFF_PATH} -o ${OUTDIR}"
	else
		CMD="check_fasta_gff.sh -f ${FASTA_PATH} -g ${GFF_PATH} -o ${OUTDIR} -c"
	fi
else
	if [[ ${COMPRESSED} == "NO" ]] ; then
		CMD="check_fasta_gff.sh -f ${FASTA_PATH} -g ${GFF_PATH} -o ${OUTDIR} -v"
	else
		CMD="check_fasta_gff.sh -f ${FASTA_PATH} -g ${GFF_PATH} -o ${OUTDIR} -c -v"
	fi
fi

if [[ ${VERBOSE} == "YES" ]] ; then echo -e "\t[VERBOSE COMMAND] ---> ${CMD}" ; fi
eval ${CMD}

################################################################################
#
# extract_info_reference.sh
#
################################################################################

if [[ ${VERBOSE} == "NO" ]] ; then
	CMD="extract_info_reference.sh -f ${OUTDIR}/filtered_${FASTA_FULLNAME} -g ${OUTDIR}/filtered_${GFF_FULLNAME} -p ${PREFIX} -o ${OUTDIR}"
else
	CMD="extract_info_reference.sh -f ${OUTDIR}/filtered_${FASTA_FULLNAME} -g ${OUTDIR}/filtered_${GFF_FULLNAME} -p ${PREFIX} -o ${OUTDIR} -v"
fi
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "\t[VERBOSE COMMAND] ---> ${CMD}" ; fi
eval ${CMD}

##############
# END SCRIPT #
##############

echo -e "# END $( basename ${0} )\n"
