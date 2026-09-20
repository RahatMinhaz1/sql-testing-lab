-- =====================================================================
-- SQL Testing Lab Database - Test Queries (linked schema)
-- Run after 03_insert_test_data.sql
-- =====================================================================

USE sql_testing_lab;

-- =====================================================================
-- SECTION A: Structure validation
-- =====================================================================
DESCRIBE student_information;
DESCRIBE student_parents_information;
DESCRIBE persons;
DESCRIBE orders;
DESCRIBE department;
DESCRIBE employee;
DESCRIBE employee_contact;

SHOW TABLES;


-- =====================================================================
-- SECTION B: student_information + student_parents_information
-- =====================================================================

-- B1. Row counts (expected: 4 and 4)
SELECT COUNT(*) AS total_students FROM student_information;
SELECT COUNT(*) AS total_parent_records FROM student_parents_information;

-- B2. Primary key uniqueness (expected: 0 rows)
SELECT student_id, COUNT(*)
FROM student_information
GROUP BY student_id
HAVING COUNT(*) > 1;

-- B3. Negative test: duplicate primary key (expected: rejected)
INSERT INTO student_information (student_id, first_name, last_name, address)
VALUES (1, 'Duplicate', 'Test', 'Dhaka');
-- Expected: ERROR 1062 (23000): Duplicate entry '1' for key 'student_information.PRIMARY'

-- B4. JOIN: student with their parent/guardian info
SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    p.student_fathers_name,
    p.student_mothers_name,
    p.student_guardian_address
FROM student_information s
JOIN student_parents_information p ON s.student_id = p.student_id
ORDER BY s.student_id;
-- Expected: every student shows their linked parent/guardian record

-- B5. Orphan check: students with no parent record on file (expected: 0 rows)
SELECT s.student_id, s.first_name, s.last_name
FROM student_information s
LEFT JOIN student_parents_information p ON s.student_id = p.student_id
WHERE p.parent_id IS NULL;

-- B6. Foreign key negative test: parent record for a non-existent student
INSERT INTO student_parents_information (student_id, student_fathers_name)
VALUES (999, 'Ghost Parent');
-- Expected: ERROR 1452 (23000): Cannot add or update a child row: a foreign
-- key constraint fails (`sql_testing_lab`.`student_parents_information`,
-- CONSTRAINT `fk_parents_student` FOREIGN KEY (`student_id`)
-- REFERENCES `student_information` (`student_id`))

-- B7. Cascade delete check: deleting a student removes their parent record
START TRANSACTION;
SELECT * FROM student_parents_information WHERE student_id = 4;
DELETE FROM student_information WHERE student_id = 4;
SELECT * FROM student_parents_information WHERE student_id = 4; -- expected: 0 rows
ROLLBACK;  -- undo so student 4 is still available for later tests


-- =====================================================================
-- SECTION C: persons + orders
-- =====================================================================

-- C1. Primary key uniqueness on persons (expected: 0 rows)
SELECT ID, COUNT(*)
FROM persons
GROUP BY ID
HAVING COUNT(*) > 1;

-- C2. NOT NULL constraint test on persons.LastName (expected: rejected)
INSERT INTO persons (ID, FirstName, Age)
VALUES (4, 'NoLastName', 40);
-- Expected: ERROR 1364 (HY000): Field 'LastName' doesn't have a default value

-- C3. Foreign key negative test: invalid PersonID in orders
INSERT INTO orders (OrderID, OrderNumber, PersonID)
VALUES (99, 55555, 999);
-- Expected: ERROR 1452 (23000): a foreign key constraint fails on orders_ibfk_1

-- C4. JOIN test: every order with the person who placed it
SELECT
    o.OrderID,
    o.OrderNumber,
    CONCAT(p.FirstName, ' ', p.LastName) AS customer_name
FROM orders o
JOIN persons p ON o.PersonID = p.ID
ORDER BY o.OrderID;

-- C5. Aggregate: number of orders per person
SELECT
    CONCAT(p.FirstName, ' ', p.LastName) AS customer_name,
    COUNT(o.OrderID) AS total_orders
FROM persons p
LEFT JOIN orders o ON p.ID = o.PersonID
GROUP BY p.ID, customer_name
ORDER BY total_orders DESC;


-- =====================================================================
-- SECTION D: department + employee + employee_contact
-- =====================================================================

-- D1. Row counts
SELECT COUNT(*) AS total_departments FROM department;
SELECT COUNT(*) AS total_employees FROM employee;
SELECT COUNT(*) AS total_employee_contacts FROM employee_contact;

-- D2. Primary key uniqueness on employee (expected: 0 rows -- now enforced by the PK itself)
SELECT EmpCode, COUNT(*)
FROM employee
GROUP BY EmpCode
HAVING COUNT(*) > 1;

-- D3. Negative test: duplicate EmpCode is now rejected (previously it was not)
INSERT INTO employee (EmpCode, EmpFName, EmpLName)
VALUES (9369, 'Duplicate', 'Employee');
-- Expected: ERROR 1062 (23000): Duplicate entry '9369' for key 'employee.PRIMARY'

-- D4. Foreign key negative test: invalid DEPTCODE
INSERT INTO employee (EmpCode, EmpFName, EmpLName, DEPTCODE)
VALUES (9999, 'Bad', 'Dept', 999);
-- Expected: ERROR 1452 (23000): a foreign key constraint fails on fk_employee_department

-- D5. NULL DEPTCODE check (still allowed -- DEPTCODE is optional, e.g. new hires)
SELECT EmpCode, EmpFName, EmpLName, DEPTCODE
FROM employee
WHERE DEPTCODE IS NULL;
-- Currently returns MADII HIMBURY (EmpCode 9777)

-- D6. JOIN: employee with department name and location
SELECT
    e.EmpCode,
    e.EmpFName,
    e.EmpLName,
    e.Job,
    d.DeptName,
    d.Location
FROM employee e
LEFT JOIN department d ON e.DEPTCODE = d.DeptCode
ORDER BY e.EmpCode;

-- D7. JOIN: employee with contact info
SELECT
    e.EmpCode,
    e.EmpFName,
    e.EmpLName,
    c.Address,
    c.Number
FROM employee e
JOIN employee_contact c ON e.EmpCode = c.EmpCode
ORDER BY e.EmpCode;

-- D8. Orphan check: department rows with no employees (expected: 0 rows, or a
-- legitimately empty department -- confirm against the business)
SELECT d.DeptCode, d.DeptName
FROM department d
LEFT JOIN employee e ON d.DeptCode = e.DEPTCODE
WHERE e.EmpCode IS NULL;

-- D9. Aggregate: average salary and headcount per department
SELECT
    d.DeptName,
    COUNT(e.EmpCode) AS employee_count,
    ROUND(AVG(e.Salary), 2) AS avg_salary
FROM department d
LEFT JOIN employee e ON d.DeptCode = e.DEPTCODE
GROUP BY d.DeptCode, d.DeptName
ORDER BY avg_salary DESC;

-- D10. Filter testing: employees earning more than 3000
SELECT EmpFName, EmpLName, Job, Salary
FROM employee
WHERE Salary > 3000
ORDER BY Salary DESC;

-- D11. Sorting testing: highest paid employees first
SELECT EmpFName, EmpLName, Salary
FROM employee
ORDER BY Salary DESC;

-- D12. Data type negative test: invalid HireDate
INSERT INTO employee (EmpCode, EmpFName, EmpLName, HireDate)
VALUES (9998, 'BadDate', 'Test', 'not-a-date');
-- Expected: ERROR 1292 (22007): Incorrect date value: 'not-a-date' for column 'HireDate'

-- D13. Transaction / rollback test
START TRANSACTION;

UPDATE employee SET Salary = 0 WHERE EmpCode = 9369;
SELECT EmpCode, Salary FROM employee WHERE EmpCode = 9369;

ROLLBACK;

SELECT EmpCode, Salary FROM employee WHERE EmpCode = 9369;
-- Expected: after ROLLBACK, Salary should be back to 2800

-- D14. Cascade delete check: deleting an employee also removes their contact row
START TRANSACTION;
SELECT * FROM employee_contact WHERE EmpCode = 9861;
DELETE FROM employee WHERE EmpCode = 9861;
SELECT * FROM employee_contact WHERE EmpCode = 9861; -- expected: 0 rows
ROLLBACK;  -- undo so employee 9861 is still available afterwards


-- =====================================================================
-- SECTION E: Final regression check
-- =====================================================================
SHOW TABLES;
SELECT COUNT(*) FROM student_information;
SELECT COUNT(*) FROM student_parents_information;
SELECT COUNT(*) FROM persons;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM department;
SELECT COUNT(*) FROM employee;
SELECT COUNT(*) FROM employee_contact;
