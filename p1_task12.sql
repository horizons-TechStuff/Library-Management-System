SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;


--project tasks 

--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn , book_title, category , rental_price, status,author,publisher)
VALUES(
'978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

--Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '123 Main St'
WHERE member_id = 'C101';

--Task 3: Delete a Record from the Issued Status Table
DELETE FROM issued_status 
WHERE issued_id = 'IS121';

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

--Task 5: List Members Who Have Issued More Than One Book
SELECT issued_member_id, COUNT(*) AS book_count
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(*) > 1;

--Task 6: Create Summary Tables:Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_cnts
AS 
SELECT b.isbn , 
b.book_title,
COUNT(ist.issued_id) as no_issued
FROM books AS b JOIN 
issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1 , 2;

SELECT * FROM book_cnts;


--Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic';

--Task 8: Find Total Rental Income by Category:
SELECT b.category ,
	SUM(b.rental_price ) , 
	COUNT(*)
FROM books AS b
JOIN 
issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

--List Members Who Registered in the Last 180 Days:
SELECT * FROM members 
WHERE reg_date  >= CURRENT_DATE - INTERVAL '180 days';


INSERT INTO members(member_id , member_name , member_address , reg_date)
VALUES 
('C31' , 'Sam' , '145 Main st' , '2024-12-01'

),
(
'C132' , 'Sammy' , '155 Main st' , '2025-1-01'

)

--List Employees with Their Branch Manager's Name and their branch details:
SELECT 
e1.* , 
b.manager_id,
e2.emp_name as manager , 
b.branch_id 
FROM employees as e1 
JOIN 
branch AS b 
ON b.branch_id = e1.branch_id
JOIN employees AS e2 
ON b.manager_id = e2.emp_id;

--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE books_price_greater_than_7
AS
SELECT * FROM books
WHERE rental_price > 7;

SELECT * FROM books_price_greater_than_7;

--Task 12: Retrieve the List of Books Not Yet Returned
SELECT 
DISTINCT ist.issued_book_name
FROM issued_status AS ist LEFT JOIN return_status AS rst
ON ist.issued_id = rst.issued_id
WHERE rst.return_id is NULL;



