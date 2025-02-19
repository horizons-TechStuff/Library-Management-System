-- 

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

--Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books
-- (assume a 30-day return period). Display the member's_id, member's name, book title,
-- issue date, and days overdue.


--issued_status == members == books == return_status
-- filter books which is returned 
--overdue > 30


SELECT ist.issued_member_id , m.member_name , 
		bk.book_title ,
		ist.issued_date,
		-- rs.return_date,
		CURRENT_DATE - ist.issued_date AS over_dues_days
FROM issued_status AS ist 
JOIN 
members AS m 
 	ON m.member_id = ist.issued_member_id
JOIN 
books AS bk 
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN
return_status AS rs 
ON rs.issued_id = ist.issued_id
WHERE rs.return_date is NULL 
AND CURRENT_DATE - ist.issued_date > 30
ORDER BY 1;


-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

CREATE OR REPLACE PROCEDURE add_return_record(p_return_id VARCHAR(10),p_issued_id VARCHAR(10),p_book_quality VARCHAR(15) )
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(50);
	v_book_name VARCHAR(80);

BEGIN 
		--THE LOGIC AND CODE

		--Inserting into return status based on users input
		INSERT INTO return_status(return_id , issued_id ,return_date,book_quality)
		VALUES
		(p_return_id,p_issued_id,CURRENT_DATE,p_book_quality);

		SELECT 
		issued_book_isbn,
		issued_book_name
		INTO 
		v_isbn,
	    v_book_name
		FROM issued_status 
		WHERE issued_id = p_issued_id;
		
		UPDATE books
		SET status = 'yes'
		WHERE isbn =v_isbn;

		RAISE NOTICE 'Thank you for returning the book:  %', v_book_name ;
		


END;
$$

--calling the function 
--Function is tested with varios tuples 
CALL add_return_record('RS138','IS135','Good');


-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

CREATE TABLE branch_report
AS 
SELECT b.branch_id ,
	   b.manager_id,
	   COUNT(ist.issued_id) AS number_book_issued,
	   COUNT(rs.return_id) AS number_book_return,
	   SUM(bk.rental_price) AS total_revenue
	   
	   
FROM issued_status AS ist
JOIN employees AS e
ON e.emp_id = ist.issued_emp_id
JOIN 
branch AS b
ON e.branch_id = b.branch_id
LEFT JOIN 
return_status AS rs
ON rs.issued_id = ist.issued_id
JOIN 
books AS bk
ON ist.issued_book_isbn = bk.isbn

GROUP BY 1 , 2;

-- SELECT * FROM branch_report;
-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT DISTINCT
	issued_member_id 
FROM issued_status
WHERE 
	issued_date >= CURRENT_DATE - INTERVAL '6 MONTH');

SELECT * FROM active_members;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues.
-- Display the employee name, number of books processed, and their branch.

SELECT e.emp_name , 
	   b.* ,
	   COUNT(ist.issued_id) AS no_book_issued 
	   
FROM issued_status AS ist 
JOIN 
employees AS e
ON e.emp_id = ist.issued_emp_id
JOIN branch AS b 
ON e.branch_id = b.branch_id
GROUP BY 1, 2;


-- Task 18: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status 
-- "damaged" in the books table. Display the member name, book title, 
-- and the number of times they've issued damaged books.

SELECT 
    m.member_name, 
    bk.book_title, 
    COUNT(ist.issued_id) AS times_issued_damaged
FROM 
    issued_status AS ist
JOIN 
    members AS m 
    ON m.member_id = ist.issued_member_id
JOIN 
    books AS bk 
    ON bk.isbn = ist.issued_book_isbn
WHERE 
    bk.status = 'damaged'
GROUP BY 
    m.member_name, bk.book_title
HAVING 
    COUNT(ist.issued_id) > 2;



/* Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), 
the procedure should return an error message indicating that the book is currently not available.*/

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10) , p_issued_member_id VARCHAR(30),p_issued_book_isbn VARCHAR(50),p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
	--variable declarations 
	v_status VARCHAR(10);
	

BEGIN
	--logic 
		--checking if book is available 'yes'
		SELECT status 
		INTO v_status
		FROM books 
		WHERE isbn = p_issued_book_isbn;

		IF  v_status = 'yes' THEN 
			INSERT INTO issued_status(issued_id,issued_member_id,issued_date , issued_book_isbn , issued_emp_id )
			VALUES
			(p_issued_id,p_issued_member_id, CURRENT_DATE ,p_issued_book_isbn , p_issued_emp_id);

			UPDATE books 
				SET status ='no'
			WHERE isbn = p_issued_book_isbn;
			
			RAISE NOTICE 'Book record added successfully for book isbn : %', p_issued_book_isbn;


		ELSE 

		RAISE NOTICE 'Sorry to inform you , the book you have requested is unavailable  book_isbn : %', p_issued_book_isbn;

		END IF;


END;
$$


CALL issue_book('IS155','C108','978-0-553-29698-2','E104');

CALL issue_book('IS155','C108','978-0-553-29698-2','E104');


-- Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

-- Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days.
-- The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each member.
-- The resulting table should show: Member ID Number of overdue books Total fines

CREATE TABLE overdue_books_fines AS
SELECT 
    ist.issued_member_id AS member_id,
    COUNT(ist.issued_id) AS num_overdue_books,
    SUM((CURRENT_DATE - ist.issued_date) * 0.50) AS total_fines
FROM 
    issued_status AS ist
LEFT JOIN 
    return_status AS rs 
    ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL 
    AND (CURRENT_DATE - ist.issued_date) > 30
GROUP BY 
    ist.issued_member_id;
