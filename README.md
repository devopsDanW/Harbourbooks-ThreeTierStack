1. Monitoring - CloudWatch Alarms +SNS
using AWS cli
created SNS topic
sns subscribe with email, confirm email
two CloudWatch alarm targeting on SNS topic
*added Cloudwatch alarm on EC2 instance's CPUUtilization (>70% for 5 consecutive minutes), sends a notification to an SNS topic subscribed with my email*
created CloudWatch Alarm "harbourbooks-ec2-cpu-high" to monitor CPU utilization, triggers after a single breaching data point \

`--statistic Average
 --period 300 \
 --evaluation-periods 1 \
 --threshold 70 \
 --comparison-operator GreaterThanThreshold \
 --alarm-actions arn:aws:sns
 --tags
`
*added CloudWatch Alarm on the EC2 instance's StatusCheckFailed metric is configured the same way.*
created CloudWatch Alarm "harbourbooks-ec2-status-check-failed" to check Status triggers on any failed check within 1 minute window \

`--statistic Maximum
 --period 60 \
 --evaluation-periods 1 \
 --threshold 1 \
 --comparison-operator GreaterThanOrEqualToThreshold \
 --alarm-actions arn:aws:sns
 --tags
`
Issue: no alerting on instance health
Resolution: CloudWatch allows early warning on resources with email notification on time instead of watch dashboard actively

2. least-privilege principle - EC2 Security Group Egress
*ec2-sg egress is narrowed from allow-all to only TCP 443 (image pulls) and TCP 3306 to rds-sg — nothing else outbound is permitted.*
Remove ec2-sg egress from allow-all
`--protocol -1
--cidr 0.0.0.0/0
`
authorize to pull Docker images
`--protocol tcp
 --port 443
 --cidr 0.0.0.0/0
 `
also authorize TCP 3306 to rds-sg
`--protocol tcp
 --port 3306
 --source-group
 `
Issue: Security group's outbound rule is wide open, if the instance were ever compromised, the attacker would send data to any destination on any port
Resolution: narrow sg egress reduces data exfiltration or lateral movement

3. proper credentials - Secrets Manager(stores and auto-rotate password) + IAM least-privilege + get credentials on container startup through network rather than .env
*Migrated RDS master password out of the shell variable into RDS's manage-master-user-password*
aws rds modify-db-instance --manage-master-user-password --apply-immediately
created secret-read-policy and attached to ec2-ssm-role
import boto3 - python AWS SDK to get GetSecretValue API from Secrets Manager to connect RDS

Issue: DB password sits in a shell variable on the instance's disk
Resolution: .env is available to users who have access, while secrets manager allows password stored encrypted, access with IAM role, CloudTrail audit

.env includes DB_SECRET_ARN, DB_HOST,DB_NAME, AWS_REGION
DB_SECRET_ARN points to a secret in Secret Manager, which contains username and password

*tag SNS topic, alarms, updated SG, secret*
--tags Key=Project,Value=harbour-books Key=Owner,Value=Dan Key=Environment,Value=dev

