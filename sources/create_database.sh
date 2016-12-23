#!/usr/local/bin/bash
set -u

############
# FUNTIONS #
############

function USAGE() {
	printf "Usage:\n\t%s -d DATABASE_NAME -o OUTDIR [-v]\n" $( basename ${0} )
	printf "\t%s -h\n\n" $( basename ${0} )
	echo -e "Required arguments :"
	echo -e "\t-d : database name"
	echo -e "\t-o : output directory"
	echo
	echo -e "Help :"
	echo -e "\t-v to activate verbose mode [by default : not activated]"
	echo -e "\t-h print this help"
	exit ${1:-0}
}

#####################
# BY DEFAULT VALUES #
#####################

DATABASE="NOTDEFINED"
OUTDIR="NOTDEFINED"
VERBOSE="NO"

##################
# OPTION PARSING #
##################

while getopts ":vhd:o:" OPTION
do
	case ${OPTION} in
		d)
			DATABASE=${OPTARG}
			;;
		o)
			OUTDIR=${OPTARG}
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

if [[ ${DATABASE} == "NOTDEFINED" || ${OUTDIR} == "NOTDEFINED" ]] ; then
	USAGE
	exit 1
fi

################################################################################


if [[ ${VERBOSE} == "YES" ]] ; then echo "Generating ${OUTDIR}/create_database.sql...." ; fi

# Replace DB_NAME by DATABASE in create_database_template.sql
sed "s/DB_NAME/${DATABASE}/g" create_database_template.sql > ${OUTDIR}/create_database.sql

if [[ ${VERBOSE} == "YES" ]] ; then echo "Generating ${OUTDIR}/create_database.sql OK!" ; fi

CMD="mysql --user=root --password < ${OUTDIR}/create_database.sql"
if [[ ${VERBOSE} == "YES" ]] ; then echo "Command : ${CMD}" ; fi
eval ${CMD}

################################################################################

##############
# END SCRIPT #
##############

echo -e "\n##########################\n# END $( basename ${0} ) #\n##########################\n\n"
