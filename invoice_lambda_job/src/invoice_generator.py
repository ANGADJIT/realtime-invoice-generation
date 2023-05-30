from typing import Any
import boto3
from os import environ
import base64
import json
from render_pdf import RenderPdf


def generate_invoice(event, context) -> Any:

    s3 = boto3.client('s3', region_name=environ.get('REGION_NAME'),
                      endpoint_url=environ.get('ENDPOINT_URL'))

    if 'Records' in event:
        # get record and convert into dict
        record: str = event['Records'][0]['kinesis']['data']

        decoded_record: bytes = base64.b64decode(record)
        json_string: str = decoded_record.decode('utf-8')

        data: dict = json.loads(json_string)

        transaction_id: str = data['transaction_id']

        # make invoice from data
        render_pdf: RenderPdf = RenderPdf(data=data)
        pdf: bytes = render_pdf()

        s3.put_object(Body=pdf,
                      Bucket=environ.get('BUCKET'), Key=f'{transaction_id}.pdf')

        return {'message': 'data written in s3'}

    return {'error': 'data not found'}
