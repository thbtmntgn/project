#!/usr/local/bin/bash
set -u

############
# FUNTIONS #
############

function USAGE() {
	printf "Usage:\n\t%s -d DATABASE -f FASTA -g GFF [-v]\n" $( basename ${0} )
	printf "\t%s -h\n\n" $( basename ${0} )
	echo -e "Required arguments :"
	echo -e "\t-d xxx"
	echo -e "\t-f xxx"
	echo -e "\t-g xxx"
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
FASTA_INFO_PATH="NOTDEFINED"
GFF_INFO_PATH="NOTDEFINED"
VERBOSE="NO"

##################
# OPTION PARSING #
##################

while getopts ":vhd:f:g:" OPTION
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

echo -e "\n#############################\n# BEGIN $( basename ${0} ) #\n#############################\n"

################################################################################

#################
# VERIFICATIONS #
#################

if [[ ${DATABASE} == "NOTDEFINED" || ${FASTA_INFO_PATH} == "NOTDEFINED" || ${GFF_INFO_PATH} == "NOTDEFINED" ]] ; then
	USAGE
	exit 1
fi

################################################################################

head ${FASTA_INFO_PATH}
head ${GFF_INFO_PATH}

################################################################################

##############
# END SCRIPT #
##############

echo -e "\n###########################\n# END $( basename ${0} ) #\n###########################\n\n"
