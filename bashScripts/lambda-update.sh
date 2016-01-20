#!/bin/bash
# deploys a directory of python modules as an update to a lambda function
# this assumes the lambda function has already been deployed at least once
# -d requires the directory of python modules as arg
# -n requires the name of the lambda function as arg

d_flag=false
n_flag=false

while getopts ":d:n:" option; do
	case $option in
		d)	
			if [ $OPTARG = -* ]; then
				echo "$opt requires a directory as an argument"
				exit 1
			else			
				LAMBDA_DIR=$OPTARG; d_flag=true
			fi
			;;
		n)
			if [ $OPTARG = -* ]; then
				echo "$opt requires a lambda function name as an argument"
				exit 1
			else			
				LAMBDA_NAME=$OPTARG; n_flag=true
			fi
			;;
		\?)
			echo "Invalid option: -$OPTARG"
			exit 1
			;;
	esac
done

# check if the required flags and arguments have been provided
if [[ ! $d_flag || ! $n_flag ]]; then
	echo "usage: lambda-deploy -d DIRECTORY_OF_PYTHON_MODULES -n LAMBDA_FUNCTION_NAME"
	exit 1
fi

cd $LAMBDA_DIR

# check if we are in the correct directory
if [ “$PWD” != “$LAMBDA_DIR” ] 
then
	echo “not in $LAMBDA_DIR”
	exit 86
fi

# compress all the python modules
zip ${LAMBDA_NAME}.zip *.py -x __init__.py

# attempts to update the $LATEST version of the lambda function
# deletes the compressed archive if successful
if aws lambda update-function-code \
--function-name ${LAMBDA_NAME} \
--zip-file fileb://${LAMBDA_NAME}.zip
then
	rm ${LAMBDA_NAME}.zip
else
	echo "$LAMBDA_NAME update unsuccessful"
	exit 1
fi

echo

exit 0
