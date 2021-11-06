# Changelog

## 1.2.0
- You can now configure if you want to automatically delete older backups and how many backups you want to keep locally.
  * `delete_local_backups` defaults to `true`, which means it will automatically delete older backups and keep `local_backups_to_keep` which defaults to `3`

## 1.0.0
- Initial release:
  * Uses the `aws s3 sync` cli command to sync the local backup folder   
  * Possibility to configure region, storage class, bucket