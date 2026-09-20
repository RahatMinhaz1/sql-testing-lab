# SQL Testing Lab – Database Testing Project

A hands-on **database testing project built on MySQL and MySQL Workbench**,
based on a set of tables originally exported while practicing SQL. The
project walks through reviewing an existing schema like a QA engineer
would, fixing the structural problems that turn up, and then testing the
corrected database from every angle — structure, constraints, CRUD
operations, relationships, and transactions.

---

## 📌 About This Project

The `sql_testing_lab` database was originally six independent `.sql` exports built
during SQL practice: a student records pair, a generic persons/orders
pair, and an employee/department pair. They were never designed as one
connected system, and a closer look at the export revealed real problems —
an `employee` table that allowed duplicate employee codes, a `department`
table that didn't actually contain department data, and a parent/guardian
table with no way to trace it back to a student.

This project treats that as the actual task: not just writing SELECT
statements against whatever schema happens to exist, but reviewing the
schema itself, fixing what's broken, and then proving — with real test
queries — that the fix works.

### Goals of the Project

- Recreate the `sql_testing_lab` schema from the original table exports
- Identify missing keys, broken relationships, and design issues
- Correct the schema so every relationship is enforced by the database
- Insert test data and verify it loaded correctly
- Test Primary Key and Foreign Key behavior with real negative tests
- Test NOT NULL and data type constraints
- Run full CRUD cycles against multiple tables
- Validate relationships using JOIN and anti-join queries
- Run aggregate, filter, sort, and transaction tests
- Record every expected result against the actual result

---

## 🛠️ Tools & Technologies

| Tool / Technology | Purpose |
|---|---|
| MySQL 8.0 | The database engine used for this project |
| MySQL Workbench | Writing and executing SQL, inspecting table structure |
| SQL | All schema definitions, data, and test queries |
| Git | Tracking changes to the project |
| GitHub | Hosting the project publicly |

---

## 🗄️ Database Overview

**Database name:**

```text
sql_testing_lab
```

The database is organized into three unrelated groups of tables. Each
group models a small, self-contained scenario, and each one is fully
linked internally with proper keys.

### Group 1 — Students

| Table | What it holds |
|---|---|
| `student_information` | One row per student: name and address |
| `student_parents_information` | One row per parent/guardian record, linked to a specific student |

### Group 2 — Persons & Orders

| Table | What it holds |
|---|---|
| `persons` | Basic person records: name and age |
| `orders` | Orders, each placed by exactly one person |

### Group 3 — Employees

| Table | What it holds |
|---|---|
| `department` | Department code, name, and location |
| `employee` | Employee details: job title, salary, hire date, and the department they belong to |
| `employee_contact` | Address and phone number for each employee |

---

## 🔗 How the Tables Connect

```text
student_information  1 ──< ∞  student_parents_information


persons               1 ──< ∞  orders


department            1 ──< ∞  employee            1 ── 1  employee_contact
```

**In plain terms:**

- A student can have one or more parent/guardian records on file.
- A person can place any number of orders.
- A department can have many employees.
- Every employee has exactly one contact record (address and phone).

The three groups don't reference each other at all — a `student_id` means
nothing in the `persons` table, and vice versa. That's intentional; they
were kept as separate practice scenarios rather than forced into one
artificial mega-schema.

---

## 📂 Project Structure

```text
sql-testing-lab/
│
├── README.md
│
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_insert_test_data.sql
│   └── 04_database_test_queries.sql
│
└── docs/
    └── test_cases.md
```

---

# 🚀 Setting Up the Project

Open MySQL Workbench and run the four scripts in `sql/` in order. Each one
builds on the last, so skipping ahead will cause foreign key errors.

## Step 1 — Create the Database

Run:

```text
sql/01_create_database.sql
```

```sql
CREATE DATABASE IF NOT EXISTS sql_testing_lab;
USE sql_testing_lab;
```

Confirm it worked:

```sql
SHOW DATABASES;
SELECT DATABASE();
```

You should see `sql_testing_lab` in the list, and `SELECT DATABASE()` should
return `sql_testing_lab` as the active schema.

## Step 2 — Build the Tables

Run:

```text
sql/02_create_tables.sql
```

This creates all seven tables with their keys and constraints already in
place — this is the corrected version of the schema, not the original
export. Confirm every table exists:

```sql
SHOW TABLES;
```

Expected output:

```text
department
employee
employee_contact
orders
persons
student_information
student_parents_information
```

## Step 3 — Load the Test Data

Run:

```text
sql/03_insert_test_data.sql
```

The insert order in this file matters, because of the foreign keys:
`department` has to exist before `employee` can reference it, `employee`
has to exist before `employee_contact` can reference it, and
`student_information` has to exist before `student_parents_information`
can reference it. The script is already ordered correctly — running it as
one batch should work without error.

Confirm the row counts:

```sql
SELECT COUNT(*) FROM student_information;
SELECT COUNT(*) FROM student_parents_information;
SELECT COUNT(*) FROM persons;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM department;
SELECT COUNT(*) FROM employee;
SELECT COUNT(*) FROM employee_contact;
```

| Table | Expected rows |
|---|---:|
| student_information | 4 |
| student_parents_information | 4 |
| persons | 3 |
| orders | 5 |
| department | 4 |
| employee | 17 |
| employee_contact | 17 |

## Step 4 — Run the Tests

Run:

```text
sql/04_database_test_queries.sql
```

This file mixes queries that are supposed to succeed with a number that
are **supposed to fail** — duplicate keys, invalid foreign key values, and
a bad date. Run it statement by statement in Workbench instead of as one
batch, so each error message is visible and can be recorded, rather than
having execution stop at the first failure.

---

# 🧪 Testing Approach

What follows is every category of test run against this database, with the
actual query used and what should happen when it runs.

## 1. Confirming the Environment

Before testing anything specific, the first check is just making sure
we're actually pointed at the right database with the right tables.

```sql
SELECT DATABASE();
SHOW TABLES;
```

**Expected:** `sql_testing_lab` is the active database, and all seven tables from
the project structure above are present.

## 2. Table Structure Review

Each table's structure is checked against the design using `DESCRIBE`,
confirming column names, data types, nullability, and keys.

```sql
DESCRIBE employee;
```

**Expected:** `EmpCode` shows `PRI` under the Key column (it's the primary
key), and `DEPTCODE` shows `MUL` (it's an indexed foreign key). This
specific check matters here because, in the original export, neither of
those was true — see the fix log for details.

## 3. Row Count Baseline

A simple sanity check that the amount of data loaded matches what was
inserted, run right after `03_insert_test_data.sql`. The counts are listed
in the setup section above. If any of them are off, either the insert
script didn't finish or a foreign key silently rejected a row that
should've succeeded.

## 4. Primary Key Enforcement

Every table with a primary key is checked two ways: first, that no
duplicates currently exist, and second, that the database actively
rejects an attempt to create one.

```sql
-- Should return 0 rows
SELECT EmpCode, COUNT(*)
FROM employee
GROUP BY EmpCode
HAVING COUNT(*) > 1;

-- Should be rejected
INSERT INTO employee (EmpCode, EmpFName, EmpLName)
VALUES (9369, 'Duplicate', 'Employee');
```

**Expected:** the GROUP BY query returns nothing, and the INSERT fails
with something like:

```text
ERROR 1062 (23000): Duplicate entry '9369' for key 'employee.PRIMARY'
```

This is worth calling out specifically for `employee`, because in the
original export this exact insert would have succeeded — there was no
primary key on `EmpCode` at all.

## 5. Foreign Key Enforcement

Each foreign key in the schema gets its own negative test: try to insert a
row pointing at something that doesn't exist, and confirm it gets
rejected.

```sql
-- employee.DEPTCODE -> department.DeptCode
INSERT INTO employee (EmpCode, EmpFName, EmpLName, DEPTCODE)
VALUES (9999, 'Bad', 'Dept', 999);

-- orders.PersonID -> persons.ID
INSERT INTO orders (OrderID, OrderNumber, PersonID)
VALUES (99, 55555, 999);

-- student_parents_information.student_id -> student_information.student_id
INSERT INTO student_parents_information (student_id, student_fathers_name)
VALUES (999, 'Ghost Parent');
```

**Expected:** all three fail with a foreign key constraint error (MySQL
error 1452). A rejected insert here counts as the test **passing** — the
whole point is that invalid data shouldn't be allowed in.

## 6. NOT NULL Enforcement

```sql
INSERT INTO persons (ID, FirstName, Age)
VALUES (4, 'NoLastName', 40);
```

**Expected:** rejected, because `LastName` is defined as `NOT NULL` and no
value was provided.

```text
ERROR 1364 (HY000): Field 'LastName' doesn't have a default value
```

## 7. Data Type Validation

```sql
INSERT INTO employee (EmpCode, EmpFName, EmpLName, HireDate)
VALUES (9998, 'BadDate', 'Test', 'not-a-date');
```

**Expected:** rejected, since `'not-a-date'` isn't a valid value for a
`DATE` column.

```text
ERROR 1292 (22007): Incorrect date value: 'not-a-date' for column 'HireDate'
```

As a positive counterpart, a real date is confirmed to store correctly:

```sql
SELECT EmpCode, EmpFName, HireDate
FROM employee
WHERE EmpCode = 9369;
```

## 8. Handling of Optional (Nullable) Fields

Not every `NULL` in this database is a problem — `DEPTCODE` on `employee`
is deliberately nullable, since a new hire might not be assigned to a
department yet.

```sql
SELECT EmpCode, EmpFName, EmpLName, DEPTCODE
FROM employee
WHERE DEPTCODE IS NULL;
```

**Expected today:** one row — `MADII HIMBURY` (EmpCode 9777). This is
called out specifically so it isn't mistaken for a bug during testing; the
column is nullable by design.

## 9. Full CRUD Cycle

Rather than testing Create, Read, Update, and Delete as isolated one-off
queries, this project runs them as a single connected sequence against one
record, to make sure each step actually reflects the previous one.

```sql
-- Create
INSERT INTO student_information (student_id, first_name, last_name, address)
VALUES (5, 'Nabila', 'Chowdhury', 'Sylhet');

-- Read
SELECT * FROM student_information WHERE student_id = 5;

-- Update
UPDATE student_information SET address = 'Chattogram' WHERE student_id = 5;
SELECT * FROM student_information WHERE student_id = 5;

-- Delete
DELETE FROM student_information WHERE student_id = 5;
SELECT * FROM student_information WHERE student_id = 5;
```

**Expected:** the record exists after insert, shows the updated address
after the UPDATE, and the final SELECT returns nothing at all — confirming
the delete actually took effect rather than just not throwing an error.

## 10. Relationship Testing via JOINs

Every relationship in the schema gets a JOIN query that proves the
connection actually returns meaningful, correctly-matched data.

**Student to parent/guardian:**

```sql
SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    p.student_fathers_name,
    p.student_mothers_name,
    p.student_guardian_address
FROM student_information s
JOIN student_parents_information p ON s.student_id = p.student_id;
```

**Person to their orders:**

```sql
SELECT
    o.OrderID,
    o.OrderNumber,
    CONCAT(p.FirstName, ' ', p.LastName) AS customer_name
FROM orders o
JOIN persons p ON o.PersonID = p.ID;
```

**Employee, their department, and their contact info, all at once:**

```sql
SELECT
    e.EmpCode,
    e.EmpFName,
    e.EmpLName,
    e.Job,
    d.DeptName,
    d.Location,
    c.Address,
    c.Number
FROM employee e
LEFT JOIN department d ON e.DEPTCODE = d.DeptCode
JOIN employee_contact c ON e.EmpCode = c.EmpCode;
```

**Expected:** each query returns one row per record on the "many" side,
with the correct related data attached — no mismatched names, no
duplicated rows, no unexpected gaps.

## 11. Finding Orphaned Records

A join proves a relationship works when data lines up. An anti-join (a
`LEFT JOIN` filtered to `WHERE ... IS NULL`) proves the opposite — it finds
rows on one side that have nothing matching them on the other, which is
exactly how the orphaned rows in the original `department` table were
originally discovered.

```sql
-- Departments with no employees
SELECT d.DeptCode, d.DeptName
FROM department d
LEFT JOIN employee e ON d.DeptCode = e.DEPTCODE
WHERE e.EmpCode IS NULL;

-- Employees with no contact record on file
SELECT e.EmpCode, e.EmpFName
FROM employee e
LEFT JOIN employee_contact c ON e.EmpCode = c.EmpCode
WHERE c.EmpCode IS NULL;
```

**Expected:** both return zero rows in the current dataset — every
department has at least one employee, and every employee has a contact
record.

## 12. Aggregate Reporting Queries

```sql
-- Headcount and average salary per department
SELECT
    d.DeptName,
    COUNT(e.EmpCode) AS employee_count,
    ROUND(AVG(e.Salary), 2) AS avg_salary
FROM department d
LEFT JOIN employee e ON d.DeptCode = e.DEPTCODE
GROUP BY d.DeptCode, d.DeptName
ORDER BY avg_salary DESC;

-- Orders placed per person
SELECT
    CONCAT(p.FirstName, ' ', p.LastName) AS customer_name,
    COUNT(o.OrderID) AS total_orders
FROM persons p
LEFT JOIN orders o ON p.ID = o.PersonID
GROUP BY p.ID, customer_name
ORDER BY total_orders DESC;
```

**Expected:** reasonable, correctly-grouped numbers — no department or
person silently dropped from the results just because they have zero
matches (the `LEFT JOIN` protects against that).

## 13. Basic Sanity / Range Checks

```sql
SELECT * FROM employee WHERE Salary < 0;
```

**Expected:** zero rows. Worth noting this isn't currently backed by a
database-level rule — there's no `CHECK` constraint stopping a negative
salary from being inserted, so this is a manual check rather than
something the schema itself guarantees. A `CHECK (Salary >= 0)` is listed
as a follow-up improvement below.

## 14. Filtering

```sql
SELECT * FROM employee WHERE Salary > 3000;
SELECT * FROM department WHERE Location = 'New York';
```

**Expected:** only rows matching the condition come back — used here more
as a general query-correctness check than a constraint test.

## 15. Sorting

```sql
SELECT EmpFName, EmpLName, Salary
FROM employee
ORDER BY Salary DESC;
```

**Expected:** the highest-paid employee appears first, lowest last, with
no ties out of order.

## 16. Transactions and Rollback

```sql
START TRANSACTION;

UPDATE employee SET Salary = 0 WHERE EmpCode = 9369;
SELECT EmpCode, Salary FROM employee WHERE EmpCode = 9369;

ROLLBACK;

SELECT EmpCode, Salary FROM employee WHERE EmpCode = 9369;
```

**Expected:** the salary shows as `0` right after the UPDATE (inside the
open transaction), and back to its original value of `2800` after the
`ROLLBACK` runs — confirming the rollback actually undid the change rather
than just appearing to.

## 17. Cascading Deletes

Two of the foreign keys in this schema are defined with
`ON DELETE CASCADE`, meaning deleting the parent row should automatically
remove its dependent rows.

```sql
START TRANSACTION;

SELECT * FROM employee_contact WHERE EmpCode = 9861;
DELETE FROM employee WHERE EmpCode = 9861;
SELECT * FROM employee_contact WHERE EmpCode = 9861;

ROLLBACK;
```

**Expected:** the first SELECT shows the contact record, the second (after
the DELETE) returns nothing — the cascade removed it automatically without
a separate DELETE statement against `employee_contact`. The transaction is
rolled back afterward purely so the test doesn't permanently remove real
data.

## 18. Final Regression Pass

After all the negative tests above (several of which are deliberately
rejected inserts), a final pass confirms the database is still in a clean,
usable state and nothing was accidentally left behind:

```sql
SHOW TABLES;
SELECT COUNT(*) FROM student_information;
SELECT COUNT(*) FROM student_parents_information;
SELECT COUNT(*) FROM persons;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM department;
SELECT COUNT(*) FROM employee;
SELECT COUNT(*) FROM employee_contact;
```

**Expected:** the row counts match the baseline from Step 3 — the rejected
inserts didn't add anything, and the rolled-back transactions didn't leave
any changes behind either.

---

# 🔧 Schema Issues Found, and What Changed

The original `sql_testing_lab` export had five structural problems, fixed
directly in `sql/02_create_tables.sql`. Summarized here:

| # | Problem in the original export | What was done about it |
|---|---|---|
| 1 | `employee.EmpCode` had no primary key, so duplicate or blank employee codes were technically allowed | Added `PRIMARY KEY (EmpCode)` |
| 2 | `department` was keyed on `EmpCode` and repeated employee names instead of holding actual department data, and contained 8 rows that matched no real employee | Rebuilt around `DeptCode` / `DeptName` / `Location`; moved the address/phone data into a new `employee_contact` table |
| 3 | `employee.DEPTCODE` had nothing enforcing that it pointed at a real department | Added a `FOREIGN KEY` to `department.DeptCode` |
| 4 | `student_parents_imformation` (also missing an "n") had no column linking a row to a specific student | Renamed the table and added a `student_id` `FOREIGN KEY` |
| 5 | `persons` and `orders` had no data at all, so the existing foreign key between them had never been tested | Added a small set of sample rows |

---

# ✅ Testing Coverage

- [x] Environment / database validation
- [x] Table structure validation
- [x] Row count baseline
- [x] Primary key testing (positive and negative)
- [x] Foreign key testing (positive and negative)
- [x] NOT NULL constraint testing
- [x] Data type validation
- [x] Nullable field / optional data testing
- [x] Full CRUD cycle testing
- [x] JOIN / relationship testing
- [x] Orphan record / anti-join testing
- [x] Aggregate query testing
- [x] Filter testing
- [x] Sort testing
- [x] Transaction and rollback testing
- [x] Cascading delete testing
- [x] Final regression check

Full pass/fail results for every test listed above:
[`docs/test_cases.md`](docs/test_cases.md) — currently **24 / 24 passing**
against the corrected schema.

---

# 📝 Follow-Up Improvements

A few things intentionally left out of this pass, noted here rather than
silently ignored:

- **No `CHECK` constraints yet.** Salary can't currently be enforced as
  non-negative at the database level — Section 13 above tests for it
  manually. Adding `CHECK (Salary >= 0)` would close that gap.
- **`persons` and `orders` only have placeholder data.** They were empty
  in the original export; the current rows exist purely to exercise the
  foreign key and should be replaced with real data if this ever needs to
  be more than a practice schema.
- **`DEPTCODE` is still nullable.** That's correct for now (a new hire
  might not be assigned yet), but if the business rule ever changes to
  "every employee must have a department," this column should switch to
  `NOT NULL`.

---

# 🎯 What This Project Reinforced

- Reading an existing schema critically instead of assuming it's already
  correct — a working `SELECT` doesn't mean the underlying design is sound
- Adding `PRIMARY KEY` and `FOREIGN KEY` constraints to a table that
  already has data in it, without losing anything
- Using anti-joins specifically to hunt for orphaned or disconnected
  records, rather than only writing joins that assume everything matches
- Treating a rejected `INSERT` as a *passing* test result, not an error to
  work around
- Writing up a schema fix with enough detail (root cause, fix, and how
  it's verified) that someone else could follow the reasoning later

---

## 👤 Author

**Database Testing Practice Project — SQL Testing Lab**
Built with MySQL, MySQL Workbench, SQL, and Git/GitHub.
