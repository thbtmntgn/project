#!/usr/local/bin/bash
set -u

############
# FUNTIONS #
############

function USAGE() {

	printf "Usage:\n\t%s -d DATABASE -f FASTA -g GFF [-v]\n" $( basename ${0} )
	printf "\t%s -h\n\n" $( basename ${0} )

	cat <<EOF

Required arguments:
	-d : database name
	-f : information from FASTA file (generated by extract_info.sh)
	-g : information from GFF file (generated by extract_info.sh)

Optional arguments:
	-o : output directory         [by default : woking directory]

Help:
	-h : print this help
	-v : to activate verbose mode [by default : not activated]

Description:

	TO BE COMPLETED!

EOF

	exit ${1:-0}

}

#####################
# BY DEFAULT VALUES #
#####################

DATABASE="NOTDEFINED"
OUTDIR=$( pwd )
FASTA_INFO_PATH="NOTDEFINED"
GFF_INFO_PATH="NOTDEFINED"
VERBOSE="NO"

##################
# OPTION PARSING #
##################

while getopts ":vhd:f:g:o:" OPTION
do
	case ${OPTION} in
		d)
			DATABASE=${OPTARG}
			;;
		f)
			FASTA_INFO_PATH=${OPTARG}
			FASTA_INFO_FULLNAME=$( basename ${FASTA_INFO_PATH} )
			FASTA_INFO_NAME=${FASTA_INFO_FULLNAME%%.*}
			FASTA_INFO_EXTENSION=${FASTA_INFO_FULLNAME#*.}
			;;
		g)
			GFF_INFO_PATH=${OPTARG}
			GFF_INFO_FULLNAME=$( basename ${GFF_INFO_PATH} )
			GFF_INFO_NAME=${GFF_INFO_FULLNAME%%.*}
			GFF_INFO_EXTENSION=${GFF_INFO_FULLNAME#*.}
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

################################################################################

#################
# VERIFICATIONS #
#################

if [[ ${DATABASE} == "NOTDEFINED" || ${FASTA_INFO_PATH} == "NOTDEFINED" || ${GFF_INFO_PATH} == "NOTDEFINED" ]] ; then
	USAGE
	exit 1
fi

################################################################################

################
# BEGIN SCRIPT #
################

echo -e "\n# BEGIN $( basename ${0} )"

################################################################################

cp import_reference_template.sql ${OUTDIR}/import_reference.sql

replace "DB_NAME"         "${DATABASE}"          -- ${OUTDIR}/import_reference.sql
replace "INFO_FROM_FASTA" "'${FASTA_INFO_PATH}'" -- ${OUTDIR}/import_reference.sql
replace "INFO_FROM_GFF"   "'${GFF_INFO_PATH}'"   -- ${OUTDIR}/import_reference.sql

################################################################################

mysql.server start
mysql --user=root --password --local-infile < ${OUTDIR}/import_reference.sql
mysql.server stop

################################################################################

##############
# END SCRIPT #
##############

echo -e "# END $( basename ${0} )\n"
