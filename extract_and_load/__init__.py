import boto3
from extract_and_load.config import AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
client = boto3.client(
aws_access_key_id=AWS_ACCESS_KEY_ID,
aws_secret_access_key=AWS_SECRET_ACCESS_KEY)