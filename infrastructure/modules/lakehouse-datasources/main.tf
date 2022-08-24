#Create Snowflake Schema
#Create AWS S3 Bucket for ingesting files
#Create AWS IAM Policy and attachs to IAM Role
#Create AWS SNS Topic for S3 Bucket Notifications
#Create AWS Policy Document for SNS topic and attaches to SNS Topic
#Create AWS Event Notification for S3 bucket and sends to SNS Topic
#Create Snowflake Stage
#Upload template file to AWS S3
#Create Snowflake File Format 
#Create Snowflake Table based on hardcoded DDL (To Do: Need to do this based on file structure instead)
#Create Snowflake Pipe 

#Create Snowflake Schema in RAW database
resource "snowflake_schema" "raw_schema" {
  database            = var.sf_database_name
  name                = "${var.datasource}"
  data_retention_days = 14
}

#Create S3 Bucket for injesting files
resource "aws_s3_bucket" "injest-bucket" {
  bucket = lower("${var.env}-${var.datasource}-injest-${var.file_type}")
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    environment = "${var.env}"
  }
}

#Creates IAM Policy for above S3 buckets
resource "aws_iam_role_policy" "injest_bucket_policy" {
  name = "injest_bucket_policy_${var.datasource}"
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
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.injest-bucket.bucket}*"
        ]
      },
    ]
  })
}

#Get Snowflake account details for use in IAM Role
data "snowflake_current_account" "this" {}

#Create Snowflake Stage for files
resource "snowflake_stage" "stage" {
  name                = upper("STAGE_${var.file_type}")
  url                 = lower("s3://sbx-${var.datasource}-injest-${var.file_type}")
  database            = var.sf_database_name
  schema              = snowflake_schema.raw_schema.name
  file_format         = upper("TYPE=${var.file_type}")
  storage_integration = var.integrationid
}

#Creates SNS topic for S3 Bucket
resource "aws_sns_topic" "snowflake_load_bucket_topic" {
  name = lower("topic-aws-s3-bucket-${var.datasource}-injest-bucket-${var.file_type}")
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
        aws_s3_bucket.injest-bucket.arn,
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

#Attaches the policy to SNS topic for the S3 Bucket
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.snowflake_load_bucket_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

#Create an event on bucket that sends notification to SNS topic for S3 Bucket
resource "aws_s3_bucket_notification" "new_objects_notification" {
  bucket     = aws_s3_bucket.injest-bucket.id
  topic {
    topic_arn     = aws_sns_topic.snowflake_load_bucket_topic.arn
    events        = ["s3:ObjectCreated:*"]
  }
 depends_on = [aws_sns_topic.snowflake_load_bucket_topic, aws_sns_topic_policy.default, aws_s3_bucket.injest-bucket]      
}

#Upload Template File to S3 to enable creation of Table based on file structure
resource "aws_s3_object" "s3_upload" {
  bucket = aws_s3_bucket.injest-bucket.bucket
  key    = lower("${var.datasource}.${var.file_type}") 
  source = lower("../sbx/file-template/${var.datasource}.${var.file_type}") 
}

#Creates Snowflake File Format
resource "snowflake_file_format" "file_format" {
  name        = upper("FILE_FORMAT_${var.datasource}_${var.file_type}")
  database    = var.sf_database_name
  schema      = snowflake_schema.raw_schema.name
  format_type = "${var.file_type}"
  #compression = "NONE"
}

resource "snowflake_table" "table" {
  database            = var.sf_database_name
  schema              = snowflake_schema.raw_schema.name
  name                = upper("STG_${var.datasource}")
  comment             = "Table for Snowpipe to COPY INTO"
  #data_retention_days = snowflake_schema.schema.data_retention_days
  #change_tracking     = false
  #To do: Figure out how to dynamically generate table DDL
  column {
    name     = "demographics"
    type     = "variant"
    nullable = true
  }

}

#Need to give time for AWS Roles to become active before creating Snowflake Pipes
#https://community.snowflake.com/s/question/0D50Z00009UruoRSAR/troubleshooting-sql-execution-error-error-assuming-awsrole-please-verify-the-role-and-externalid-are-configured-correctly-in-your-aws-policy
resource "time_sleep" "wait_10_seconds" {
  depends_on = [
    snowflake_table.table, snowflake_stage.stage, aws_s3_bucket_notification.new_objects_notification
  ]
  create_duration = "10s"
}

#Create Snowflake Pipe for files
resource "snowflake_pipe" "pipe" {
  database             = var.sf_database_name
  schema               = snowflake_schema.raw_schema.name
  name                 = upper("PIPE_${var.datasource}_${var.file_type}")
  comment              = "Copy files from stage into STG table"
  copy_statement       = <<EOT
   COPY INTO "SBX_RAW"."${var.datasource}"."STG_${var.datasource}" FROM @"SBX_RAW"."${var.datasource}"."STAGE_PARQUET"
   EOT
  auto_ingest          = true
  aws_sns_topic_arn    = aws_sns_topic.snowflake_load_bucket_topic.arn
  depends_on           = [time_sleep.wait_10_seconds, snowflake_table.table, snowflake_stage.stage, aws_s3_bucket_notification.new_objects_notification]

}
