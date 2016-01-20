'''
Created on Jan 19, 2016

@author: padelstein
'''

from __future__ import print_function

import boto3
import json


def lambdaTools_handler(event, context):
    '''Provide an event that may contain the following keys:

      - operation: one of the operations in the operations dict below
      - function_name: the name of the lambda function
      - bucket_path: the path to the deployment zip file in the sqor-lambda-code s3 bucket
    '''

    operation = event['operation']

    operations = {
        'create': lambda x: create_function(x.get('function_name'), x.get('bucket_path') ),
        'ping': lambda x: 'pong'
    }

    if operation in operations:
        return operations[operation](event)
    else:
        raise ValueError('Unrecognized operation "{}"'.format(operation))
    
def create_function(function_name, s3_bucket_path):
    '''creates a lambda function using the parameters:
    
        - function_name: the desired name of the Lambda Function
        - function_role: the AWS IAM role that has the appropriate permissions
        - function_handler: the python method Lambda will call to execute the function
        - s3_bucket: the AWS S3 bucket that contains your python modules
    '''
    
    client = boto3.client('lambda')
    
    response = client.create_function(
         FunctionName=function_name,
         Runtime='python2.7',
         Role='arn:aws:iam::742333168435:role/lambdaFULL',
         Handler="{}.{}_handler".format(function_name, function_name),
         Code={"S3Bucket":"sqor-lambda-code","S3Key":s3_bucket_path},
         Publish=False        
    )
    
    return "successfully created the {} Lambda function at {}".format(response.get('FunctionName'), response.get('FunctionArn') )