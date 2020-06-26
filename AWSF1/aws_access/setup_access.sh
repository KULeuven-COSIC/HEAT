#!/bin/bash

HOST="centos@ec2-34-248-40-63.eu-west-1.compute.amazonaws.com"

# Setup passwordless SSH access
cat ~/.ssh/id_rsa.pub | (ssh -i "aws_exp.pem" $HOST "cat >> ~/.ssh/authorized_keys")

# Copy preparation script to the aws instance
scp     prepare_environment.sh $HOST:~/.

# Copy the software directory
scp -r  ../software $HOST:~/.
scp -r  ../software_multicore $HOST:~/.
scp -r  ../nneval_app $HOST:~/.