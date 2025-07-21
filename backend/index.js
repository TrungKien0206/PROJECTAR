const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Kết nối MongoDB
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/ar_app_db';
mongoose.connect(MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB connection error:', err));

// Định nghĩa User Schema
const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true },
});
const User = mongoose.model('User', userSchema);

// Secret key cho JWT
const JWT_SECRET = process.env.JWT_SECRET || 'ar_app_secret_key_123';

// Đăng ký
app.post('/api/register', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ message: 'Thiếu username hoặc password' });
  }
  try {
    const userExists = await User.findOne({ username });
    if (userExists) {
      return res.status(409).json({ message: 'Tài khoản đã tồn tại' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ username, password: hashedPassword });
    await newUser.save();
    res.json({ message: 'Đăng ký thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error });
  }
});

// Đăng nhập
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(401).json({ message: 'Sai tài khoản hoặc mật khẩu' });
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Sai tài khoản hoặc mật khẩu' });
    }
    const token = jwt.sign({ userId: user._id, username: user.username }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, username: user.username });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error });
  }
});

// Test API
app.get('/', (req, res) => {
  res.send('AR App Backend with MongoDB is running!');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Backend server running at http://localhost:${PORT}`);
}); 