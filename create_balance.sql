-- Check if the user exists
SELECT id FROM users WHERE id = 1;

-- Check if balance already exists
SELECT * FROM balances WHERE student_id = 1;

-- Create balance if it doesn't exist
INSERT INTO balances (student_id, amount) 
VALUES (1, 100.00)
ON CONFLICT (student_id) DO UPDATE SET amount = 100.00;

-- Verify the balance was created
SELECT * FROM balances WHERE student_id = 1; 