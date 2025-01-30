#!/bin/bash

# 디버깅을 위한 로그 활성화
set -x

echo "Starting before_install script..."

# 현재 디렉토리 확인
pwd
ls -la

# 기존 디렉토리가 있다면 제거
if [ -d /home/ec2-user/nodes-on-aws ]; then
    echo "Removing existing directory..."
    rm -rf /home/ec2-user/nodes-on-aws || {
        echo "Failed to remove directory"
        exit 1
    }
fi

# 새 디렉토리 생성
echo "Creating new directory..."
mkdir -p /home/ec2-user/nodes-on-aws || {
    echo "Failed to create directory"
    exit 1
}

# 권한 설정
echo "Setting permissions..."
chown -R ec2-user:ec2-user /home/ec2-user/nodes-on-aws || {
    echo "Failed to set ownership"
    exit 1
}
chmod -R 755 /home/ec2-user/nodes-on-aws || {
    echo "Failed to set permissions"
    exit 1
}

echo "Directory permissions:"
ls -la /home/ec2-user/nodes-on-aws

echo "Before install script completed successfully"