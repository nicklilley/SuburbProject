#Create AWS S3 Buckets for ingesting files
#Create AWS IAM Policy and attach to IAM Role
#Create Snowflake Schemas
#Create Snowflake Stages
#Create Snowflake Pipes


#Create S3 Bucket for injesting json files
resource "aws_s3_bucket" "injest-bucket-json" {
  bucket = lower("${var.env}-${var.datasource}-injest-json")
  tags = {
    environment = "${var.env}"
  }
}

#Create S3 Bucket for injesting parquet files
resource "aws_s3_bucket" "injest-bucket-parquet" {
  bucket = lower("${var.env}-${var.datasource}-injest-parquet")
  tags = {
    environment = "${var.env}"
  }
}

#Creates IAM Policy for above S3 buckets
resource "aws_iam_role_policy" "injest_bucket_policy" {
  name = "injest_bucket_policy"
  #role = aws_iam_role.injest_bucket_role.id #Attaches policy to the global IAM role create in Core
  #role = module.lakehouse-core.outputs.iam_role_injest_bucket_id.value #Attaches policy to the role create below
  #role = "1234"
  role = var.injest_bucket_iam_role
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObjectVersion"
        ]
        Effect   = "Allow"
        #Resource = "arn:aws:s3:::${aws_s3_bucket.injest-bucket.bucket}*"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.injest-bucket-json.bucket}*",
          "arn:aws:s3:::${aws_s3_bucket.injest-bucket-parquet.bucket}*"
        ]
      },
    ]
  })
}

#Get Snowflake account details for use in IAM Role
data "snowflake_current_account" "this" {}

#Create Snowflake Schema in RAW database
resource "snowflake_schema" "raw_schema" {
  database            = var.sf_database_name
  name                = "${var.datasource}"
  data_retention_days = 14
}

#Create Snowflake Stage for Parquet files
resource "snowflake_stage" "stage_parquet" {
  name                = "STAGE_PARQUET"
  url                 = "s3://sbx-domain-api-injest-parquet"
  #url                 = "s3://lower("${var.env}-${var.datasource}-injest-parquet")"
  database            = var.sf_database_name
  schema              = snowflake_schema.raw_schema.name
  file_format         = "TYPE=PARQUET"
  storage_integration = var.integrationid
}
/*
#Create Snowflake Stage for JSON files
resource "snowflake_stage" "stage_json" {
  name                = "STAGE_JSON"
  url                 = "s3://sbx-suburbproject-api-responses-json"
  database            = var.sf_database_name
  schema              = snowflake_schema.raw_schema.name
  file_format         = "TYPE=JSON"
  storage_integration = var.integrationid
}

*/

#Creates SNS topic for Parquet S3 Bucket
resource "aws_sns_topic" "snowflake_load_bucket_topic" {
  name = lower("topic-aws-s3-bucket-${var.datasource}-injest-bucket-parquet")
  delivery_policy = <<EOF
  {
    "http": {
      "defaultHealthyRetryPolicy": {
        "minDelayTarget": 20,
        "maxDelayTarget": 20,
        "numRetries": 3,
        "numMaxDelayRetries": 0,
        "numNoDelayRetries": 0,
        "numMinDelayRetries": 0,
        "backoffFunction": "linear"
      },
      "disableSubscriptionOverrides": false,
      "defaultThrottlePolicy": {
        "maxReceivesPerSecond": 1
      }
    }
  }
  EOF
}  

#Get AWS Account ID for code block below
data "aws_caller_identity" "current" {}

#Creates policy document for the above SNS topic for Parquet S3 Bucket
data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.snowflake_load_bucket_topic.arn
    ]

    sid = "__default_statement_ID"
  }

  statement {
    actions = [
      "SNS:Subscribe"
    ]
    effect = "Allow"
 
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

   # principals {
   #   type        = "AWS"
   #   #identifiers = [var.snowflake_account_arn]
   #   identifiers = [var.injest_bucket_iam_role]
   # }

    resources = [
      aws_sns_topic.snowflake_load_bucket_topic.arn
    ]

    sid = "1"
  }  

  statement {
    actions = [
      "SNS:Publish"
    ]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values = [
        aws_s3_bucket.injest-bucket-parquet.arn,
      ]
    }

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.snowflake_load_bucket_topic.arn,
    ]

    sid = "s3-event-notifier"
  } 
}

#Attaches the policy to SNS topic for the Parquet S3 Bucket
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.snowflake_load_bucket_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

#Create an event on bucket that sends notification to SNS topic for Parquet S3 Bucket
resource "aws_s3_bucket_notification" "new_objects_notification" {
  bucket     = aws_s3_bucket.injest-bucket-parquet.id

  topic {
    topic_arn     = aws_sns_topic.snowflake_load_bucket_topic.arn
    events        = ["s3:ObjectCreated:*"]
  }

 depends_on = [aws_sns_topic.snowflake_load_bucket_topic, aws_sns_topic_policy.default, aws_s3_bucket.injest-bucket-parquet]      
}

/*

#Create Snowflake Pipe for Parquet files
resource "snowflake_pipe" "pipe_parquet" {
  database             = var.sf_database_name
  schema               = snowflake_schema.raw_schema.name
  name                 = "PIPE_PARQUET"
  comment              = "Copy files from stage into table"
  copy_statement    = <<EOT
  COPY INTO "SBX_RAW"."DOMAIN-API"."MYPARQUETTABLE"
  FROM (
  SELECT 
   *
  FROM @STAGE_PARQUET t
  ) FILE_FORMAT = (TYPE = 'parquet')
    EOT
  #copy_statement       = "copy into SBX_RAW.DOMAIN-API.MYPARQUETTABLE from @STAGE_PARQUET"
  #copy_statement       = "copy into ${var.sf_database_name}.${snowflake_schema.raw_schema.name}.MYPARQUETTABLE from @STAGE_PARQUET"
  auto_ingest          = true
  aws_sns_topic_arn    = aws_sns_topic.snowflake_load_bucket_topic.arn
}
*/
