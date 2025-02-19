                        


# Library Management System

This project is a **Library Management System** built using SQL. It includes various tasks to manage books, members, employees, and transactions like issuing and returning books. Below is a detailed explanation of each task and its corresponding SQL query.

---

## **Tasks and Queries**

### **Task 1: Create a New Book Record**
**Objective**: Insert a new book into the `books` table.

**Query**:
```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

**Explanation**: This query adds a new book titled "To Kill a Mockingbird" to the `books` table.

---

### **Task 2: Update an Existing Member's Address**
**Objective**: Update the address of a member with `member_id = 'C101'`.

**Query**:
```sql
UPDATE members
SET member_address = '123 Main St'
WHERE member_id = 'C101';
```

**Explanation**: This query updates the address of the member with ID `C101` to `123 Main St`.

---

### **Task 3: Delete a Record from the Issued Status Table**
**Objective**: Delete a record from the `issued_status` table where `issued_id = 'IS121'`.

**Query**:
```sql
DELETE FROM issued_status 
WHERE issued_id = 'IS121';
```

**Explanation**: This query removes the record with `issued_id = 'IS121'` from the `issued_status` table.

---

### **Task 4: Retrieve All Books Issued by a Specific Employee**
**Objective**: Select all books issued by the employee with `emp_id = 'E101'`.

**Query**:
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';
```

**Explanation**: This query retrieves all books issued by the employee with ID `E101`.

---

### **Task 5: List Members Who Have Issued More Than One Book**
**Objective**: Find members who have issued more than one book.

**Query**:
```sql
SELECT issued_member_id, COUNT(*) AS book_count
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(*) > 1;
```

**Explanation**: This query lists members who have issued more than one book, along with the count of books they've issued.

---

### **Task 6: Create Summary Tables**
**Objective**: Use CTAS to generate a new table `book_cnts` that shows each book and the total number of times it has been issued.

**Query**:
```sql
CREATE TABLE book_cnts AS 
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS no_issued
FROM books AS b 
JOIN issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;
```

**Explanation**: This query creates a new table `book_cnts` that contains the ISBN, title, and the number of times each book has been issued.

---

### **Task 7: Retrieve All Books in a Specific Category**
**Objective**: Retrieve all books in the "Classic" category.

**Query**:
```sql
SELECT * FROM books
WHERE category = 'Classic';
```

**Explanation**: This query retrieves all books that belong to the "Classic" category.

---

### **Task 8: Find Total Rental Income by Category**
**Objective**: Calculate the total rental income and count of books issued for each category.

**Query**:
```sql
SELECT b.category, SUM(b.rental_price), COUNT(*)
FROM books AS b
JOIN issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;
```

**Explanation**: This query calculates the total rental income and the number of books issued for each category.

---

### **Task 9: List Members Who Registered in the Last 180 Days**
**Objective**: Retrieve members who registered in the last 180 days.

**Query**:
```sql
SELECT * FROM members 
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

**Explanation**: This query lists members who registered in the last 180 days.

---

### **Task 10: List Employees with Their Branch Manager's Name**
**Objective**: Retrieve employees along with their branch manager's name and branch details.

**Query**:
```sql
SELECT e1.*, b.manager_id, e2.emp_name AS manager, b.branch_id 
FROM employees AS e1 
JOIN branch AS b ON b.branch_id = e1.branch_id
JOIN employees AS e2 ON b.manager_id = e2.emp_id;
```

**Explanation**: This query retrieves employees along with their branch manager's name and branch details.

---

### **Task 11: Create a Table of Books with Rental Price Above a Certain Threshold**
**Objective**: Create a new table `books_price_greater_than_7` containing books with a rental price greater than 7.

**Query**:
```sql
CREATE TABLE books_price_greater_than_7 AS
SELECT * FROM books
WHERE rental_price > 7;
```

**Explanation**: This query creates a new table `books_price_greater_than_7` containing books with a rental price greater than 7.

---

### **Task 12: Retrieve the List of Books Not Yet Returned**
**Objective**: Retrieve the list of books that have not been returned.

**Query**:
```sql
SELECT DISTINCT ist.issued_book_name
FROM issued_status AS ist 
LEFT JOIN return_status AS rst
ON ist.issued_id = rst.issued_id
WHERE rst.return_id IS NULL;
```

**Explanation**: This query retrieves the list of books that have not been returned.

---

### **Task 13: Identify Members with Overdue Books**
**Objective**: Identify members who have overdue books (assuming a 30-day return period).

**Query**:
```sql
SELECT ist.issued_member_id, m.member_name, bk.book_title, ist.issued_date, CURRENT_DATE - ist.issued_date AS overdue_days
FROM issued_status AS ist 
JOIN members AS m ON m.member_id = ist.issued_member_id
JOIN books AS bk ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL 
AND CURRENT_DATE - ist.issued_date > 30
ORDER BY 1;
```

**Explanation**: This query identifies members with overdue books, displaying the member's ID, name, book title, issue date, and days overdue.

---

### **Task 14: Update Book Status on Return**
**Objective**: Create a stored procedure to update the status of books to "Yes" when they are returned.

**Query**:
```sql
CREATE OR REPLACE PROCEDURE add_return_record(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$
DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
BEGIN
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT issued_book_isbn, issued_book_name INTO v_isbn, v_book_name
    FROM issued_status WHERE issued_id = p_issued_id;

    UPDATE books SET status = 'yes' WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$;
```

**Explanation**: This stored procedure updates the status of a book to "Yes" when it is returned.

---

### **Task 15: Branch Performance Report**
**Objective**: Create a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated.

**Query**:
```sql
CREATE TABLE branch_report AS 
SELECT b.branch_id, b.manager_id, COUNT(ist.issued_id) AS number_book_issued, COUNT(rs.return_id) AS number_book_return, SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.branch_id = b.branch_id
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
JOIN books AS bk ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;
```

**Explanation**: This query creates a performance report for each branch.

---

### **Task 16: Create a Table of Active Members**
**Objective**: Create a new table `active_members` containing members who have issued at least one book in the last 6 months.

**Query**:
```sql
CREATE TABLE active_members AS
SELECT * FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id 
    FROM issued_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL '6 MONTH'
);
```

**Explanation**: This query creates a table `active_members` containing members who have issued at least one book in the last 6 months.

---

### **Task 17: Find Employees with the Most Book Issues Processed**
**Objective**: Find the top 3 employees who have processed the most book issues.

**Query**:
```sql
SELECT e.emp_name, b.*, COUNT(ist.issued_id) AS no_book_issued 
FROM issued_status AS ist 
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.branch_id = b.branch_id
GROUP BY 1, 2;
```

**Explanation**: This query retrieves the top 3 employees who have processed the most book issues.

---

### **Task 18: Identify Members Issuing High-Risk Books**
**Objective**: Identify members who have issued books more than twice with the status "damaged".

**Query**:
```sql
SELECT m.member_name, bk.book_title, COUNT(ist.issued_id) AS times_issued_damaged
FROM issued_status AS ist
JOIN members AS m ON m.member_id = ist.issued_member_id
JOIN books AS bk ON bk.isbn = ist.issued_book_isbn
WHERE bk.status = 'damaged'
GROUP BY m.member_name, bk.book_title
HAVING COUNT(ist.issued_id) > 2;
```

**Explanation**: This query identifies members who have issued damaged books more than twice.

---

### **Task 19: Stored Procedure to Issue a Book**
**Objective**: Create a stored procedure to issue a book and update its status.

**Query**:
```sql
CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(50), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(10);
BEGIN
    SELECT status INTO v_status
    FROM books WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books SET status = 'no' WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book record added successfully for book isbn: %', p_issued_book_isbn;
    ELSE
        RAISE NOTICE 'Sorry, the book you have requested is unavailable. Book ISBN: %', p_issued_book_isbn;
    END IF;
END;
$$;
```

**Explanation**: This stored procedure issues a book and updates its status to "no" if it is available.

---

### **Task 20: Create Table of Overdue Books and Fines**
**Objective**: Create a new table `overdue_books_fines` that lists members with overdue books and calculates fines.

**Query**:
```sql
CREATE TABLE overdue_books_fines AS
SELECT ist.issued_member_id AS member_id, COUNT(ist.issued_id) AS num_overdue_books, SUM((CURRENT_DATE - ist.issued_date) * 0.50) AS total_fines
FROM issued_status AS ist
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL AND (CURRENT_DATE - ist.issued_date) > 30
GROUP BY ist.issued_member_id;
```

**Explanation**: This query creates a table `overdue_books_fines` that lists members with overdue books and calculates fines at $0.50 per day.

---

## **How to Use**
1. Clone the repository.
2. Run the SQL scripts to set up the database and tables.
3. Execute the queries to perform the tasks.

---

## **Contributing**
Feel free to contribute to this project by submitting pull requests or opening issues.

---

## **License**
This project is licensed under the MIT License. 

---
