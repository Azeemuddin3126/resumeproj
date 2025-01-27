#!/bin/bash

# Description: Upload Jenkins logs to S3, compress them, clean up EC2, and manage snapshots for cost optimization.

# Load .env variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found."
    exit 1
fi

# Constants
DATE=$(date +%Y-%m-%d)
LOG_FILE="/var/log/upload_logs.log"

# Helper for logging
log() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - $1" | tee -a "$LOG_FILE"
}

# Verify AWS CLI is installed
if ! command -v aws &> /dev/null; then
    log "Error: AWS CLI not installed."
    exit 1
fi

# Compress and upload log to S3
upload_to_s3() {
    local log_file=$1
    local s3_path=$2

    # Check if DRY_RUN is true, if so, do not execute the command
    if [ "$DRY_RUN" == "true" ]; then
        log "DRY_RUN: Would upload $log_file to $s3_path"
    else
        gzip -c "$log_file" > "$log_file.gz"
        aws s3 cp "$log_file.gz" "$s3_path" --only-show-errors && rm -f "$log_file.gz" "$log_file"
        log "Uploaded: $log_file.gz to $s3_path"
    fi
}

# Manage EC2 snapshots
manage_snapshots() {
    if [ "$SNAPSHOT_ENABLED" = true ]; then
        local instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
        local volume_id=$(aws ec2 describe-instances --instance-ids $instance_id \
            --query "Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId" --output text)

        # Create snapshot
        if [ "$DRY_RUN" == "true" ]; then
            log "DRY_RUN: Would create snapshot for volume $volume_id"
        else
            local snapshot_id=$(aws ec2 create-snapshot --volume-id $volume_id \
                --description "Snapshot-$(date +%Y-%m-%d-%H-%M-%S)" --query "SnapshotId" --output text)
            log "Created snapshot: $snapshot_id"
        fi

        # Delete old snapshots
        if [ "$DRY_RUN" == "true" ]; then
            log "DRY_RUN: Would delete snapshots older than 30 days for volume $volume_id"
        else
            aws ec2 describe-snapshots --filters Name=volume-id,Values=$volume_id \
                --query "Snapshots[?StartTime<'$(date --date='30 days ago' +%Y-%m-%dT%H:%M:%S)'].SnapshotId" \
                --output text | xargs -r -I {} aws ec2 delete-snapshot --snapshot-id {}
            log "Deleted snapshots older than 30 days."
        fi
    fi
}

# Main process: Upload logs
if [ -d "$JENKINS_HOME/jobs" ]; then
    for job_dir in "$JENKINS_HOME/jobs/"*/; do
        for build_dir in "$job_dir/builds/"*/; do
            log_file="$build_dir/log"
            if [ -f "$log_file" ] && [ "$(date -r "$log_file" +%Y-%m-%d)" == "$DATE" ]; then
                s3_path="$S3_BUCKET/$(basename "$job_dir")-$(basename "$build_dir").log.gz"
                upload_to_s3 "$log_file" "$s3_path"
            fi
        done
    done
else
    log "Error: Jenkins jobs directory not found."
    exit 1
fi

# Snapshot management
manage_snapshots

