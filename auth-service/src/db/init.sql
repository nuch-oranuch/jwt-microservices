-- สร้าง table สำหรับ users (auth data เท่านั้น)
CREATE TABLE IF NOT EXISTS auth_users (
  id        SERIAL PRIMARY KEY,
  user_id   VARCHAR(50) UNIQUE NOT NULL,   -- shared ID กับ user-service
  email     VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role      VARCHAR(20) DEFAULT 'member',  -- member, admin
  created_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP
);

-- ข้อมูลทดสอบ (password: "password123" → bcrypt hash)
INSERT INTO auth_users (user_id, email, password_hash, role) VALUES
  ('user-001', 'alice@example.com',
   '$2y$10$uvZCZBc.TMN3KG9gyDwUiO7kLL8t.LAcmHYzoz1ecuBgXZ2DBRD82', 'member'),
  ('user-002', 'bob@example.com',
   '$2y$10$uvZCZBc.TMN3KG9gyDwUiO7kLL8t.LAcmHYzoz1ecuBgXZ2DBRD82', 'member'),
  ('user-admin', 'admin@example.com',
   '$2y$10$uvZCZBc.TMN3KG9gyDwUiO7kLL8t.LAcmHYzoz1ecuBgXZ2DBRD82', 'admin')
ON CONFLICT DO NOTHING;
