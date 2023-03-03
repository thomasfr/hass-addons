# Changelog

## 1.2.2

- Backup Script was running twice since it was still in services.d folder. Removed all unnecessary files.
- Removed unnecassary Executable bits from .md files
- Thanks to [HarryEMartland](https://github.com/HarryEMartland) and [atrepca](https://github.com/atrepca) for contributing.

## 1.2.1

- Added missing CMD to the Dockerfile. This was reported by several users (Thanks for reporting and being patient with me). I added the CMD so i hope it works now for everyone. If not please create another issue

## 1.2.0

- You can now configure if you want to automatically delete older backups and how many backups you want to keep locally.
  - `delete_local_backups` defaults to `true`, which means it will automatically delete older backups and keep `local_backups_to_keep` which defaults to `3`

## 1.0.0

- Initial release:
  - Uses the `aws s3 sync` cli command to sync the local backup folder
  - Possibility to configure region, storage class, bucket
