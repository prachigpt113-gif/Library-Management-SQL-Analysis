-- =====================================================
-- Library Management System - SQL Analysis Queries
-- =====================================================

-- Query 1: Top 5 Most Borrowed Books
-- Business Question: Which books are the most popular among library members?
SELECT b.title, b.author,
       COUNT(c.checkout_ID) as times_borrowed
FROM books b
LEFT JOIN checkouts c ON c.book_id = b.book_id
GROUP BY b.book_id, b.title, b.author
ORDER BY times_borrowed DESC
LIMIT 5;

-- Query 2: Members with Overdue Books
-- Business Question: Which members currently have overdue books?
SELECT m.member_id, m.first_name, m.last_name, c.status
FROM members m
LEFT JOIN checkouts c ON m.member_id = c.member_id
WHERE c.status = 'Overdue';

-- Query 3: Count of Borrowed vs. Returned Books
-- Business Question: What is the current status of all checkouts?
SELECT COUNT(b.book_id), c.status
FROM books b
JOIN checkouts c ON b.book_id = c.book_id
WHERE c.status = 'Borrowed' OR c.status = 'Returned'
GROUP BY c.status;

-- Query 4: Top 5 Most Popular Genres
-- Business Question: Which genres are most frequently borrowed?
SELECT b.genre, COUNT(c.checkout_ID) as times_borrowed
FROM books b
JOIN checkouts c ON b.book_id = c.book_id
GROUP BY b.genre
ORDER BY times_borrowed DESC
LIMIT 5;

-- Query 5: Active Members with No Borrowing Activity
-- Business Question: Which active members have never borrowed a book?
SELECT m.member_id, m.first_name, m.last_name, m.membership_status
FROM members m
LEFT JOIN checkouts c ON m.member_id = c.member_id
WHERE m.membership_status = 'Active' AND c.checkout_id IS NULL;

-- Query 6: Members Who Borrowed More Than 1 Book
-- Business Question: Which members are frequent borrowers?
SELECT COUNT(c.checkout_id) as books_borrowed, m.first_name, m.last_name
FROM checkouts c
LEFT JOIN members m ON c.member_id = m.member_id
GROUP BY c.member_id
HAVING books_borrowed > 1;

-- Query 7: Average Borrowing Duration
-- Business Question: What is the average number of days members keep books?
-- Note: Uses julianday() because dates are stored as TEXT
SELECT AVG(julianday(return_date) - julianday(checkout_date)) AS avg_days_kept
FROM checkouts
WHERE return_date IS NOT NULL;

-- Query 8: Overdue Books with Member Contact Information
-- Business Question: Which books are overdue and how to contact members?
SELECT m.member_id, m.first_name, m.last_name, m.phone, m.email, c.status, b.title
FROM members m
LEFT JOIN checkouts c ON m.member_id = c.member_id
LEFT JOIN books b ON c.book_id = b.book_id
WHERE c.status = 'Overdue'
ORDER BY m.member_id;

-- Query 9: Total Late Fee Revenue
-- Business Question: What is the total late fee amount ($0.50/day)?
SELECT '$' || ROUND(
    SUM(CASE 
        WHEN c.status = 'Returned' THEN 0.5 * (julianday(return_date) - julianday(due_date))
        WHEN c.status = 'Overdue' THEN 0.5 * (julianday('now') - julianday(due_date))
        ELSE 0 
    END), 2) AS total_late_fees
FROM checkouts;

-- Query 10: Authors with Highest Return Rate
-- Business Question: Which authors have the best return rates?
SELECT 
    b.author,
    COUNT(c.checkout_id) AS total_checkouts,
    COUNT(CASE WHEN c.status = 'Returned' THEN 1 END) AS returned_count, 
    ROUND((COUNT(CASE WHEN c.status = 'Returned' THEN 1 END) * 100.0 / COUNT(c.checkout_id)), 2) AS return_rate
FROM books b
JOIN checkouts c ON b.book_id = c.book_id
GROUP BY b.author
HAVING returned_count > 0
ORDER BY return_rate DESC
LIMIT 10;

-- Query 11: Member Rankings by Borrowing Activity
-- Business Question: How do members rank by total books borrowed?
-- Note: Uses DENSE_RANK() to avoid gaps in ranking
SELECT 
    m.first_name, m.last_name, 
    COUNT(c.checkout_id) as total_books, 
    DENSE_RANK() OVER (ORDER BY COUNT(c.checkout_id) DESC) as member_rank
FROM checkouts c
JOIN members m ON m.member_id = c.member_id
GROUP BY m.member_id, m.first_name, m.last_name;

-- Query 12: Running Total of Checkouts by Book
-- Business Question: What is the cumulative checkout count?
SELECT b.book_id, b.title, 
       COUNT(c.checkout_id) AS times_borrowed,
       SUM(COUNT(c.checkout_id)) OVER (ORDER BY b.book_id) AS running_total
FROM books b
JOIN checkouts c ON b.book_id = c.book_id
GROUP BY b.book_id, b.title;

-- Query 13: Books Borrowed Above Average
-- Business Question: Which books exceed average borrowing rates?
SELECT 
    b.book_id,
    b.title,
    COUNT(c.checkout_id) AS times_borrowed
FROM books b
JOIN checkouts c ON b.book_id = c.book_id
GROUP BY b.book_id, b.title
HAVING COUNT(c.checkout_id) > (
    SELECT AVG(checkout_count)
    FROM (
        SELECT COUNT(checkout_id) AS checkout_count
        FROM checkouts
        GROUP BY book_id
    )
);
```
