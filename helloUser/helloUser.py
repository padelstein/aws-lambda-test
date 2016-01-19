'''
Created on Jan 19, 2016

@author: padelstein
'''

from __future__ import print_function

import boto3
import json


def hello_user_handler(event, context):
    '''Provide an event that contains the following keys:

      - operation: one of the operations in the operations dict below
      - tableName: required for operations that interact with DynamoDB
      - payload: a parameter to pass to the operation being performed
    '''

    operation = event['operation']

    operations = {
        'ping': lambda x: 'Hi {}'.format(x)
    }

    if operation in operations:
        return operations[operation](event.get('payload'))
    else:
        raise ValueError('Unrecognized operation "{}"'.format(operation))