#!/bin/bash


# 스크립트 실행 중 오류 발생시 즉시 중단
set -e


# 기존 애플리케이션 디렉토리가 있다면 제거
if [ -d /home/ec2-user/nodes-on-aws ]; then
    sudo rm -rf /home/ec2-user/nodes-on-aws
fi


# 애플리케이션 디렉토리 생성 및 권한 설정
sudo mkdir -p /home/ec2-user/nodes-on-aws
sudo chown -R ec2-user:ec2-user /home/ec2-user/nodes-on-aws


# Node.js 설치 (없는 경우)
if ! command -v node &> /dev/null; then
    curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
    sudo yum install -y nodejs
fi


# npm이 설치되어 있지 않은 경우 설치
if ! command -v npm &> /dev/null; then
    sudo yum install -y npm
fi


# PM2가 설치되어 있지 않은 경우 전역으로 설치
if ! command -v pm2 &> /dev/null; then
    sudo npm install -g pm2
fi


# 애플리케이션 디렉토리로 이동
cd /home/ec2-user/nodes-on-aws


# package.json이 있는 경우에만 npm install 실행
if [ -f "package.json" ]; then
    npm install
fi
