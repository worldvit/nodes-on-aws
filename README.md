* 애플리케이션 생성
aws deploy create-application --application-name nodes-on-aws --compute-platform Server

* 배포 그룹 생성 할때 아래의 값은 본인의 설정에 맞게 변경해주세요.
* arn:aws:iam::676206941602:role/kevin-CodeDeployRole
* --region us-west-2
* --ec2-tag-filters Key=Name,Type=KEY_AND_VALUE,Value=express-app-ec2 Key=Purpose,Type=KEY_AND_VALUE,Value=nodejs-app

//============================================
aws deploy create-deployment-group --application-name nodes-on-aws  --deployment-group-name nodes-on-aws-group --service-role-arn arn:aws:iam::676206941602:role/kevin-CodeDeployRole --deployment-style deploymentType=IN_PLACE,deploymentOption=WITHOUT_TRAFFIC_CONTROL --ec2-tag-filters Key=Name,Type=KEY_AND_VALUE,Value=express-app-ec2 Key=Purpose,Type=KEY_AND_VALUE,Value=nodejs-app --auto-rollback-configuration enabled=true,events=DEPLOYMENT_FAILURE --region us-west-2


# Node.js 애플리케이션 AWS 배포 가이드

## 1. 프로젝트 초기 설정

프로젝트 생성
mkdir nodes-on-aws
cd nodes-on-aws
npm init -y
필요한 패키지 설치
npm install express bcryptjs body-parser

# 필요한 패키지 설치
npm install express bcryptjs body-parser

## 4. AWS CodeDeploy 설정 파일

### appspec.yml
```yaml:README.md
version: 0.0
os: linux
files:
  - source: /
    destination: /home/ec2-user/nodes-on-aws
permissions:
  - object: /home/ec2-user/nodes-on-aws
    pattern: "**"
    owner: ec2-user
    group: ec2-user
    mode: 755
hooks:
  BeforeInstall:
    - location: scripts/before_install.sh
      timeout: 300
      runas: root
  ApplicationStart:
    - location: scripts/application_start.sh
      timeout: 300
      runas: root
```

### scripts/before_install.sh
```bash
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
    curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
    sudo yum install -y nodejs
fi

# PM2 설치 (없는 경우)
if ! command -v pm2 &> /dev/null; then
    sudo npm install -g pm2
fi
```

### scripts/application_start.sh
```bash
#!/bin/bash

# 스크립트 실행 중 오류 발생시 즉시 중단
set -e

# 애플리케이션 디렉토리로 이동
cd /home/ec2-user/nodes-on-aws

# 의존성 패키지 설치
npm install

# 이전 PM2 프로세스 중지
pm2 stop all || true
pm2 delete all || true

# 환경 변수 설정
export PORT=3000
export NODE_ENV=production

# PM2로 애플리케이션 시작
pm2 start src/app.js --name "nodes-on-aws"

# PM2 startup 설정 및 저장
pm2 startup
pm2 save
```

## 5. AWS 설정

### 5.1 EC2 인스턴스 태그 설정
- Name: express-app-ec2
- Purpose: nodejs-app

### 5.2 CodeDeploy 애플리케이션 생성
```bash
aws deploy create-application \
    --application-name nodes-on-aws \
    --compute-platform Server
```

### 5.3 CodeDeploy 배포 그룹 생성
```bash
aws deploy create-deployment-group \
    --application-name nodes-on-aws \
    --deployment-group-name nodes-on-aws-group \
    --service-role-arn arn:aws:iam::676206941602:role/kevin-CodeDeployRole \
    --deployment-style deploymentType=IN_PLACE,deploymentOption=WITHOUT_TRAFFIC_CONTROL \
    --ec2-tag-filters Key=Name,Type=KEY_AND_VALUE,Value=express-app-ec2 Key=Purpose,Type=KEY_AND_VALUE,Value=nodejs-app \
    --auto-rollback-configuration enabled=true,events=DEPLOYMENT_FAILURE \
    --region us-west-2
```

## 6. EC2 인스턴스 설정

### 6.1 CodeDeploy 에이전트 설치
```bash
sudo yum update
sudo yum install ruby
sudo yum install wget
cd /home/ec2-user
wget https://aws-codedeploy-us-west-2.s3.us-west-2.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent status
```

### 6.2 Node.js 및 PM2 설치
```bash
# Node.js 설치
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs

# PM2 설치
sudo npm install -g pm2
```

## 7. 보안 그룹 설정
- SSH (포트 22): 0.0.0.0/0
- HTTP (포트 80): 0.0.0.0/0
- Custom TCP (포트 3000): 0.0.0.0/0

## 8. 배포 확인
```bash
# 배포 그룹 정보 확인
aws deploy get-deployment-group \
    --application-name nodes-on-aws \
    --deployment-group-name nodes-on-aws-group \
    --region us-west-2

# 애플리케이션 상태 확인
pm2 list
pm2 logs

# 포트 확인
sudo ss -tulpn | grep 3000
```

## 주의사항
1. IAM 역할이 올바르게 설정되어 있어야 합니다.
2. EC2 인스턴스의 태그가 정확히 설정되어 있어야 합니다.
3. CodeDeploy 에이전트가 실행 중이어야 합니다.
4. 보안 그룹에서 필요한 포트가 열려있어야 합니다.