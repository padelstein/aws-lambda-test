#!/bin/bash
# uplpoads a directory of python modules to create a lambda function
# -n required: the desired name of the lambda function as arg
# -h required: the handler method as arg
# -d required: the directory of python modules as arg

n_flag=false
h_flag=false
d_flag=false

while getopts ":n:h:d:" option; do
	case $option in
		n)	
			if [ $OPTARG = -* ]; then
				echo "$opt requires a lambda function name as an argument"
				exit 1
			else			
				LAMBDA_NAME=$OPTARG; n_flag=true
			fi
			;;
		h)
			if [ $OPTARG = -* ]; then
				echo "$opt requires the lambda function handler as an argument"
				exit 1
			else			
				LAMBDA_HANDLER=$OPTARG; h_flag=true
			fi
			;;
		d)
			if [ $OPTARG = -* ]; then
				echo "$opt requires the directory as an argument"
				exit 1
			else			
				LAMBDA_DIR=$OPTARG; d_flag=true
			fi
			;;
		\?)
			echo "Invalid option: -$OPTARG"
			exit 1
			;;
	esac
done

# check if the required flags and arguments have been provided
if [[ ! $n_flag || ! $h_flag || ! $d_flag ]]; then
	echo "usage: lambda-deploy -d DIRECTORY_OF_PYTHON_MODULES -n LAMBDA_FUNCTION_NAME -d LAMBDA_MODULE_DIRECTORY"
	exit 1
fi


cd $LAMBDA_DIR
	
# check if we are in the correct directory
if [ “$PWD” != “$LAMBDA_DIR” ]; then
	echo “not in $LAMBDA_DIR”
	exit 86
else
	# compress all the python modules
	zip ${LAMBDA_NAME}.zip *.py -x __init__.py
fi


# attempts to update the $LATEST version of the lambda function
# deletes the compressed archive if successful
if aws lambda create-function \
--function-name ${LAMBDA_NAME} \
--runtime python2.7 \
--role arn:aws:iam::742333168435:role/lambda_basic_execution \
--handler ${LAMBDA_HANDLER} \
--zip-file fileb://${LAMBDA_NAME}.zip
then
	rm ${LAMBDA_NAME}.zip
else
	echo "$LAMBDA_NAME update unsuccessful"
	exit 1
fi

echo

exit 0
