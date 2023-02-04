#!/bin/bash

set -e
set -u 

FUNCTION_NAME=mistaker-test
AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq .Account | tr -d '"')

# Create the IAM policies and role needed by the lambda
# Update policy documents
# Cloudwatch log groups
ALL_LOG_GROUPS_ARN=arn:aws:logs:${AWS_REGION}:${AWS_ACCOUNT_ID}:*
CW_LOG_GROUP_ARN=arn:aws:logs:${AWS_REGION}:${AWS_ACCOUNT_ID}:log-group:/aws/lambda/${FUNCTION_NAME}:*
CW_POLICY_DOC=$(jq --arg Lg_Arn "${ALL_LOG_GROUPS_ARN}" --arg Cw_Arn "${CW_LOG_GROUP_ARN}" '.Statement[0].Resource |= $Lg_Arn 
| .Statement[1].Resource |= $Cw_Arn' cloudwatch_policy_template.json)

CLOUDWATCH_POLICY=$(aws iam create-policy --policy-name cloudwatch-policy-${FUNCTION_NAME} \
--policy-document "${CW_POLICY_DOC}" | jq .Policy.Arn | tr -d '"')

# Create role with trust document
EXECUTION_ROLE=$(aws iam create-role --role-name lambda-execution-role-${FUNCTION_NAME} \
--assume-role-policy-document file://trust.json | jq .Role.Arn | tr -d '"')
echo ${EXECUTION_ROLE}

sleep 10

# Attach policy
echo 'Attaching policy to role'
aws iam attach-role-policy --policy-arn ${CLOUDWATCH_POLICY} --role-name lambda-execution-role-${FUNCTION_NAME}

echo 'Done'
set +u 
set +e 
