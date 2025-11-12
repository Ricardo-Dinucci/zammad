-- SQL to make prefeitura@cestaas.com an admin
-- First, find the user ID
SELECT id, email, firstname, lastname FROM users WHERE email = 'prefeitura@cestaas.com';

-- Then, get role IDs
SELECT id, name FROM roles WHERE name IN ('Admin', 'Agent');

-- Make user admin (replace USER_ID with the actual ID from first query)
-- Admin role is usually ID 1, Agent is usually ID 2
DELETE FROM roles_users WHERE user_id = (SELECT id FROM users WHERE email = 'prefeitura@cestaas.com');
INSERT INTO roles_users (user_id, role_id)
  SELECT u.id, r.id
  FROM users u, roles r
  WHERE u.email = 'prefeitura@cestaas.com'
    AND r.name IN ('Admin', 'Agent');

-- Verify
SELECT u.email, r.name as role
FROM users u
JOIN roles_users ru ON u.id = ru.user_id
JOIN roles r ON ru.role_id = r.id
WHERE u.email = 'prefeitura@cestaas.com';
