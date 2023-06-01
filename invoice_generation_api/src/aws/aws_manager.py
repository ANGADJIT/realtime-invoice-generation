import boto3
from dotenv import load_dotenv
from os import environ
import json
from string import ascii_lowercase
from random import sample
from botocore.exceptions import ClientError


class AwsManager:

    def __init__(self) -> None:
        load_dotenv()  # load env

        region_name: str = environ.get('REGION_NAME')
        endpoint_url: str = environ.get('ENDPOINT_URL')
        self.__kinesis = boto3.client('kinesis', region_name=region_name,
                                      endpoint_url=endpoint_url)
        self.__s3 = boto3.client('s3', region_name=region_name,
                                 endpoint_url=endpoint_url)

    def send_event(self, event: dict) -> None:
        # convert data into bytes
        data: bytes = json.dumps(event).encode()

        # generate random partition key
        partition_key: str = ''.join(sample(ascii_lowercase, k=6))

        stream_name: str = environ.get('PAYMENT_STREAM_NAME')
        self.__kinesis.put_record(
            StreamName=stream_name,
            Data=data,
            PartitionKey=partition_key
        )

    def check_for_object(self, object_key: str) -> bool:
        bucket_name: str = environ.get('BUCKET_NAME')

        try:
            self.__s3.head_object(Bucket=bucket_name, Key=object_key)

            return True

        except (ClientError):
            return False

    def generate_public_url(self, object_key: str) -> str:
        bucket_name: str = environ.get('BUCKET_NAME')

        return self.__s3.generate_presigned_url(
            'get_object',
            Params={'Bucket': bucket_name, 'Key': object_key},
            ExpiresIn=3600
        )
