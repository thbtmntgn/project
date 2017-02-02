#!/usr/local/bin/bash
set -u

############
# FUNTIONS #
############

function USAGE() {

	printf "Usage:\n\t%s -d DATABASE_NAME [-o OUTDIR] [-v]\n" $( basename ${0} )
	printf "\t%s [-h]\n" $( basename ${0} )

	cat <<EOF

Required arguments:
	-d : database name

Optional arguments:
	-o : output directory       [by default: working directory]

Help :
	-h print this help
	-v to activate verbose mode [by default: not activated]

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

################################################################################

if [[ ${DATABASE} == "NOTDEFINED" ]] ; then
	USAGE
fi

################################################################################

################
# BEGIN SCRIPT #
################

echo -e "\n# BEGIN $( basename ${0} )"

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

echo -e "# END $( basename ${0} )\n"
