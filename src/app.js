#!/usr/bin/env node


const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');


const app = express();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));


// 기본 라우트 추가
app.get('/', (req, res) => {
  res.send('서버가 정상적으로 실행중입니다.');
});


// 임시 사용자 저장소
const users = [];


// 회원가입 페이지 렌더링
app.get('/register', (req, res) => {
  res.send(`
    <form action="/register" method="POST">
      <input type="text" name="username" placeholder="사용자명">
      <input type="password" name="password" placeholder="비밀번호">
      <button type="submit">회원가입</button>
    </form>
  `);
});


// 회원가입 처리
app.post('/register', async (req, res) => {
  try {
    const { username, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
   
    users.push({
      username,
      password: hashedPassword
    });
   
    res.send('회원가입 성공!');
  } catch (error) {
    console.error('회원가입 에러:', error);
    res.status(500).send('회원가입 실패');
  }
});


const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0';


// 에러 처리 추가
app.listen(PORT, HOST, (err) => {
  if (err) {
    console.error('서버 시작 실패:', err);
    process.exit(1);
  }
  console.log(`서버가 ${HOST}:${PORT}에서 실행중입니다.`);
  console.log('사용 가능한 경로:');
  console.log(`- http://localhost:${PORT}/`);
  console.log(`- http://localhost:${PORT}/register`);
});


// 예기치 않은 에러 처리
process.on('uncaughtException', (err) => {
  console.error('예기치 않은 에러:', err);
  process.exit(1);
});