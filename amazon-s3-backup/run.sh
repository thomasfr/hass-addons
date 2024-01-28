#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Amazon S3 Backup
# ==============================================================================
#bashio::log.level "debug"


bucket_name="$(bashio::config 'bucket_name')"
storage_class="$(bashio::config 'storage_class' 'STANDARD')"
bucket_region="$(bashio::config 'bucket_region' 'eu-central-1')"
delete_local_backups="$(bashio::config 'delete_local_backups' 'true')"
local_backups_to_keep="$(bashio::config 'local_backups_to_keep' '3')"
monitor_path="/backup"
jq_filter=".backups|=sort_by(.date)|.backups|reverse|.[$local_backups_to_keep:]|.[].slug"

bashio::log.info "Configure S3 Backup..."
aws configure set aws_access_key_id "$(bashio::config 'aws_access_key')"
aws configure set aws_secret_access_key "$(bashio::config 'aws_secret_access_key')"

aws configure set plugins.endpoint awscli_plugin_endpoint
if bashio::config.has_value "endpoint_url"; then
    endpoint_url="$(bashio::config 'endpoint_url' '')"
    bashio::log.info "Configure Amazon S3 Backup endpoint to ${endpoint_url}"
    aws configure set s3.endpoint_url "${endpoint_url}"
    aws configure set s3api.endpoint_url "${endpoint_url}"
fi

if bashio::config.has_value "max_concurrent_requests"; then
    aws configure set s3.max_concurrent_requests "$(bashio::config 'max_concurrent_requests' '10')"
fi

aws configure set region "$(bashio::config 'bucket_region' 'eu-central-1')"

bashio::log.info "Starting Amazon S3 Backup..."
bashio::log.debug "Using AWS CLI version: '$(aws --version)'"
bashio::log.debug "Command: 'aws s3 sync $monitor_path s3://$bucket_name/ --no-progress --region $bucket_region --storage-class $storage_class'"
aws s3 sync $monitor_path s3://"$bucket_name"/ --no-progress --region "$bucket_region" --storage-class "$storage_class"

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