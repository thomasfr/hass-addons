#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Amazon S3 Backup
# ==============================================================================
#bashio::log.level "debug"

bashio::log.info "Starting Amazon S3 Backup..."

bucket_name="$(bashio::config 'bucket_name')"
storage_class="$(bashio::config 'storage_class' 'STANDARD')"
bucket_region="$(bashio::config 'bucket_region' 'eu-central-1')"
delete_local_backups="$(bashio::config 'delete_local_backups' 'true')"
local_backups_to_keep="$(bashio::config 'local_backups_to_keep' '3')"
monitor_path="/backup"
jq_filter=".backups|=sort_by(.date)|.backups|reverse|.[$local_backups_to_keep:]|.[].slug"

export AWS_ACCESS_KEY_ID="$(bashio::config 'aws_access_key')"
export AWS_SECRET_ACCESS_KEY="$(bashio::config 'aws_secret_access_key')"
export AWS_REGION="$bucket_region"

bashio::log.debug "Using AWS CLI version: '$(aws --version)'"

readarray -t backups < <(bashio::api.supervisor GET /backups/info false .backups | jq -c '.[]')
for backup in "${backups[@]}"; do
  bashio::log.debug $(echo "${backup}" | jq -C .)

  slug=$(echo "${backup}" | jq -r .slug)
  name=$(echo "${backup}" | jq -r .name)

  bashio::log.info "Uploading ${name}"

  bashio::log.debug "Command: aws s3 cp ${monitor_path}/${slug}.tar s3://${bucket_name}/${name}.tar --no-progress --region ${bucket_region} --storage-class ${storage_class} --metadata '<omitted>'"
  aws s3 cp "${monitor_path}/${slug}.tar" "s3://${bucket_name}/${name}.tar" --no-progress --region "${bucket_region}" --storage-class "${storage_class}" \
    --metadata "$(echo "${backup}" | jq '{slug:.slug,name:.name,date:.date,type:.type,size:.size,protected:.protected,compressed:.compressed,homeassistant:.content.homeassistant,addons:.content.addons,folders:.content.folders} | map_values(tostring)')"
done

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
