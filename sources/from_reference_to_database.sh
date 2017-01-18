#!/usr/local/bin/bash
set -u

############
# FUNTIONS #
############

function USAGE() {
	printf "Usage:\n\t%s -f FASTA -g GFF -d DATABASE -o DIRECTORY [-m LENGTH] [-p PREFIX] [-c] [-v]\n" $( basename ${0} )
	printf "\t%s -h\n\n" $( basename ${0} )
	echo -e "Required arguments :"
	echo -e "\t-f FASTA file"
	echo -e "\t-g GFF file"
	echo -e "\t-d database name"
	echo -e "\t-o output directory"
	echo
	echo -e "Options :"
	echo -e "\t-c if FASTA and GFF are compressed (gzip)"
	echo -e "\t-m minimum sequence length to be conserved"
	echo -e "\t-p prefix to select ID field in GFF column 9"
	echo
	echo -e "Help :"
	echo -e "\t-v to activate verbose mode [by default : not activated]"
	echo -e "\t-h print this help"
	exit ${1:-0}
}

#####################
# BY DEFAULT VALUES #
#####################

FASTA_PATH="NOTDEFINED"
GFF_PATH="NOTDEFINED"
DATABASE="NOTDEFINED"
OUTDIR="NOTDEFINED"
PREFIX="ID"
MIN_LENGTH=1
COMPRESSED="NO"
VERBOSE="NO"

##################
# OPTION PARSING #
##################

while getopts ":vhcf:g:d:o:m:p:" OPTION
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
		d)
			DATABASE=${OPTARG}
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

################
# BEGIN SCRIPT #
################

echo -e "\n#######################################\n# BEGIN $( basename ${0} ) #\n#######################################\n"

################################################################################

#################
# VERIFICATIONS #
#################

# Check if needed parameters are defined
if [[ ${FASTA_PATH} == "NOTDEFINED" || ${GFF_PATH} == "NOTDEFINED" || ${DATABASE} == "NOTDEFINED" || ${OUTDIR} == "NOTDEFINED" ]] ; then
	USAGE
	exit 1
fi

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

echo "${CMD}"
eval ${CMD}

################################################################################
#
# extract_info.sh
#
################################################################################

if [[ ${VERBOSE} == "NO" ]] ; then
	CMD="extract_info.sh -f ${OUTDIR}/filtered_${FASTA_FULLNAME} -g ${OUTDIR}/filtered_${GFF_FULLNAME} -p ${PREFIX} -o ${OUTDIR}"
else
	CMD="extract_info.sh -f ${OUTDIR}/filtered_${FASTA_FULLNAME} -g ${OUTDIR}/filtered_${GFF_FULLNAME} -p ${PREFIX} -o ${OUTDIR} -v"
fi

echo "${CMD}"
eval ${CMD}

################################################################################
#
# create_database.sh
#
################################################################################

if [[ ${VERBOSE} == "NO" ]] ; then
	CMD="create_database.sh -d ${DATABASE} -o ${OUTDIR}"
else
	CMD="create_database.sh -d ${DATABASE} -o ${OUTDIR} -v"
fi

echo "${CMD}"
eval ${CMD}

################################################################################
#
# import_reference.sh
#
################################################################################

if [[ ${VERBOSE} == "NO" ]] ; then
	CMD="import_reference.sh -d ${DATABASE} -f ${OUTDIR}/info_from_fasta_complete.tsv -g ${OUTDIR}/info_from_gff.tsv -o ${OUTDIR}"
else
	CMD="import_reference.sh -d ${DATABASE} -f ${OUTDIR}/info_from_fasta_complete.tsv -g ${OUTDIR}/info_from_gff.tsv -o ${OUTDIR} -v"
fi

echo "${CMD}"
eval ${CMD}

##############
# END SCRIPT #
##############

echo -e "\n#####################################\n# END $( basename ${0} ) #\n#####################################\n"
