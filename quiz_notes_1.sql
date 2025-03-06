/*
SQL has lots of weird syntax compared to other languages.
This is because: 
1. SQL was designed in the 70s before current conventions were standardized, and
1. these conventions have not been changed for backwards compatibility reasons.
*/

-- commands case insensitive, but text case sensative
sElEcT 'hello world';

--Output:
--  ?column?
-------------
-- hello world
-- (1 row)

SELECT 'Hello' = 'hello';

--Output:
-- ?column?
----------
-- f
-- (1 row)

-- string concatenation uses || not +
-- + used only for "real" math
SELECT 'hello' || 'world';

--Output
--  ?column?
------------
-- helloworld
-- (1 row)

SELECT 1 + 2;

--Output
-- ?column?
----------
--   3
--(1 row)

-- escape quotations by doubling the quote marked
SELECT 'isn''t SQL great?';
-- SELECT 'isn\'t SQL great?';          /* syntax error */

--Output
--     ?column?
------------------
-- isn't SQL great?
--(1 row)

-- sql supports the "dollar quoted string literal" syntax
SELECT $$isn't SQL great?$$;
SELECT $blah$isn't SQL great?$blah$; /* both queries are same */

--Output
--     ?column?
------------------
-- isn't SQL great?
-- (1 row)


-- double quotes for column/relation names
-- they are optional if no special characters are used in the name
SELECT 'hello world';
SELECT 'hello world' AS greeting;
--Output
--  greeting
-------------
-- hello world
--(1 row)

SELECT 'hello world' AS "the greeting";


/*
All the notes below concern the *semantics* of SQL instead of the *syntax*.
*/

-- aggregate functions will ignore null values only if included in the function list

SELECT count(*) FROM basket_a; -- Output: count: 7
SELECT count(1) FROM basket_a; -- Output: count: 7. Same as above, but all rows will be filled with 1
SELECT count(fruit_a) FROM basket_a; -- Output: count: 5. Ignores 2 NULL entries
SELECT count(id) FROM basket_a; -- Output: count: 5. Ignores 2 NULL entries
SELECT count(id || fruit_a) FROM basket_a; -- Output: count: 4. Concatenates id and fruit_a, and if either entry has NULL, then the concatenation will be NULL, so 3 total NULL

SELECT sum(1) FROM basket_a; --Output: sum: 7. Sum of 7 1s
SELECT sum(id) FROM basket_a; -- Output: sum: 11. Sum of id (1+1+2+3+4) 

-- the DISTINCT operator removes duplicates before passing to the aggregate function

SELECT count(DISTINCT fruit_a) FROM basket_a; -- Output: count: 4. Gets 5 distinct values, ignores NULL so becomes 4
SELECT count(DISTINCT id) FROM basket_a; -- Output: count: 4. Same as above 
SELECT count(DISTINCT 1) FROM basket_a; -- Output: count: 1. All rows are 1, so only 1 distinct entry
SELECT sum(DISTINCT id) FROM basket_a; -- Output: sum: 10. Sums all distinct ids (1+2+3+4)

-- operators on NULL values always return NULL
-- A NULL condition in a WHERE clause causes the row to not be selected

SELECT count(*) FROM basket_a WHERE fruit_a = NULL; -- Output: count: 0
SELECT count(*) FROM basket_a WHERE fruit_a IS NULL; -- Output: count: 2. Still selects rows where fruit_a is NULL
SELECT count(*) FROM basket_a WHERE fruit_a != NULL; -- Output: count: 0
SELECT count(*) FROM basket_a WHERE fruit_a IS NOT NULL; -- Output: count: 5. Still selects rows where fruit_a is not NULl

SELECT count(*) FROM basket_a WHERE id < 3; -- Output: count: 3. Selects id = 1, 1, 2
SELECT count(*) FROM basket_a WHERE id < 3 OR id IS NULL; -- Output: count: 5. Selects id = 1, 1, 2, and NULL ids
SELECT count(id) FROM basket_a WHERE id < 3; -- Output: count: 3.
SELECT count(DISTINCT id) FROM basket_a WHERE id < 3; -- Output: count: 2. Selects id = 1, 2

SELECT count(*) FROM basket_a WHERE (fruit_a = NULL) IS NULL; -- Output: count: 7. Equivalent to WHERE NULL IS NULL, which is always TRUE, since fruit_a = NULL always equates to NULL
SELECT count(*) FROM basket_a WHERE NOT (fruit_a = NULL) IS NULL; -- Output: count: 0. Equivalent to WHERE NOT NULL IS NULL, which is never true

SELECT sum(id) FROM basket_a WHERE fruit_a IS NULL; -- Output: sum: 4. 
SELECT sum(id) FROM basket_a WHERE id IS NOT NULL; -- Output: sum: 11

-- In the ANSI SQL standard:
-- (1) the LIKE operator is case sensitive
-- (2) % behaves in the same way as the POSIX glob
--
-- Case sensitive operations are usually more efficient to implement;
-- case in-sensitive operations, are usually more useful.
--
-- In postgres:
-- (1) LIKE is case sensitive
-- (2) ILIKE is case insensitive
--
-- In sqlite3:
-- (1) LIKE is case insensitive
-- (2) ILIKE does not exist and results in an error

SELECT count(*) FROM basket_a WHERE fruit_a LIKE '%a%'; -- Output: count: 2. Orange and banana only since capital A in Apple not matched
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE '%a%'; -- Output: count: 4. Apple now included
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE 'a%'; -- Output: count: 2. Only the 2 copies of Apple
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE 'a'; -- Output: count: 0
SELECT count(DISTINCT fruit_a) FROM basket_a WHERE fruit_a ILIKE '%a%';-- Output: count: 3. Orange, banana, and one Apple


-- GROUP BY considers NULL values to be their own group
-- NULL values are by default ordered last

SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
ORDER BY fruit_a DESC;

-- Output:
-- fruit_a  | count
------------+-------
--          |     2
-- Orange   |     1
-- Cucumber |     1
-- Banana   |     1
-- Apple    |     2
--(5 rows)


SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
ORDER BY fruit_a ASC; -- Default ORDER BY is ASC

-- Output:
-- fruit_a  | count
------------+-------
-- Apple    |     2
-- Banana   |     1
-- Cucumber |     1
-- Orange   |     1
--          |     2
--(5 rows)

-- the WHERE clause happens before the GROUP BY, the HAVING clause happens after the GROUP BY
-- the WHERE clause cannot contain aggregate functions, but the HAVING clause can
-- the HAVING clause cannot contain columns that are not included in the SELECT statement's column list, but the WHERE clause can

SELECT fruit_a, count(*)
FROM basket_a
WHERE id IS NULL
GROUP BY fruit_a
ORDER BY fruit_a;

-- Output:
-- fruit_a  | count
------------+-------
-- Cucumber |     1
--          |     1
--(2 rows)

SELECT fruit_a, count(*)
FROM basket_a
WHERE id = NULL
GROUP BY fruit_a
ORDER BY fruit_a; -- = NULL does not run

-- Output:
-- fruit_a | count
-----------+-------
--(0 rows)

SELECT fruit_a, count(fruit_a)
FROM basket_a
WHERE id < 5 AND id >= 3
GROUP BY fruit_a
ORDER BY fruit_a; -- NULL fruit_a not included in count

-- Output:
-- fruit_a | count
-----------+-------
-- Banana  |     1
--         |     0
--(2 rows)

SELECT fruit_a, count(*)
FROM basket_a
WHERE id < 5 AND id >= 3
GROUP BY fruit_a
ORDER BY fruit_a;

-- Output:
-- fruit_a | count
-----------+-------
-- Banana  |     1
--         |     1
--(2 rows)

SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
HAVING count(*) > 1
ORDER BY fruit_a; -- count(*) includes NULL

-- Output:
-- fruit_a | count
-----------+-------
-- Apple   |     2
--         |     2
--(2 rows)

SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
HAVING count(fruit_a) = 1
ORDER BY fruit_a;
-- Output:
-- fruit_a  | count
------------+-------
-- Banana   |     1
-- Cucumber |     1
-- Orange   |     1
--(3 rows)

SELECT fruit_a, count(*)
FROM basket_a
WHERE fruit_a LIKE '%a%'
GROUP BY fruit_a
HAVING fruit_a LIKE '%a%'
ORDER BY fruit_a; -- HAVING doesn't do anything if same as WHERE. If using count(), must have GROUP BY with a column of SELECT

-- Output: 
-- fruit_a | count
-----------+-------
-- Banana  |     1
-- Orange  |     1
--(2 rows)

-- JOINs construct a new table by combining two separate tables.
-- All JOINs are constructed internally from a CROSS JOIN,
-- but CROSS JOINs are rarely directly used in practice.
-- The CROSS JOIN joins every row from the first table with every other row from the second table. Every combination achieved

-- Start of CROSS JOIN
 id | fruit_a  | id |  fruit_b
----+----------+----+------------
  1 | Apple    |  1 | Apple
  1 | Apple    |  2 | Apple
  1 | Apple    |  3 | Orange
  1 | Apple    |  4 | Orange
  1 | Apple    |  5 | Watermelon
  1 | Apple    |    | Pear
  1 | Apple    |  6 |
  1 | Apple    |    |
  1 | Apple    |  1 | Apple
  1 | Apple    |  2 | Apple
  1 | Apple    |  3 | Orange
  1 | Apple    |  4 | Orange
  1 | Apple    |  5 | Watermelon
  1 | Apple    |    | Pear


SELECT count(*)
FROM basket_a, basket_b; -- Output: count: 56. Same as rows basket_a * rows basket_b, which is 7*8

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id; -- Output: count: 5. 1, 1, 2, 3, 4 from each table match once

SELECT count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id; -- Same as above but NULL ignored

SELECT count(DISTINCT basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id; -- Output: count: 4. Removes duplicateof 1:1

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id OR (basket_a.id IS NULL AND basket_b.id IS NULL); -- Output: count: 9. Same as above but each NULL in basket_a matches 2 NULLS in basket_b

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.id > basket_b.id; -- Output: count: 6. 2>1, 3>1 and 2, 4>1,2, and 3. NULL not evaluated for inequality

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b; -- Output: count: 6. NULL not evaluated

SELECT count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b; -- Same as above since no NULL values

SELECT count(DISTINCT basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b; -- Output: count: 2. Duplicated removed

SELECT fruit_a, count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b
GROUP BY fruit_a
ORDER BY fruit_a DESC;

-- Output:
-- fruit_a | count
-----------+-------
-- Orange  |     2
-- Apple   |     4
--(2 rows)

SELECT fruit_a, count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b
GROUP BY fruit_a
HAVING count(basket_a.id) > 3
ORDER BY fruit_a;

 fruit_a | count
---------+-------
 Apple   |     4
(1 row)

SELECT fruit_a, count(*)
FROM basket_a, basket_b
WHERE basket_a.id > basket_b.id
GROUP BY fruit_a
ORDER BY fruit_a;

 fruit_a | count
---------+-------
 Banana  |     2
 Orange  |     1
         |     3
(3 rows)

-- The INNER JOIN is syntactic sugar for a CROSS JOIN plus a WHERE clause

SELECT count(DISTINCT basket_a.id)
FROM basket_a
JOIN basket_b ON basket_a.id = basket_b.id;

 count
-------
     4
(1 row)

/*
the above query is equivalent to 

SELECT count(DISTINCT basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id;
*/

SELECT fruit_a, count(*)
FROM basket_a
JOIN basket_b ON basket_a.id > basket_b.id
GROUP BY fruit_a
ORDER BY fruit_a;

 fruit_a | count
---------+-------
 Banana  |     2
 Orange  |     1
         |     3
(3 rows)

/*
the above query is equivalent to 

SELECT fruit_a, count(*)
FROM basket_a, basket_b
WHERE basket_a.id > basket_b.id
GROUP BY fruit_a
ORDER BY fruit_a;
*/

-- The USING clause is syntactic sugar for an INNER JOIN that:
-- (1) uses an equality condition
-- (2) has identical column names in both tables
--
-- WARNING:
-- Ensure that you understand the behavior of NULL values.

SELECT DISTINCT id
FROM basket_a
JOIN basket_b USING (id);

 id
----
  3
  4
  2
  1
(4 rows)

SELECT count(DISTINCT id)
FROM basket_a
JOIN basket_b USING (id);

 count
-------
     4
(1 row)

/*
the above query is equivalent to

SELECT count(DISTINCT basket_a.id)
FROM basket_a
JOIN basket_b ON basket_a.id = basket_b.id

Note that in the column list for JOINs with the ON clause,
we must use "fully qualified names" to refer to columns.
When we use the USING clause,
we do not need to specify the table of the "id" column.
*/

SELECT count(*)
FROM basket_a
JOIN basket_b USING (id)
WHERE id IS NOT NULL; -- Same without WHERE condition

 count
-------
     5
(1 row)

-- The NATURAL JOIN is syntactic sugar for a USING clause.
-- It joins the tables on all columns with shared names.

SELECT count(DISTINCT id)
FROM basket_a
NATURAL JOIN basket_b; -- Same as above


-- A "self join" is a join of a table with itself.
-- Self joins are not their own special join type;
-- any type of join (e.g. CROSS, INNER, NATURAL) can be called a self join.
-- To be syntactically valid, a self join must specify a "table alias".
-- (Table aliases are always allowed, but required for self joins.)
-- Aliases disambiguate which column of the table we are referring to.

SELECT count(*)
FROM basket_a AS a1
   , basket_a AS a2
WHERE a1.id > a2.id; -- Output: count: 9. 2>1 and 1, 3> 2, 1, and 1, 4> 3, 2, 1, 1. 

SELECT count(*)
FROM basket_a AS a1
   , basket_a AS a2
WHERE a1.id = a2.id; -- Output: count: 7. 1=1,1. 1=1,1. 2=2. 3=3. 4=4. 

SELECT count(*)
FROM basket_a a1 -- the AS keyword is optional
   , basket_a a2
WHERE a1.id = a2.id; -- Same as above

SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 USING (id); -- Same as above

SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 USING (id, fruit_a); -- Output: count: 6. Same as above, but NULL fruit_a now ignored

SELECT count(*)
FROM basket_a a1
NATURAL JOIN basket_a a2; -- Same as above since NATURAL JOIN matches id and fruit_a so NULL ignored

-- All joins are "binary operations" and involve exactly two tables.
-- But multiple joins can be combined together.
-- CROSS JOINS, INNER JOINS, and NATURAL JOINS are associative and commutative (up to the ordering of column results).

SELECT count(*)
FROM basket_a a1, basket_a a2, basket_b
WHERE a1.id = a2.id
  AND a1.fruit_a = basket_b.fruit_b; -- Output: count: 10. First JOIN same as above, with 4 1:Apple, a 2:Orange, a 3:Banana, and a 4:NULL. Each 1:Apple matches 2 Apples from basket_b, and the 2:Orange matches 2 Oranges from basket_b

/*
the above query is the same as

SELECT count(*)
FROM basket_a a1, basket_b, basket_a a2
WHERE a1.id = a2.id
  AND a1.fruit_a = basket_b.fruit_b;

SELECT count(*)
FROM basket_b, basket_a a2, basket_a a1 
WHERE a1.id = a2.id
  AND a1.fruit_a = basket_b.fruit_b;
*/

SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 ON a1.id = a2.id
JOIN basket_b ON a1.fruit_a = basket_b.fruit_b; -- Same as above

/*
the above query is equivalent to

SELECT count(*)
FROM basket_a a1
JOIN basket_b ON a1.fruit_a = basket_b.fruit_b
JOIN basket_a a2 ON a1.id = a2.id;

SELECT count(*)
FROM basket_b 
JOIN basket_a a1 ON a1.fruit_a = basket_b.fruit_b
JOIN basket_a a2 ON a1.id = a2.id;
*/

-- NOTE:
-- SQL is based mathematically on "relational algebra".
-- If this were a database theory course,
-- we would cover relational algebra in detail and prove the associative and commutative properties above.
