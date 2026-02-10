# Library Management System - SQL Analysis

## Project Overview

A comprehensive SQL analysis project that explores library operations through data-driven insights. This project demonstrates proficiency in database design, complex SQL queries, and business intelligence through real-world library management scenarios.

The analysis covers member activity tracking, book circulation patterns, revenue calculations, and operational metrics using advanced SQL techniques including JOINs, window functions, subqueries, and aggregate functions.

---

## Database Schema

The database consists of three main tables with the following relationships:

### Tables:

**Books Table:**
- Stores book inventory information
- Tracks title, author, genre, ISBN, publication year, and copy count

**Members Table:**
- Contains member registration details
- Tracks membership status (Active, Inactive, Suspended)
- Stores contact information

**Checkouts Table:**
- Records all borrowing transactions
- Links books to members through foreign keys
- Tracks checkout dates, due dates, return dates, and status

---

## Technologies Used

- **Database:** SQLite
- **SQL Techniques:** 
  - Complex JOINs (INNER, LEFT, OUTER)
  - Aggregate Functions (COUNT, AVG, SUM, ROUND)
  - Window Functions (RANK, DENSE_RANK, SUM OVER)
  - Subqueries and CTEs
  - CASE statements
  - Date/Time functions (julianday)
  - GROUP BY and HAVING clauses

- **Tools:** 
  - SQLiteOnline for query execution
  - dbdiagram.io for ER diagram creation

---

## Key Analytical Questions Answered

### 1. **Collection Performance**
   - Which books are most popular among members?
   - Which genres drive the highest circulation?
   - Which books exceed average borrowing rates?

### 2. **Member Engagement**
   - Who are the most active borrowers?
   - Which active members have never borrowed books?
   - How do members rank by borrowing activity?

### 3. **Operational Metrics**
   - What is the average borrowing duration?
   - What is the current borrowed vs. returned ratio?
   - What are the monthly borrowing trends?

### 4. **Revenue & Compliance**
   - Who has overdue books with contact information?
   - What is the total late fee revenue ($0.50/day)?
   - Which authors have the highest return rates?

---

## Sample Queries & Insights

### Query 1: Top 5 Most Borrowed Books
**Business Question:** Which books are the most popular among library members?
```sql
SELECT b.title, b.author,
       COUNT(c.checkout_ID) as times_borrowed
FROM books b
LEFT JOIN checkouts c ON c.book_id = b.book_id
GROUP BY b.book_id, b.title, b.author
ORDER BY times_borrowed DESC
LIMIT 5;
```

**Insight:** Identifies high-demand titles that may require additional copies for the collection.

---

### Query 7: Average Borrowing Duration
**Business Question:** What is the average number of days members keep books before returning them?
```sql
SELECT AVG(julianday(return_date) - julianday(checkout_date)) AS avg_days_kept
FROM checkouts
WHERE return_date IS NOT NULL;
```

**Technical Note:** Initially, direct date subtraction returned incorrect results (0.1) because dates were stored as TEXT. Used `julianday()` function to properly calculate the difference in days.

---

### Query 9: Total Late Fee Revenue
**Business Question:** What is the total amount of late fees owed or collected (at $0.50 per day)?
```sql
SELECT '$' || ROUND(
    SUM(CASE 
        WHEN c.status = 'Returned' THEN 
            0.5 * (julianday(return_date) - julianday(due_date))
        WHEN c.status = 'Overdue' THEN 
            0.5 * (julianday('now') - julianday(due_date))
        ELSE 0 
    END), 2) AS total_late_fees
FROM checkouts;
```

**Insight:** Quantifies potential revenue from late returns and tracks financial impact of overdue items.

---

### Query 11: Member Rankings by Activity
**Business Question:** How do members rank based on total books borrowed?
```sql
SELECT 
    m.first_name, m.last_name, 
    COUNT(c.checkout_id) as total_books, 
    DENSE_RANK() OVER (ORDER BY COUNT(c.checkout_id) DESC) as member_rank
FROM checkouts c
JOIN members m ON m.member_id = c.member_id
GROUP BY m.member_id, m.first_name, m.last_name;
```

**Technical Note:** Switched from `RANK()` to `DENSE_RANK()` to ensure consecutive ranking without gaps after ties, providing more intuitive results.

---

### Query 12: Running Total of Checkouts
**Business Question:** What is the cumulative checkout count across all books?
```sql
SELECT b.book_id, b.title, 
       COUNT(c.checkout_id) AS times_borrowed,
       SUM(COUNT(c.checkout_id)) OVER (ORDER BY b.book_id) AS running_total
FROM books b
JOIN checkouts c ON b.book_id = c.book_id
GROUP BY b.book_id, b.title;
```

**Insight:** Demonstrates circulation trends using window functions to show cumulative totals across the collection.

---

## 🎯 Key Findings

1. **High Engagement Rate:** Only 1 active member has never borrowed a book, indicating strong library utilization
2. **Popular Genres:** Fantasy and Dystopian genres dominate borrowing activity
3. **Return Behavior:** Average borrowing duration provides insights for optimizing loan periods
4. **Revenue Opportunity:** Late fees tracking enables better financial management and member follow-up
5. **Author Performance:** Return rate analysis identifies authors whose books circulate most efficiently

---

## Project Files

- **`schema.sql`** - Complete database structure with CREATE TABLE statements
- **`queries.sql`** - All 13 analytical queries with business questions and comments
- **`SQL_Analysis.pdf`** - Full documentation with query outputs and results
- **`ER_Diagram.png`** - Entity-Relationship diagram
- **`books.png`, `members.png`, `checkouts.png`** - Sample data screenshots

---

## How to Use

1. **Setup Database:**
```bash
   sqlite3 library.db < schema.sql
```

2. **Run Queries:**
   - Open `queries.sql` and execute queries individually
   - Or use SQLiteOnline and import the database

3. **Explore Results:**
   - Review `SQL_Analysis.pdf` for complete query outputs
   - Modify queries to explore different analytical questions

---

## Skills Demonstrated

- Database design and normalization
- Complex SQL query writing
- Data analysis and business intelligence
- Window functions and advanced SQL techniques
- Problem-solving (e.g., date function debugging)
- Technical documentation

---

## Contact

Feel free to reach out for questions or collaboration opportunities!

---

## License

This project is open source and available for educational purposes.
