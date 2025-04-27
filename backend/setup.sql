CREATE DATABASE canteen_db;

\c canteen_db

-- Users table
CREATE TABLE users (
                       id SERIAL PRIMARY KEY,
                       name VARCHAR(255),
                       email VARCHAR(255) UNIQUE NOT NULL,
                       password_hash VARCHAR(255) NOT NULL,
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
                        id SERIAL PRIMARY KEY,
                        student_id INTEGER REFERENCES users(id),
                        items JSONB,
                        status VARCHAR(20),
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transactions table
CREATE TABLE transactions (
                              student_id INTEGER REFERENCES users(id),
                              order_id INTEGER REFERENCES orders(id),
                              amount DECIMAL(10, 2),
                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                              PRIMARY KEY (student_id, order_id)
);

-- RFID mappings table
CREATE TABLE rfid_mappings (
                               rfid_uid VARCHAR(50) PRIMARY KEY,
                               student_id INTEGER UNIQUE REFERENCES users(id),
                               created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Menu table
CREATE TABLE menu (
                      id SERIAL PRIMARY KEY,
                      name VARCHAR(255) NOT NULL,
                      price DECIMAL(10, 2),
                      stock INTEGER,
                      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tags (
                      id SERIAL PRIMARY KEY,
                      name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE menu_tags (
                           menu_id INTEGER REFERENCES menu(id),
                           tag_id INTEGER REFERENCES tags(id),
                           PRIMARY KEY (menu_id, tag_id)
);

