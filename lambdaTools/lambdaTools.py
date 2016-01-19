'''
Created on Jan 19, 2016

@author: padelstein
'''

from __future__ import print_function

import boto3
import json


def lambdaTools_handler(event, context):
    '''Provide an event that contains the following keys:

      - operation: one of the operations in the operations dict below
      - tableName: required for operations that interact with DynamoDB
      - payload: a parameter to pass to the operation being performed
    '''

    operation = event['operation']

    operations = {
        'create': lambda x: create_function(x.get('name'), x.get('role'), x.get('handler'), x.get('bucket') ),
        'ping': lambda x: 'pong'
    }

    if operation in operations:
        return operations[operation](event)
    else:
        raise ValueError('Unrecognized operation "{}"'.format(operation))
    
def create_function(function_name, function_role="arn:aws:iam::742333168435:role/lambdaFULL", function_handler, s3_bucket):
    '''creates a lambda function using the parameters:
    
        - function_name: the desired name of the Lambda Function
        - function_role: the AWS IAM role that has the appropriate permissions
        - function_handler: the python method Lambda will call to execute the function
        - s3_bucket: the AWS S3 bucket that contains your python modules
    '''
    
    client = boto3.client('lambda')
    
    response = client.create_function(
         FunctionName=function_name,
         Runtime='python.2.7',
         Role=function_role,
         Handler=function_handler,
         Code=s3_bucket,
         Publish=False        
    )
    
    return "successfully created the {} Lambda function at {}".format(response.get('FunctionName'), response.get('FunctionARN') )