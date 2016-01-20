#!/bin/bash
# tests a lambda function by using the curl bash command
# -n required: the name of the lambda function as arg
# -v required: the stage of the lambda function as arg {dev, test, prod}
# -d required: a JSON object

n_flag=false
v_flag=false
d_flag=false

while getopts ":n:v:d:" option; do
	case $option in
		n)	
			if [ $OPTARG = -* ]; then
				echo "$opt requires a lambda function name as an argument"
				exit 1
			else			
				LAMBDA_NAME=$OPTARG; n_flag=true
			fi
			;;
		v)
			if [ $OPTARG = -* ]; then
				echo "$opt requires {dev,test,prod} as an argument"
				exit 1
			else			
				LAMBDA_STAGE=$OPTARG; v_flag=true
			fi
			;;
		d)
			if [ $OPTARG = -* ]; then
				echo "$opt requires a JSON object as an argument"
				exit 1
			else			
				JSON_DATA=$OPTARG; d_flag=true
			fi
			;;
		\?)
			echo "Invalid option: -$OPTARG"
			exit 1
			;;
	esac
done

case $LAMBDA_NAME in
	"hello-user") 
			TEST_URL="https://081nwdrb39.execute-api.us-east-1.amazonaws.com/$LAMBDA_STAGE"
			;;
	"lambdaTools") 
			TEST_URL="https://gbm9ky6ulc.execute-api.us-east-1.amazonaws.com/$LAMBDA_STAGE"
			;;
	\?)
			echo "$LAMBDA_NAME not known"
			exit 1
			;;
esac

# check if the required flags and arguments have been provided
if [[ ! $n_flag || ! $v_flag || ! $d_flag ]]; then 
	echo "usage: lambda-test -n LAMBDA_FUNCTION_NAME -v LAMBDA_FUNCTION_STAGE -d JSON_OBJECT"
	exit 1
fi

curl \
-H '"Content-Type: application/json"' \
-X POST \
-d $JSON_DATA \
$TEST_URL


echo


exit 0