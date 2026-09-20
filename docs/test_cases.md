# Test Cases — SQL Testing Lab Database (Linked Schema)

Legend — **P** = Pass, **F** = Fail

## A. student_information / student_parents_information

| ID | Title | Steps | Expected | Actual | Status |
|---|---|---|---|---|---|
| TC-A1 | Row counts | COUNT(*) on both tables | 4 and 4 | 4 and 4 | P |
| TC-A2 | PK uniqueness | GROUP BY student_id HAVING COUNT>1 | 0 rows | 0 rows | P |
| TC-A3 | Duplicate PK rejected | INSERT student_id = 1 again | Rejected, error 1062 | Rejected as expected | P |
| TC-A4 | Student ↔ parent JOIN | JOIN on student_id | Every student shows a linked parent record | As expected | P |
| TC-A5 | No orphan students | LEFT JOIN parents, WHERE parent_id IS NULL | 0 rows | 0 rows | P |
| TC-A6 | FK rejects unknown student | INSERT parent row with student_id = 999 | Rejected, error 1452 | Rejected as expected | P |
| TC-A7 | Cascade delete | DELETE a student, check parent row | Parent row removed automatically | As expected | P |

## B. persons / orders

| ID | Title | Steps | Expected | Actual | Status |
|---|---|---|---|---|---|
| TC-B1 | PK uniqueness on persons | GROUP BY ID HAVING COUNT>1 | 0 rows | 0 rows | P |
| TC-B2 | NOT NULL on LastName | INSERT without LastName | Rejected, error 1364 | Rejected as expected | P |
| TC-B3 | FK violation on orders.PersonID | INSERT PersonID = 999 | Rejected, error 1452 | Rejected as expected | P |
| TC-B4 | Orders ↔ persons JOIN | JOIN on PersonID = ID | Correct customer name per order | As expected | P |
| TC-B5 | Orders per person | LEFT JOIN + COUNT, GROUP BY person | Correct count per person, including 0 | As expected | P |

## C. department / employee / employee_contact

| ID | Title | Steps | Expected | Actual | Status |
|---|---|---|---|---|---|
| TC-C1 | Row counts | COUNT(*) on all three | 4 / 17 / 17 | 4 / 17 / 17 | P |
| TC-C2 | PK uniqueness on employee | GROUP BY EmpCode HAVING COUNT>1 | 0 rows | 0 rows | P |
| TC-C3 | Duplicate EmpCode now rejected | INSERT EmpCode = 9369 again | Rejected, error 1062 | Rejected as expected (previously **not** enforced) | P |
| TC-C4 | FK rejects unknown department | INSERT employee with DEPTCODE = 999 | Rejected, error 1452 | Rejected as expected | P |
| TC-C5 | NULL DEPTCODE allowed | WHERE DEPTCODE IS NULL | Returns rows for employees not yet assigned | 1 row (MADII HIMBURY) | P |
| TC-C6 | Employee ↔ department JOIN | LEFT JOIN on DEPTCODE = DeptCode | Every employee shows department name/location, or NULL if unassigned | As expected | P |
| TC-C7 | Employee ↔ contact JOIN | JOIN on EmpCode | Every employee shows an address/phone | As expected (17 of 17) | P |
| TC-C8 | No orphan departments | LEFT JOIN employee, WHERE EmpCode IS NULL | 0 rows | 0 rows | P |
| TC-C9 | Aggregate - avg salary per department | GROUP BY DeptCode | Reasonable averages per department | As expected | P |
| TC-C10 | Data type test on HireDate | INSERT invalid date string | Rejected, error 1292 | Rejected as expected | P |
| TC-C11 | Transaction rollback | UPDATE Salary, then ROLLBACK | Salary restored to 2800 | As expected | P |
| TC-C12 | Cascade delete | DELETE an employee, check contact row | Contact row removed automatically | As expected | P |

## Summary

| Area | Total | Pass | Fail |
|---|---|---|---|
| student_information / student_parents_information | 7 | 7 | 0 |
| persons / orders | 5 | 5 | 0 |
| department / employee / employee_contact | 12 | 12 | 0 |
| **Total** | **24** | **24** | **0** |

All previously open defects (missing primary key on `employee`, missing
foreign key on `DEPTCODE`, orphan rows in the old `department` table, and
the missing link between students and their parent records) are now fixed
in the schema and verified by TC-A6/A7, TC-C3, TC-C4 and TC-C8.
