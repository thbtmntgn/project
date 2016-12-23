#!/usr/local/bin/bash
set -u

############
# FUNTIONS #
############

function USAGE() {
	printf "Usage:\n\t%s -a xxx [-b yyy] [-v]\n" $( basename ${0} )
	printf "\t%s -h\n\n" $( basename ${0} )
	echo -e "Required arguments :"
	echo -e "\t-a xxx"
	echo
	echo -e "Options :"
	echo -e "\t-b yyy"
	echo
	echo -e "Help :"
	echo -e "\t-v to activate verbose mode [by default : not activated]"
	echo -e "\t-h print this help"
	exit ${1:-0}
}

#####################
# BY DEFAULT VALUES #
#####################

ARGA="by default"
ARGB="by default"
VERBOSE="NO"

##################
# OPTION PARSING #
##################

while getopts ":vha:b:" OPTION
do
	case ${OPTION} in
		a)
			ARGA_PATH=${OPTARG}
			ARGA_FULLNAME=$( basename ${GFF_PATH} )
			ARGA_NAME=${GFF_FULLNAME%%.*}
			ARGA_EXTENSION=${GFF_FULLNAME#*.}
			;;
		b)
			ARGB_PATH=${OPTARG}
			ARGB_FULLNAME=$( basename ${GFF_PATH} )
			ARGB_NAME=${GFF_FULLNAME%%.*}
			ARGB_EXTENSION=${GFF_FULLNAME#*.}			;;
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

if [[ ${VERBOSE} == "YES" ]] ; then
	echo -e "-a : ${ARGA_FULLNAME}"
	echo -e "-b : ${ARGB_FULLNAME}"
fi

################################################################################



################################################################################

##############
# END SCRIPT #
##############

echo -e "\n##########################\n# END $( basename ${0} ) #\n##########################\n\n"
