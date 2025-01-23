#!/bin/bash

# Author: Azeemuddin Shaik
# Description: This script uploads Jenkins build logs created today to an S3 bucket, with snapshot optimizations.
# It checks if AWS CLI is installed, compresses logs, uploads them to S3, deletes them from EC2, and manages EC2 snapshots to optimize AWS costs.

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Variables
JENKINS_HOME="${JENKINS_HOME:-/var/lib/jenkins}"  # Default to /var/lib/jenkins if not set in .env
S3_BUCKET="${S3_BUCKET:-s3://your-s3-bucket-name}"  # Default to your S3 bucket if not set in .env
DATE=$(date +%Y-%m-%d)  # Today's date
LOG_FILE="/var/log/upload_jenkins_build_logs.log"  # Log file path
DRY_RUN="${DRY_RUN:-false}"  # Default to false if not set in .env
COMPRESSION="${COMPRESSION:-true}"  # Enable compression by default
SNAPSHOT_ENABLED="${SNAPSHOT_ENABLED:-false}"  # Option to enable EC2 snapshots (default is false)

# Function to log messages
log_message() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - $1" | tee -a "$LOG_FILE"
}

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        log_message "AWS CLI is not installed. Please install it to proceed."
        exit 1
    fi
}

# Function to compress log files
compress_log_file() {
    local log_file=$1
    local compressed_log="$log_file.gz"
    log_message "Compressing log file: $log_file"
    gzip -c "$log_file" > "$compressed_log"
    echo "$compressed_log"
}

# Function to delete log file from EC2 instance
delete_log_file() {
    local log_file=$1
    log_message "Deleting log file: $log_file from EC2 instance"
    rm "$log_file"
}

# Function to upload log files to S3
upload_log_file() {
    local log_file=$1
    local s3_path=$2

    if [ "$DRY_RUN" = true ]; then
        log_message "Dry run: aws s3 cp $log_file $s3_path"
    else
        aws s3 cp "$log_file" "$s3_path" --only-show-errors
        if [ $? -eq 0 ]; then
            log_message "Uploaded: $log_file to $s3_path"
            delete_log_file "$log_file"  # Delete log file from EC2 after successful upload
        else
            log_message "Failed to upload: $log_file"
        fi
    fi
}

# Function to take a snapshot of the EC2 instance
take_snapshot() {
    if [ "$SNAPSHOT_ENABLED" = true ]; then
        instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
        timestamp=$(date +%Y-%m-%d-%H-%M-%S)
        snapshot_name="jenkins-snapshot-$timestamp"
        log_message "Creating EC2 snapshot: $snapshot_name"

        # Create a snapshot of the EC2 instance's root volume
        snapshot_id=$(aws ec2 create-snapshot --volume-id $(aws ec2 describe-instances --instance-ids $instance_id --query "Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId" --output text) --description "$snapshot_name" --query "SnapshotId" --output text)
        
        if [ $? -eq 0 ]; then
            log_message "Snapshot created successfully: $snapshot_id"
        else
            log_message "Failed to create snapshot."
        fi
    fi
}

# Function to delete old snapshots (older than 30 days)
delete_old_snapshots() {
    if [ "$SNAPSHOT_ENABLED" = true ]; then
        log_message "Deleting snapshots older than 30 days"
        old_snapshots=$(aws ec2 describe-snapshots --filters Name=tag:Name,Values=jenkins-snapshot-* --query "Snapshots[?StartTime<'$(date --date='30 days ago' +%Y-%m-%dT%H:%M:%S)'].SnapshotId" --output text)
        
        if [ -n "$old_snapshots" ]; then
            for snapshot_id in $old_snapshots; do
                log_message "Deleting snapshot: $snapshot_id"
                aws ec2 delete-snapshot --snapshot-id $snapshot_id
            done
        fi
    fi
}

# Main script
check_aws_cli

# Ensure Jenkins jobs directory exists
if [ ! -d "$JENKINS_HOME/jobs" ]; then
    log_message "Jenkins jobs directory not found: $JENKINS_HOME/jobs"
    exit 1
fi

# Optionally delete old snapshots (older than 30 days)
delete_old_snapshots

# Optionally create a snapshot before uploading logs
take_snapshot

# Iterate through Jenkins job directories
for job_dir in "$JENKINS_HOME/jobs/"*/; do
    job_name=$(basename "$job_dir")

    if [ ! -d "$job_dir/builds" ]; then
        log_message "Builds directory not found for job: $job_name"
        continue
    fi

    # Iterate through build directories for each job
    for build_dir in "$job_dir/builds/"*/; do
        log_file="$build_dir/log"

        # Check if log file exists and was created today
        if [ -f "$log_file" ] && [ "$(date -r "$log_file" +%Y-%m-%d)" == "$DATE" ]; then
            # Compress log file if enabled
            if [ "$COMPRESSION" = true ]; then
                log_file=$(compress_log_file "$log_file")
            fi

            # Upload log file to S3 with the build number as the filename
            s3_path="$S3_BUCKET/$job_name-$(basename "$build_dir").log"
            upload_log_file "$log_file" "$s3_path"

            # Clean up compressed log if it was created
            if [ -f "$log_file" ] && [[ "$log_file" == *.gz ]]; then
                log_message "Removing compressed log file: $log_file"
                rm "$log_file"
            fi
        fi
    done
done
