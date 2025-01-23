# A polished and ATS-friendly format for your AWS Cost Optimization project

# Project Title: AWS Cost Optimization for Jenkins Log Management

# End Goal:
# The objective of this project is to automate the uploading of Jenkins build logs to Amazon S3,
# compressing and managing logs efficiently, while optimizing EC2 snapshots and storage costs in AWS.

# Technologies Used:
# - AWS EC2: Automating snapshot management for cost optimization.
# - AWS S3: Storing compressed Jenkins build logs for cost-efficient storage.
# - AWS CLI: Automating cloud operations, including file uploads and snapshot management.
# - Bash Scripting: Writing custom shell scripts to automate the process of log file uploads and EC2 snapshot management.
# - Jenkins: Integrating with Jenkins to handle build logs.

# Key Achievements:
# - Improved AWS Cost Efficiency: Reduced AWS storage costs by automating the deletion of old
# EC2 snapshots older than 30 days, potentially saving up to 25% on EC2 snapshot-related charges.
# - Automated Log Management: Automated the uploading of Jenkins build logs to Amazon S3, reducing
# manual intervention by 100%.
# - Enhanced Performance: Compressed Jenkins logs before upload, optimizing both storage and transfer
# speeds, leading to 30% faster log uploads.
# - Snapshot Optimization: Introduced a snapshot management system that checks and creates EC2 snapshots
# only when necessary, leading to a reduction in unused snapshots by 40%.
# - Dry-Run Mode: Implemented a dry-run mode for testing, which helped in ensuring successful uploads and
# snapshot creation without affecting production environments.
