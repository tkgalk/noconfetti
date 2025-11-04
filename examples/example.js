// JavaScript/Node.js Example - Express API Server
// Testing: comments, strings, numbers, keywords, functions, types

import express from 'express';
import { createServer } from 'http';

/**
 * User model representing application users
 * @param {string} name - The user's full name
 * @returns {Object} User object
 */
class User {
  constructor(name, email, age) {
    this.name = name;
    this.email = email;
    this.age = age;
    this.createdAt = new Date();
  }

  isAdult() {
    return this.age >= 18;
  }

  getProfile() {
    return {
      name: this.name,
      email: this.email,
      age: this.age,
      adult: this.isAdult(),
    };
  }
}

// Constants and configuration
const PORT = process.env.PORT || 3000;
const API_VERSION = 'v1';
const MAX_RETRIES = 5;
const TIMEOUT_MS = 30000;
const DEBUG = true;

// Initialize Express app
const app = express();
app.use(express.json());

// Helper function with async/await
async function fetchUserData(userId) {
  try {
    const response = await fetch(`https://api.example.com/users/${userId}`);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error('Failed to fetch user data:', error);
    return null;
  }
}

// Route handlers
app.get('/api/users/:id', async (req, res) => {
  const userId = req.params.id;
  const userData = await fetchUserData(userId);

  if (!userData) {
    return res.status(404).json({ error: 'User not found' });
  }

  res.json(userData);
});

app.post('/api/users', (req, res) => {
  const { name, email, age } = req.body;
  const user = new User(name, email, age);

  res.status(201).json(user.getProfile());
});

// Array methods and destructuring
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.map(n => n * 2);
const evens = numbers.filter(n => n % 2 === 0);
const sum = numbers.reduce((acc, n) => acc + n, 0);

// Object destructuring and spread
const config = { host: 'localhost', port: 8080, ssl: true };
const { host, ...rest } = config;
const newConfig = { ...config, timeout: 5000 };

// Template literals
const message = `Server running on ${host}:${PORT}`;
const multiline = `
  This is a multiline
  string with ${API_VERSION}
`;

// Start server
const server = createServer(app);
server.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});

export { User, fetchUserData };
