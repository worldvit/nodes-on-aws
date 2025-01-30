#!/bin/bash

# 디버깅을 위한 로그 추가
echo "Deployment directory content check:"
ls -la /home/ec2-user/nodes-on-aws/

# 권한 재설정
sudo chown -R ec2-user:ec2-user /home/ec2-user/nodes-on-aws
sudo chmod -R 755 /home/ec2-user/nodes-on-aws

echo "Final directory content and permissions:"
ls -la /home/ec2-user/nodes-on-aws/ 