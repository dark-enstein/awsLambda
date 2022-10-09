#! /bin/bash

echo "Enter AWS Account ID"
read accountid
ACCOUNT_ID=$accountid

if ! aws --version; then
  echo "Installing AWS CLI..."
  echo "1) Downloading AWS CLI..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  echo "2) Installing AWS CLI..."
  sudo ./aws/install
  echo "AWS CLI successfully installed!"
  rm -f awscliv2.zip

  echo "Setting up AWS Credentials"
  echo "Enter your AWS Access Key"
  read access
  ACCESS_KEY=$access
  echo "Enter your AWS Secret Access Key"
  read password
  SECRET_KEY=$password

  aws configure set default.region us-east-1
  aws configure set aws_access_key_id $ACCESS_KEY
  aws configure set aws_secret_access_key $SECRET_KEY

  FILE=~/.aws/credentials
  if test -f "$FILE" | [ -s diff.txt ] ; then
      echo "AWS Credentials successfully configured"
  fi
else
  echo "AWS CLI is already installed"
  echo "Enter AWS profile that should be used"
  read profile
fi

#Lambda aws cli commands
aws iam create-role --role-name lambda-ex --assume-role-policy-document file://trust-policy.json --profile $profile

aws iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole --profile $profile

#package go program
go mod tidy
go build main.go

if [ $? != 0 ]; then
  echo "Encountered issue while building main.go file"
  exit 1
else
  echo "Application binary successfully built"
fi

zip function-main.zip main

for i in `ls *`; do
  if [ i == "main" ]; then
    echo "Main found"
    break
  else
    echo "main binary not found"
    continue
  fi
done

#deploy to lambda

aws lambda create-function --function-name awsLambda \
--zip-file fileb://function.zip --handler main --runtime go1.x \
--role arn:aws:iam::$ACCOUNT_ID:role/lambda-ex

#aws invoke