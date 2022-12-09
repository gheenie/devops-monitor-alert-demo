# Monitoring and Alerting

This exercise is meant to test your understanding of using Cloudwatch logs as a source of alarms and alerting for potential errors.

The lambda defined in `mistaker.py` is designed to make mistakes. It has a random number generator that will cause an error if the generated number is a multiple of five. 

You can deploy this useful piece of software by:
1. Forking and cloning this repo.
1. Running:
  ```bash
  make requirements
  make dev-setup
  make run-checks
  ```
3. Creating a sandbox
1. Updating your AWS credentials
1. Authenticating via `awsume` or other method
1. And running `./deploy.sh`

Then go have a cup of tea, coffee or other refreshment. A few minutes later, you can run these commands:
```bash
FUNCTION_NAME=FUNCTION_NAME=$(aws lambda list-functions | jq '.Functions[0].FunctionName' | tr -d '"')
aws logs tail /aws/lambda/${FUNCTION_NAME} --region us-east-1
```
The application logs activity every minute so eventually you should see something similar to this:
```bash
2022-12-09T07:58:02.621000+00:00 2022/12/09/[$LATEST]11821906d1b44631bcd0c624a7423261 [WARNING]	2022-12-09T07:58:02.620Z	ee4748fc-bbde-4ab4-a054-7b673a27df13	Oh no 15 is divisible by 5
2022-12-09T07:58:02.621000+00:00 2022/12/09/[$LATEST]11821906d1b44631bcd0c624a7423261 [ERROR] MultipleOfFiveError
Traceback (most recent call last):
  File "/var/task/mistaker.py", line 16, in lambda_handler
    raise MultipleOfFiveError
```

Your task is to create an alerting process that sends you an email whenever one of these "ERROR" log messages appears.

To do this, you will need to fill in the script `alarm.sh` with commands to:
1. Make a metric filter that spots the "ERROR" event.
1. Create an SNS topic that includes your email address as a subscriber.
1. Create a Cloudwatch alarm based on the metric filter and which uses the SNS topic.

You should be able to run the script to deploy these items. You should then receive an email request to subscribe to the SNS topic. If you accept, then sometime later, you should start getting emails alerting you to the errors. At that point you might want to delete the alarm or destroy your sandbox as you will likely get a _lot_ of emails. 