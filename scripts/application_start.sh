#!/bin/bash

# 스크립트 실행 중 오류 발생시 즉시 중단
set -e

# 애플리케이션 디렉토리로 이동
cd /home/ec2-user/nodes-on-aws

# Node.js와 npm이 설치되어 있는지 확인
if ! command -v node &> /dev/null; then
    curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
    sudo yum install -y nodejs
fi

# 의존성 패키지 설치
sudo npm install

# 이전 PM2 프로세스 중지
sudo pm2 stop all || true
sudopm2 delete all || true

# 실행 권한 확인 및 부여
chmod +x src/app.js

# 환경 변수 설정
export PORT=3000
export NODE_ENV=production

# PM2로 애플리케이션 시작
sudo pm2 start src/app.js --name "nodes-on-aws" -- --port 3000

# PM2 startup 설정 및 저장
sudo pm2 startup
sudo pm2 save

# 실행 상태 확인
sudo pm2 list
