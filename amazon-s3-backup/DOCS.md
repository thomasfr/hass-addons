# Home Assistant Add-on: Amazon S3 Backup

## Installation

Follow these steps to get the add-on installed on your system:

1. Enable **Advanced Mode** in your Home Assistant user profile.
2. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
3. Search for "Amazon S3 Backup" add-on and click on it.
4. Click on the "INSTALL" button.

## How to use

1. Set the `aws_access_key`, `aws_secret_access_key`, `bucket_name`, `bucket_region` and `storage_class` configuration options.
2. Start the add-on to sync the `/backup/` directory to the configured `bucket_name`.

## Automation

To automate your backup creation and syncing to Amazon S3, add these two automations in Home Assistant and modify the automation to your needs:
```
# backups
- alias: Create a backup every monday
  trigger:
    platform: time
    at: '3:00:00'
  condition:
    condition: time
    weekday:
      - mon
  action:
    service: hassio.backup_full

- alias: Upload to S3
  trigger:
    platform: time
    at: '3:30:00'
  condition:
    condition: time
    weekday:
      - mon
  action:
    service: hassio.addon_start
    data:
        addon: xxxxxxxx_amazon-s3-backup
```

The automation above first creates a full backup at 3am, and then at 3.30am syncs to Amazon S3.

## Configuration

Example add-on configuration:

```
aws_access_key: AKXXXXXXXXXXXXXXXX
aws_secret_access_key: XXXXXXXXXXXXXXXX
bucket_name: my-bucket
bucket_region: eu-central-1
storage_class: STANDARD
```

### Option: `aws_access_key` (required)
AWS IAM access key used to access the S3 bucket.

### Option: `aws_secret_access_key` (required)
AWS IAM secret access key used to access the S3 bucket.

### Option: `bucket_name` (required)
Amazon S3 bucket used to store backups.

### Option: `bucket_region` (required)
AWS region where the S3 bucket was created.

### Option: `storage_class` (required)
Amazon S3 storage class to use when uploading files to S3.

## Minimal IAM Policy

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAWSS3Sync",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::YOUR-S3-BUCKET-NAME/*",
                "arn:aws:s3:::YOUR-S3-BUCKET-NAME"
            ]
        }
    ]
}
```

## Support

Usage of the addon requires knowledge of Amazon S3 and AWS IAM.
Under the hood it uses the aws cli version 2, specifically the `aws s3 sync` command.

## Thanks
This addon is highly inspired by https://github.com/gdrapp/hass-addons and https://github.com/rrostt/hassio-backup-s3