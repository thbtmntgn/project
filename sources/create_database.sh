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

if [[ ${DATABASE} == "NOTDEFINED" || ${OUTDIR} == "NOTDEFINED" ]] ; then
	USAGE
	exit 1
fi

################################################################################


if [[ ${VERBOSE} == "YES" ]] ; then echo -e "> Generating ${OUTDIR}/create_database.sql...." ; fi

# Replace DB_NAME by DATABASE in create_database_template.sql
sed "s/DB_NAME/${DATABASE}/g" create_database_template.sql > ${OUTDIR}/create_database.sql

if [[ ${VERBOSE} == "YES" ]] ; then echo -e "> Generating ${OUTDIR}/create_database.sql OK!\n" ; fi

CMD1="mysql.server start"
CMD2="mysql --user=root --password < ${OUTDIR}/create_database.sql"
CMD3="mysql.server stop"

if [[ ${VERBOSE} == "YES" ]] ; then echo -e "> Command : ${CMD1}\n" ; fi
eval ${CMD1}
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "> Command : ${CMD2}\n" ; fi
eval ${CMD2}
if [[ ${VERBOSE} == "YES" ]] ; then echo -e "> Command : ${CMD3}\n" ; fi
eval ${CMD3}

################################################################################

##############
# END SCRIPT #
##############

echo -e "\n##########################\n# END $( basename ${0} ) #\n##########################\n"
