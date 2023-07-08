#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Amazon S3 Backup
# ==============================================================================
#bashio::log.level "debug"

bashio::log.info "Starting Amazon S3 Backup..."

bucket_name="$(bashio::config 'bucket_name')"
storage_class="$(bashio::config 'storage_class' 'STANDARD')"
bucket_region="$(bashio::config 'bucket_region' 'eu-central-1')"
bucket_region_other="$(bashio::config 'bucket_region_other' '')"
endpoint_url="$(bashio::config 'endpoint_url' '')"
delete_local_backups="$(bashio::config 'delete_local_backups' 'true')"
local_backups_to_keep="$(bashio::config 'local_backups_to_keep' '3')"
monitor_path="/backup"
jq_filter=".backups|=sort_by(.date)|.backups|reverse|.[$local_backups_to_keep:]|.[].slug"

export AWS_ACCESS_KEY_ID="$(bashio::config 'aws_access_key')"
export AWS_SECRET_ACCESS_KEY="$(bashio::config 'aws_secret_access_key')"
export AWS_REGION="$bucket_region"

# Set optional flags
[[ -n "$endpoint_url" ]] && ENDPOINT="--endpoint-url $endpoint_url"
[[ "$storage_class" != "None" ]] && STORAGECLASS="--storage-class $storage_class"
if [ "$bucket_region" == "other" ]; then
  [[ -n "$bucket_region_other" ]] && BUCKETREGION="--region $bucket_region_other"
else
  BUCKETREGION="--region $bucket_region"
fi

bashio::log.debug "Using AWS CLI version: '$(aws --version)'"
COMMAND="aws ${ENDPOINT:=} s3 sync $monitor_path s3://$bucket_name/ --no-progress ${BUCKETREGION:=} ${STORAGECLASS:=}"
bashio::log.debug "Command: '$COMMAND'"
$COMMAND

if bashio::var.true "${delete_local_backups}"; then
    bashio::log.info "Will delete local backups except the '${local_backups_to_keep}' newest ones."
    backup_slugs="$(bashio::api.supervisor "GET" "/backups" "false" "$jq_filter")"
    bashio::log.debug "Backups to delete: '$backup_slugs'"

    for s in $backup_slugs; do
        bashio::log.info "Deleting Backup: '$s'"
        bashio::api.supervisor "DELETE" "/backups/$s"
    done
else
    bashio::log.info "Will not delete any local backups since 'delete_local_backups' is set to 'false'"
fi

bashio::log.info "Finished Amazon S3 Backup."