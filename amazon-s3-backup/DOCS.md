# Home Assistant Add-on: Amazon S3 Backup

## Installation

Follow these steps to get the add-on installed on your system:

1. Enable **Advanced Mode** in your Home Assistant user profile.
2. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
3. Search for "Amazon S3 Backup" add-on and click on it.
4. Click on the "INSTALL" button.

## How to use

1. Set the `aws_access_key`, `aws_secret_access_key`, and `bucket_name`. 
2. Optionally / if necessary, change `bucket_region`, `storage_class`, and `delete_local_backups` and `local_backups_to_keep` configuration options.
3. Start the add-on to sync the `/backup/` directory to the configured `bucket_name` on Amazon S3. You can also automate this of course, see example below:

## Automation

To automate your backup creation and syncing to Amazon S3, add these two automations in Home Assistants `configuration.yaml` and change it to your needs:
```
automation:
  # create a full backup
  - id: backup_create_full_backup
    alias: Create a full backup every day at 4am
    trigger:
      platform: time
      at: "04:00:00"
    action:
      service: hassio.backup_full
      data:
        # uses the 'now' object of the trigger to create a more user friendly name (e.g.: '202101010400_automated-backup')
        name: "{{as_timestamp(trigger.now)|timestamp_custom('%Y%m%d%H%M', true)}}_automated-backup"

  # Starts the addon 15 minutes after every hour to make sure it syncs all backups, also manual ones, as soon as possible
  - id: backup_upload_to_s3
    alias: Upload to S3
    trigger:
      platform: time_pattern
      # Matches every hour at 15 minutes past every hour
      minutes: 15
    action:
      service: hassio.addon_start
      data:
      addon: XXXXX_amazon-s3-backup
```

The automation above first creates a full backup at 4am, and then at 4:15am syncs to Amazon S3 and if configured deletes local backups according to your configuration.

## Configuration

Example add-on configuration:

```
aws_access_key: AKXXXXXXXXXXXXXXXX
aws_secret_access_key: XXXXXXXXXXXXXXXX
bucket_name: my-bucket
bucket_region: eu-central-1
storage_class: STANDARD
delete_local_backups: true
local_backups_to_keep: 3
```

### Option: `aws_access_key` (required)
AWS IAM access key used to access the S3 bucket.

### Option: `aws_secret_access_key` (required)
AWS IAM secret access key used to access the S3 bucket.

### Option: `bucket_name` (required)
Amazon S3 bucket used to store backups.

### Option: `bucket_region` (optional, Default: eu-central-1)
AWS region where the S3 bucket was created. See https://aws.amazon.com/about-aws/global-infrastructure/ for all available regions.

### Option: `storage_class` (optional, Default: STANDARD)
Amazon S3 storage class to use for the synced objects, when uploading files to S3. One of STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, DEEP_ARCHIVE. For more information see https://aws.amazon.com/s3/storage-classes/.

### Option: `delete_local_backups` (optional, Default: true)
Should the addon remove oldest local backups after syncing to your Amazon S3 Bucket? You can configure how many local backups you want to keep with the Option `local_backups_to_keep`. Oldest Backups will get deleted first.

### Option: `local_backups_to_keep` (optional, Default: 3)
How many backups you want to keep locally? If you want to disable automatic local cleanup, set `delete_local_backups` to false.

If you also want to automatically delete backups to keep your Amazon S3 Bucket clean, or change the storage class for backups to safe some money, you should take a look at S3 Lifecycle Rules (https://docs.aws.amazon.com/AmazonS3/latest/userguide/how-to-set-lifecycle-configuration-intro.html).

## Security
I recommend to create a new IAM user, which:
- can not login to the AWS Console
- can only access AWS programmatically
- is used by this add-on only
- uses the lowest possible IAM Policy, which is this:

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
Under the hood it uses the aws cli version 1, specifically the `aws s3 sync` command.

## Thanks
This addon is highly inspired by https://github.com/gdrapp/hass-addons and https://github.com/rrostt/hassio-backup-s3