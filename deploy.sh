#!/bin/bash

set -e
set -u 

SUFFIX=$(date +%s)
FUNCTION_NAME=mistaker-${SUFFIX}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account | tr -d '"')

# Create the deployment package
echo 'Creating the deployment package'
zip function.zip mistaker.py

# Create the IAM policies and role needed by the lambda
# Update policy documents
# Cloudwatch log groups
ALL_LOG_GROUPS_ARN=arn:aws:logs:${AWS_REGION}:${AWS_ACCOUNT_ID}:*
CW_LOG_GROUP_ARN=arn:aws:logs:${AWS_REGION}:${AWS_ACCOUNT_ID}:log-group:/aws/lambda/${FUNCTION_NAME}:*
CW_POLICY_DOC=$(jq --arg Lg_Arn "${ALL_LOG_GROUPS_ARN}" --arg Cw_Arn "${CW_LOG_GROUP_ARN}" '.Statement[0].Resource |= $Lg_Arn 
| .Statement[1].Resource |= $Cw_Arn' cloudwatch_policy_template.json)

# Event config
LAMBDA_ARN=arn:aws:lambda:${AWS_REGION}:${AWS_ACCOUNT_ID}:function:${FUNCTION_NAME}

CLOUDWATCH_POLICY=$(aws iam create-policy --policy-name cloudwatch-policy-${FUNCTION_NAME} \
--policy-document "${CW_POLICY_DOC}" | jq .Policy.Arn | tr -d '"')

# Create role with trust document
EXECUTION_ROLE=$(aws iam create-role --role-name lambda-execution-role-${FUNCTION_NAME} \
--assume-role-policy-document file://deployment/trust_policy.json | jq .Role.Arn | tr -d '"')
echo ${EXECUTION_ROLE}

sleep 10

# Attach policy
echo 'Attaching policy to role'
aws iam attach-role-policy --policy-arn ${CLOUDWATCH_POLICY} --role-name lambda-execution-role-${FUNCTION_NAME}

sleep 10

# Create function
echo 'Creating function'
FUNCTION=$(aws lambda create-function --function-name ${FUNCTION_NAME} --runtime python3.9 \
--role ${EXECUTION_ROLE} \
--package-type Zip --handler mistaker.lambda_handler \
--zip-file function.zip)

# Rule config
echo 'Creating rule'
LAMBDA_ARN=arn:aws:lambda:${AWS_REGION}:${AWS_ACCOUNT_ID}:function:${FUNCTION_NAME}
RULE_NAME=${FUNCTION_NAME}-SCHEDULE
SCHEDULE='rate(1 minute)'
RULE_ARN=$(aws events put-rule --name ${RULE_NAME} --schedule-expression ${SCHEDULE} | jq .RuleArn | tr -d '"')


# Add permission to allow function to be invoked by scheduler
echo 'Adding Rule notification and permission'
PERMISSION=$(aws lambda add-permission --function-name ${FUNCTION_NAME} --principal events.amazonaws.com \
--statement-id rate_invoke --action "lambda:InvokeFunction" \
--source-arn ${RULE_ARN} \
--source-account ${AWS_ACCOUNT_ID})

RULE_TARGETS=$(aws events put-targets --rule ${RULE_NAME} --targets "Id"="${FUNCTION_NAME}","Arn"="${LAMBDA_ARN}")

set +u 
set +e 