#!/usr/local/bin/bash
set -u

############
# FUNTIONS #
############

function USAGE() {

	printf "Usage:\n\t%s -f FASTA_FILE -g GFF_FILE [-c] [-m MIN_SEQ_LENGTH] [-o OUTDIR] [-v]\n" $( basename ${0} )
	printf "\t%s [-h]\n" $( basename ${0} )

	cat <<EOF

Required arguments:
	-f : FASTA file
	-g : GFF file

Optional arguments:
	-c : if files are compressed (gzip) [by default: not compressed]
	-m : minimum sequence length        [by default: 1]
	-o : output directory               [by default: working directory]

Help:
	-h : to print this help
	-v : to activate VERBOSE       [by default: not activated]

Description:

	This scripts needs 2 input files:
	- a FASTA file
	- a GFF file

	It checks and compare seqid names and seqids length from FASTA and GFF to:
	- focus on seqids in common between FASTA and GFF file
	- discard discordant seqids a.k.a seqids with different length in FASTA and GFF file
	- discard 'too short' seqids based on -m option

EOF

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

#################
# VERIFICATIONS #
#################

# Check if needed parameters are defined
if [[ ${FASTA_PATH} == "NOTDEFINED" || ${GFF_PATH} == "NOTDEFINED" || ${OUTDIR} == "NOTDEFINED" ]] ; then
	USAGE
	exit 1
fi

################
# BEGIN SCRIPT #
################

echo -e "\n# BEGIN $( basename ${0} )"

################################################################################

# Check file compression
if [[ ${COMPRESSED} == "YES" ]] ; then
	# If files are compressed, uncompressed them in output directory
	gunzip -kc ${FASTA_PATH} > "${OUTDIR}/${FASTA_NAME}.fasta"
	gunzip -kc ${GFF_PATH} > "${OUTDIR}/${GFF_NAME}.gff"
	FASTA="${OUTDIR}/${FASTA_NAME}.fasta"
	GFF="${OUTDIR}/${GFF_NAME}.gff"
	FASTA_EXTENSION="fasta"
	GFF_EXTENSION="gff"
elif [[ ${COMPRESSED} == "NO" ]] ; then
	# If files are uncompressed, copy them in output directory
	cp ${FASTA_PATH} "${OUTDIR}/${FASTA_NAME}.fasta"
	cp ${GFF_PATH} "${OUTDIR}/${GFF_NAME}.gff"
	FASTA="${OUTDIR}/${FASTA_NAME}.fasta"
	GFF="${OUTDIR}/${GFF_NAME}.gff"
fi

################################################################################

# If bash_bioinfo already cloned : remove it
if [[ -d "bash_bioinfo" ]] ; then

	# Remove bash_bioinfo/ directory
	CMD1="rm -rf bash_bioinfo/"
	if [[ ${VERBOSE} == "YES" ]] ; then echo -e "\t[VERBOSE COMMAND] ---> ${CMD1}" ; fi
	eval ${CMD1}

fi

# Get .bash_bioinfo from Github
CMD2="git clone 'https://github.com/thbtmntgn/bash_bioinfo' 2> /dev/null"
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "\t[VERBOSE COMMAND] ---> ${CMD2}" ; fi
eval ${CMD2}

# Source .bash_bioinfo
CMD3="source 'bash_bioinfo/.bash_bioinfo'"
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "\t[VERBOSE COMMAND] ---> ${CMD3}" ; fi
eval ${CMD3}

################################################################################

# Verbose prints
if [[ ${VERBOSE} == "YES" ]] ; then
	echo -e "\t[VERBOSE INFO] ---> Your GFF file is           : ${GFF_FULLNAME}"
	echo -e "\t[VERBOSE INFO] ---> Your FASTA file is         : ${FASTA_FULLNAME}"
	echo -e "\t[VERBOSE INFO] ---> Your output directory is   : ${OUTDIR}"
	echo -e "\t[VERBOSE INFO] ---> Minimal sequence length is : ${MIN_LENGTH}"
	echo -e "\t[VERBOSE INFO] ---> VERBOSE is activated"
	if [[ ${COMPRESSED} == "YES" ]] ; then echo -e "\t[VERBOSE INFO] ---> FASTA and GFF files are compressed"       ; fi
	if [[ ${COMPRESSED} == "NO" ]]  ; then echo -e "\t[VERBOSE INFO] ---> FASTA and GFF files are not compressed" ; fi
fi

################################################################################

# Get sequence ID + sequence length from FASTA file
CMD="fadesc ${FASTA} > ${OUTDIR}/${FASTA_NAME}.desc"
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "\t[VERBOSE COMMAND] ---> ${CMD}" ; fi
eval ${CMD}

################################################################################

# Compare and filter seqids from FASTA and GFF
if [[ ${VERBOSE} == "YES" ]] ; then
	CMD="perl check_fasta_gff.pl --description ${OUTDIR}/${FASTA_NAME}.desc --gff ${GFF} --outdir ${OUTDIR} --verbose"
	echo -e "\t[VERBOSE COMMAND] ---> ${CMD}"
else
	CMD="perl check_fasta_gff.pl --description ${OUTDIR}/${FASTA_NAME}.desc --gff ${GFF} --outdir ${OUTDIR}"
fi
eval ${CMD}

################################################################################

# If good common seqids are retrieved, sort them by sequence length from FASTA (longest to smallest)
if [[ -e "${OUTDIR}/seqids_in_common_concordant.desc" ]] ; then

	CMD="cat ${OUTDIR}/seqids_in_common_concordant.desc | sort -nr -k2 > ${OUTDIR}/seqids_in_common_concordant_sorted.desc"
	if [[ ${VERBOSE} == "YES" ]] ; then echo -e "\t[VERBOSE COMMAND] ---> ${CMD}" ; fi
	eval ${CMD}

else

	echo -e "Problem : none common seqids !"
	exit 1

fi

################################################################################

# Get seqids from LIST file
CMD="cat ${OUTDIR}/seqids_in_common_concordant_sorted.desc | awk '{ if (\$2 >= ${MIN_LENGTH}){ print \$0 } }' > ${OUTDIR}/filtered_seqids.desc"
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "\t[VERBOSE COMMAND] ---> ${CMD}" ; fi
eval ${CMD}

################################################################################

# Get too short SEQIDS
CMD="cat ${OUTDIR}/seqids_in_common_concordant_sorted.desc | awk '{ if (\$2 < ${MIN_LENGTH}){ print \$0 } }' > ${OUTDIR}/seqids_in_common_concordant_too_short.desc"
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "\t[VERBOSE COMMAND] ---> ${CMD}" ; fi
eval ${CMD}

################################################################################

SEQIDS_COMMON_NUM=$( cat ${OUTDIR}/seqids_in_common_concordant_sorted.desc | wc -l | awk '{print $1}' )
SEQIDS_TOO_SHORT_NUM=$( cut -f1 ${OUTDIR}/seqids_in_common_concordant_too_short.desc | wc -l | awk '{print $1}' )
SEQIDS_FILTERED_NUM=$( cut -f1 ${OUTDIR}/filtered_seqids.desc | wc -l | awk '{print $1}' )

if [[ ${VERBOSE} == "YES" ]] ; then
	echo -e "\t[VERBOSE INFO] ---> Concordant seqids           : ${SEQIDS_COMMON_NUM}"
	echo -e "\t[VERBOSE INFO] ---> Concordant seqids too short : ${SEQIDS_TOO_SHORT_NUM}"
	echo -e "\t[VERBOSE INFO] ---> Keeped seqids               : ${SEQIDS_FILTERED_NUM}"
fi

################################################################################

if [[ ${SEQIDS_TOO_SHORT_NUM} -eq 0 ]] ; then
	rm ${OUTDIR}/seqids_in_common_concordant_too_short.desc
fi

################################################################################

# Index FASTA file
CMD="samtools faidx ${FASTA}"
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "\t[VERBOSE COMMAND] ---> ${CMD}" ; fi
eval ${CMD}

################################################################################

# Get only seqid field
CMD="cut -f1 ${OUTDIR}/filtered_seqids.desc > ${OUTDIR}/filtered_seqids.list"
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "\t[VERBOSE COMMAND] ---> ${CMD}" ; fi
eval ${CMD}

################################################################################

# Get FASTA sequences with seqids in LIST
CMD="faget ${FASTA} ${OUTDIR}/filtered_seqids.list > ${OUTDIR}/filtered_${FASTA_NAME}.${FASTA_EXTENSION}"
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "\t[VERBOSE COMMAND] ---> ${CMD}" ; fi
eval ${CMD}

################################################################################

# Get GFF sequences with seqids in LIST
CMD="grep -F -w -f ${OUTDIR}/filtered_seqids.list ${GFF} > ${OUTDIR}/filtered_${GFF_NAME}.${GFF_EXTENSION}"
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "\t[VERBOSE COMMAND] ---> ${CMD}" ; fi
eval ${CMD}

################################################################################
# Check seqids number in LIST, new FASTA and new GFF

if [[ ${VERBOSE} == "YES" ]] ; then

	FASTA_SEQID_NUM=$( grep -c ">" ${OUTDIR}/filtered_${FASTA_NAME}.${FASTA_EXTENSION} )
	GFF_SEQID_NUM=$( grep -v "^#" ${OUTDIR}/filtered_${GFF_NAME}.${GFF_EXTENSION} | cut -f1 | sort -u | wc -l | awk '{ print $1 }' )

	if [[ ${SEQIDS_FILTERED_NUM} -eq ${FASTA_SEQID_NUM} && ${SEQIDS_FILTERED_NUM} -eq ${GFF_SEQID_NUM} ]] ; then
		echo -e "\t[VERBOSE INFO] ---> ALL GOOD !"
		echo -e "\t[VERBOSE INFO] ---> Keeped seqids at the end : ${SEQIDS_FILTERED_NUM}"
		echo -e "\t[VERBOSE INFO] ---> Seqids in final fasta    : ${FASTA_SEQID_NUM}"
		echo -e "\t[VERBOSE INFO] ---> Seqids in final gff      : ${GFF_SEQID_NUM}"
	else
		echo -e "\t[VERBOSE INFO] ---> PROBLEM ! !"
		echo -e "\t[VERBOSE INFO] ---> Keeped seqids at the end : ${SEQIDS_FILTERED_NUM}"
		echo -e "\t[VERBOSE INFO] ---> Seqids in final fasta    : ${FASTA_SEQID_NUM}"
		echo -e "\t[VERBOSE INFO] ---> Seqids in final gff      : ${GFF_SEQID_NUM}"
	fi

fi

################################################################################

# Delete temporary files
rm ${FASTA}
rm ${GFF}
rm ${FASTA}.fai
rm ${OUTDIR}/seqids_in_common_concordant_sorted.desc
rm ${OUTDIR}/filtered_seqids.list
rm ${OUTDIR}/${FASTA_NAME}.desc

##############
# END SCRIPT #
##############

echo -e "# END $( basename ${0} )\n"
