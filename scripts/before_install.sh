#!/bin/bash

# 필요한 패키지 설치
sudo yum update -y
sudo yum install -y nodejs npm

# 애플리케이션 디렉토리 생성
sudo mkdir -p /home/ec2-user/nodes-on-aws
cd /home/ec2-user/nodes-on-aws

# PM2 전역 설치
sudo npm install -g pm2

# 프로젝트 의존성 설치
npm install
