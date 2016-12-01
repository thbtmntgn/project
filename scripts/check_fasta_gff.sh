#!/usr/local/bin/bash
set -u

source "/Users/Thibaut/.bash_bioinfo"

############
# FUNTIONS #
############

function USAGE() {
	printf "Usage:\n %s -f FASTA_FILE -g GFF_FILE -o OUTDIR [-c] [-v] [-h]\n\n" $( basename ${0} )
	echo -e "Required arguments :"
	echo -e " -f file.fasta"
	echo -e " -g file.gff"
	echo -e " -o output directory"
	echo
	echo -e "Options :"
	echo -e " -m minimum sequence length"
	echo -e " -c if files are compressed (gzip)"
	echo -e " -v to activate verbose mode"
	echo -e " -h to print this help"
	echo
	exit ${1:-0}
}

#####################
# BY DEFAULT VALUES #
#####################

FASTA_PATH="NOTDEFINED"
GFF_PATH="NOTDEFINED"
OUTDIR="NOTDEFINED"
MIN_LENGTH=1
COMPRESSED="NO"
VERBOSE="NO"

##################
# OPTION PARSING #
##################

while getopts ":f:g:o:m:cvh" OPTION
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

echo -e "\n############################\n# BEGIN $( basename ${0} ) #\n############################\n"

################################################################################

#################
# VERIFICATIONS #
#################

# Check if needed parameters are defined
if [[ ${FASTA_PATH} == "NOTDEFINED" || ${GFF_PATH} == "NOTDEFINED" || ${OUTDIR} == "NOTDEFINED" ]] ; then
	USAGE
	exit 1
fi

# Check file compression
if [[ ${COMPRESSED} == "YES" ]] ; then
	# If files are compressed, uncompressed them in output directory
	gunzip -kc ${FASTA_PATH} > "${OUTDIR}/${FASTA_NAME}.fasta"
	gunzip -kc ${GFF_PATH} > "${OUTDIR}/${GFF_NAME}.gff"
	FASTA="${OUTDIR}/${FASTA_NAME}.fasta"
	GFF="${OUTDIR}/${GFF_NAME}.gff"
elif [[ ${COMPRESSED} == "NO" ]] ; then
	# If files are uncompressed, copy them in output directory
	cp ${FASTA_PATH} "${OUTDIR}/${FASTA_NAME}.fasta"
	cp ${GFF_PATH} "${OUTDIR}/${GFF_NAME}.gff"
	FASTA="${OUTDIR}/${FASTA_NAME}.fasta"
	GFF="${OUTDIR}/${GFF_NAME}.gff"
fi

# Verbose prints
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Verbose mode is activated"              ; fi
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Your FASTA file is : ${FASTA_FULLNAME}" ; fi
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Your GFF file is   : ${GFF_FULLNAME}"   ; fi
if [[ ${VERBOSE} == "YES" ]] ; then
	if [[ ${COMPRESSED} == "YES" ]] ; then echo -e "[VERBOSE MODE]--->  FASTA and GFF files are compressed"     ; fi
	if [[ ${COMPRESSED} == "NO" ]]  ; then echo -e "[VERBOSE MODE]--->  FASTA and GFF files are not compressed" ; fi
fi
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Minimal sequence length is : ${MIN_LENGTH}" ; fi
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "[VERBOSE MODE]---> Your output directory is   : ${OUTDIR}\n"   ; fi

################################################################################

# Get sequence ID + sequence length from FASTA file
CMD="fadesc ${FASTA} > ${FASTA_NAME}.desc"
if [[ ${VERBOSE} == "YES" ]] ; then
	echo -e "[VERBOSE MODE]--->  Get sequence ID + sequence length from FASTA file"
	echo -e "\t--->  Commande : ${CMD}\n" ; fi
eval ${CMD}

################################################################################

# Compare and filter seqids from FASTA and GFF
if [[ ${VERBOSE} == "YES" ]] ; then
	CMD="perl check_fasta_gff.pl --description ${FASTA_NAME}.desc --gff ${GFF} --outdir ${OUTDIR} --verbose"
	echo -e "[VERBOSE MODE]--->  Compare and filter seqids from FASTA and GFF"
	echo -e "\t--->  Commande : ${CMD}\n"
else
	CMD="perl check_fasta_gff.pl --description ${FASTA_NAME}.desc --gff ${GFF} --outdir ${OUTDIR}"
fi

eval ${CMD}

################################################################################

# If good common seqids are retrieved, sort them by sequence length from FASTA (longest to smallest)
if [[ -e "${OUTDIR}/seqids_in_common_concordant.desc" ]] ; then
	CMD="cat ${OUTDIR}/seqids_in_common_concordant.desc | sort -nr -k2 > ${OUTDIR}/seqids_in_common_concordant_sorted.desc"
	if [[ ${VERBOSE} == "YES" ]] ; then
		echo -e "[VERBOSE MODE]--->  If common seqids (with concordant length between FASTA and GFF) are retrieved, they are sorted by FASTA sequence length (longest to smallest)"
		echo -e "\t--->  Commande : ${CMD}\n"
	fi
	eval ${CMD}
fi

################################################################################

# Get seqids from LIST file
CMD="cat ${OUTDIR}/seqids_in_common_concordant_sorted.desc | awk '{ if (\$2 >= ${MIN_LENGTH}){ print \$0 } }' > ${OUTDIR}/filtered_seqids.desc"
if [[ ${VERBOSE} == "YES" ]] ; then
	echo -e "[VERBOSE MODE]--->  Get seqids with length equal or greater than ${MIN_LENGTH} pb"
	echo -e "\t--->  Commande : ${CMD}\n"
fi
eval ${CMD}

# Get too short SEQIDS
CMD="cat ${OUTDIR}/seqids_in_common_concordant_sorted.desc | awk '{ if (\$2 < ${MIN_LENGTH}){ print \$0 } }' > ${OUTDIR}/seqids_in_common_concordant_too_short.desc"
if [[ ${VERBOSE} == "YES" ]] ; then
	echo -e "[VERBOSE MODE]--->  Get seqids with length lower than ${MIN_LENGTH} pb"
	echo -e "\t--->  Commande : ${CMD}\n"
fi
eval ${CMD}

SEQIDS_COMMON_NUM=$( cat ${OUTDIR}/seqids_in_common_concordant_sorted.desc | wc -l | awk '{print $1}' )
SEQIDS_TOO_SHORT_NUM=$( cut -f1 ${OUTDIR}/seqids_in_common_concordant_too_short.desc | wc -l | awk '{print $1}' )
SEQIDS_FILTERED_NUM=$( cut -f1 ${OUTDIR}/filtered_seqids.desc | wc -l | awk '{print $1}' )
echo -e "---> Concordant seqids           : ${SEQIDS_COMMON_NUM}"
echo -e "---> Concordant seqids too short : ${SEQIDS_TOO_SHORT_NUM}"
echo -e "---> Keeped seqids               : ${SEQIDS_FILTERED_NUM}\n"

# Index FASTA file
CMD="samtools faidx ${FASTA}"
if [[ ${VERBOSE} == "YES" ]] ; then
	echo -e "[VERBOSE MODE]--->  Index FASTA file"
	echo -e "\t--->  Commande : ${CMD}\n"
fi
eval ${CMD}

# Get only seqid field
CMD="cut -f1 ${OUTDIR}/filtered_seqids.desc > ${OUTDIR}/filtered_seqids.list"
if [[ ${VERBOSE} == "YES" ]] ; then
	echo -e "[VERBOSE MODE]--->  Get only seqid field"
	echo -e "\t--->  Commande : ${CMD}\n"
fi
eval ${CMD}

# Get FASTA sequences with seqids in LIST
CMD="xargs samtools faidx ${FASTA} < ${OUTDIR}/filtered_seqids.list > ${OUTDIR}/filtered_${FASTA_NAME}.${FASTA_EXTENSION}"
if [[ ${VERBOSE} == "YES" ]] ; then
	echo -e "[VERBOSE MODE]--->  Get FASTA sequences with seqids in ${OUTDIR}/filtered_seqids.list"
	echo -e "\t--->  Commande : ${CMD}\n"
fi
eval ${CMD}

################################################################################

# Get GFF sequences with seqids in LIST
CMD="grep -F -w -f ${OUTDIR}/filtered_seqids.list ${GFF} > ${OUTDIR}/filtered_${GFF_NAME}.${GFF_EXTENSION}"
if [[ ${VERBOSE} == "YES" ]] ; then
	echo -e "[VERBOSE MODE]--->  Get GFF sequences with seqids in ${OUTDIR}/filtered_seqids.list"
	echo -e "\t--->  Commande : ${CMD}\n"
fi
eval ${CMD}

################################################################################
# Check seqids number in LIST, new FASTA and new GFF

FASTA_SEQID_NUM=$( grep -c ">" ${OUTDIR}/filtered_${FASTA_NAME}.${FASTA_EXTENSION} )
GFF_SEQID_NUM=$( cat ${OUTDIR}/filtered_${GFF_NAME}.${GFF_EXTENSION} | cut -f1 | sort -u | wc -l | awk '{print $1}' )

if [[ ${SEQIDS_FILTERED_NUM} -eq ${FASTA_SEQID_NUM} && ${SEQIDS_FILTERED_NUM} -eq ${GFF_SEQID_NUM} ]] ; then
	echo -e "---> ALL GOOD !"
	echo -e "\t--->  Keeped seqids at the end : ${SEQIDS_FILTERED_NUM}"
	echo -e "\t--->  Seqids in final fasta    : ${FASTA_SEQID_NUM}"
	echo -e "\t--->  Seqids in final gff      : ${GFF_SEQID_NUM}"
else
	echo -e "---> PROBLEM ! !"
	echo -e "\t--->  Keeped seqids at the end : ${SEQIDS_FILTERED_NUM}"
	echo -e "\t--->  Seqids in final fasta    : ${FASTA_SEQID_NUM}"
	echo -e "\t--->  Seqids in final gff      : ${GFF_SEQID_NUM}"
fi

################################################################################

# Delete temporary files
rm ${FASTA}
rm ${GFF}
rm ${FASTA}.fai
rm ${OUTDIR}/seqids_in_common_concordant_sorted.desc

##############
# END SCRIPT #
##############

echo -e "\n##########################\n# END $( basename ${0} ) #\n##########################\n\n"
