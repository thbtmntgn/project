#!/usr/local/bin/bash
set -u

############
# FUNTIONS #
############

function USAGE() {

	printf "Usage:\n\t%s -d DATABASE -p PILEUP_INFO -t TABLE_NAME [-o OUTDIR] [-v]\n" $( basename ${0} )
	printf "\t%s [-h]\n\n" $( basename ${0} )

	cat <<EOF

Required arguments:
	-d database name
	-p information from PILEUP file
	-t table name

Optional arguments:
	-o output directory

Help :
	-h print this help
	-v to activate verbose mode [by default : not activated]

Description:

	This script needs:
	- a file containing extracted information from a pileup file,
	- a database name
	- a table name

	It inserts information within the given table of the given database.
EOF

	exit ${1:-0}

}

#####################
# BY DEFAULT VALUES #
#####################

DB_NAME="NOTDEFINED"
TABLE_NAME="NOTDEFINED"
PILEUP_INFO_PATH="NOTDEFINED"

OUTDIR=$( pwd )
VERBOSE="NO"

##################
# OPTION PARSING #
##################

while getopts ":vhd:p:t:o:" OPTION
do
	case ${OPTION} in
		d)
			DB_NAME=${OPTARG}
			;;
		p)
			PILEUP_INFO_PATH=${OPTARG}
			PILEUP_INFO_FULLNAME=$( basename ${PILEUP_INFO_PATH} )
			PILEUP_INFO_NAME=${PILEUP_INFO_FULLNAME%%.*}
			PILEUP_INFO_EXTENSION=${PILEUP_INFO_FULLNAME#*.}
			;;
		t)
			TABLE_NAME=${OPTARG}
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

if [[ ${DB_NAME} == "NOTDEFINED" || ${PILEUP_INFO_PATH} == "NOTDEFINED" || ${TABLE_NAME} == "NOTDEFINED" ]] ; then
	USAGE
	exit 1
fi

################################################################################

################
# BEGIN SCRIPT #
################

echo -e "\n# BEGIN $( basename ${0} )"

################################################################################

cp import_individual_template.sql ${OUTDIR}/import_individual.sql

replace "DB_NAME"          "${DB_NAME}"            -- ${OUTDIR}/import_individual.sql
replace "TABLE_NAME"       "${TABLE_NAME}"         -- ${OUTDIR}/import_individual.sql
replace "INFO_FROM_PILEUP" "'${PILEUP_INFO_PATH}'" -- ${OUTDIR}/import_individual.sql

################################################################################

mysql.server start
mysql --user=root --password --local-infile < ${OUTDIR}/import_individual.sql
mysql.server stop

################################################################################

##############
# END SCRIPT #
##############

echo -e "# END $( basename ${0} )\n"
