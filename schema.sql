-- Library Management System Database Schema

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    genre TEXT,
    isbn TEXT UNIQUE,
    publication_year INTEGER,
    total_copies INTEGER DEFAULT 1
);

CREATE TABLE members (
    member_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    join_date DATE DEFAULT CURRENT_DATE,
    membership_status TEXT CHECK(membership_status IN ('Active', 'Inactive', 'Suspended'))
);

CREATE TABLE checkouts (
    checkout_id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id INTEGER,
    member_id INTEGER,
    checkout_date DATE DEFAULT CURRENT_DATE,
    due_date DATE,
    return_date DATE,
    status TEXT CHECK(status IN ('Borrowed', 'Returned', 'Overdue')),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);