from typing import Any
import boto3
from os import environ
import base64
import json


def generate_invoice(event, context) -> Any:

    s3 = boto3.client('s3', region_name=environ.get('REGION_NAME'),
                      endpoint_url=environ.get('ENDPOINT_URL'))

    for index, record in enumerate(event['Records']):
        try:
            # data = base64.b64decode(
            #     record['kinesis']['data'])decode('latin-1')
            data = type(record['kinesis']['data'])

            s3.put_object(Body=str(data),
                          Bucket='invoices', Key=f'type{index}.txt')
            s3.put_object(Body=str(record['kinesis']['data']),
                          Bucket='invoices', Key=f'data{index}.txt')
        except (Exception) as e:
            s3.put_object(Body=str(e),
                          Bucket='invoices', Key=f'error{index}.txt')

    return {'error': 'data not found'}
