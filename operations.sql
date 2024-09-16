
-- Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

-- Update an Existing Member's Address 

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

-- Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE   issued_id =   'IS121';

--  Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

-- List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
;
SELECT
    issued_member_id,
    COUNT(issued_member_id)
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(*) > 1

-- Retrieve All Books in a Specific Category:
;
SELECT * FROM books
WHERE category = 'Classic';

--  Find Total Rental Income by Category;

SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY b.category;


-- List Members Who Registered in the Last 180 Days:

SELECT * 
FROM members
WHERE DATEDIFF(CURRENT_DATE, reg_date) <= 180;

-- List Employees with Their Branch Manager's Name and their branch details:

SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
inner JOIN 
branch as b
ON e1.branch_id = b.branch_id    
left JOIN
employees as e2
ON e2.emp_id = b.manager_id

-- Create a Table of Books with Rental Price Above a Certain Threshold

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 9.00;

-- Retrieve the List of Books Not Yet Returned

SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.


SELECT 
    ist.issued_member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
inner JOIN 
members as m
    ON m.member_id = ist.issued_member_id
inner join books b
on ist.issued_book_isbn = b.isbn
inner join return_status rs
on rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) = 30
ORDER BY ASC

Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when 
-- they are returned (based on entries in the return_status table).

DROP PROCEDURE IF EXISTS add_return_records;

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
	DECLARE v_isbn VARCHAR(20);
    DECLARE v_book_name VARCHAR(100);
    
    INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET books.status = 'yes'
    WHERE isbn = v_isbn;

END &&
DELIMITER ;

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

CALL add_return_records('RS138', 'IS135', 'Good');

-- Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table 
-- active_members containing members who have issued at least one book in the last 2 months.



drop table if exists active_members;

CREATE TABLE active_members AS
SELECT * 
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE DATEDIFF(CURRENT_DATE, issued_date) < 123456 
);

select * from active_members;
