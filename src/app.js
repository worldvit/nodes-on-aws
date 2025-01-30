const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');

const app = express();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

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
    res.status(500).send('회원가입 실패');
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`서버가 포트 ${PORT}에서 실행중입니다.`);
});
