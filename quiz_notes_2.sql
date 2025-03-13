-- A "subquery" is a SELECT statement that is inside another SELECT statement;
-- Subqueries can be placed anywhere a tablename can be placed;
-- Subqueries used in this way must be given a name

SELECT count(*) FROM (
    SELECT id FROM basket_a
) AS t; -- the AS is optional

/*
| count(*) |
|----------|
| 7        |
*/

/*
The above query is equivalent to

SELECT count(*) FROM basket_a;
*/

-- JOINs combine tables "horizontally" whereas set operations combine tables "vertically"
-- column types must match between the two select statements,
-- but the final column names will be the column names of the first query

-- UNION ALL concatenates the results of two queries
-- UNION also removes duplicates

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    UNION ALL
    SELECT fruit_b FROM basket_b
) t;

/*
 * All rows from basket_a and basket_b, including NULL
| count(*) |
|----------|
| 15       |
*/

-- NOTE:
-- sqlite3 is "weakly typed", and postgres is "strongly typed";
-- the types from a UNION need not match in sqlite3,
-- but they must match in postgres;
-- see: <https://www.sqlite.org/quirks.html>

/*
The following query is not allowed in postgres, but is allowed in sqlite3

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    UNION ALL
    SELECT id FROM basket_b
) t;
*/

/*
 * Sqlite3 output:
| count(*) |
|----------|
| 15       |
*/

/* Postgres supports every set operation including the ALL variant
 *
 * sqlite3 only supports set operations that do not include the ALL variant */

-- UNION removes duplicates, so changing the columns can change the number of rows
-- UNION ALL: changing the columns will never change the number of rows
-- UNION ALL is available in sqlite3

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    UNION
    SELECT fruit_b FROM basket_b
) t;
/*
 * Takes all fruit_a and adds new fruits from fruit_b, including NULL
| count(*) |
|----------|
| 7        |
 * Without count(*)
|  fruit_a   |
|------------|
|            |
| Apple      |
| Banana     |
| Cucumber   |
| Orange     |
| Pear       |
| Watermelon |
*/

SELECT count(*) FROM (
    SELECT id, fruit_a FROM basket_a
    UNION
    SELECT id, fruit_b FROM basket_b
) t;

/*
 * Selects all id, fruit_a pairs, then adds all new id fruit_b pairs
| count(*) |
|----------|
| 12       |
 * Without count(*)
| id |  fruit_a   |
|----|------------|
|    |            |
|    | Cucumber   |
|    | Pear       |
| 1  | Apple      |
| 2  | Apple      |
| 2  | Orange     |
| 3  | Banana     |
| 3  | Orange     |
| 4  |            |
| 4  | Orange     |
| 5  | Watermelon |
| 6  |            |
*/


SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    WHERE id < 3
    UNION ALL
    SELECT fruit_b FROM basket_b
    WHERE id > 3 AND fruit_b ILIKE '%a%'
) t;
-- Remember ILIKE not available in sqlite3
/*
 count
-------
     5
  fruit_a
------------
 Apple
 Apple
 Orange
 Orange
 Watermelon
(5 rows)
*/

SELECT count(id) FROM (
    SELECT DISTINCT id FROM basket_a
    UNION ALL
    SELECT id FROM basket_b
) t;
/*
| count(id) |
|-----------|
| 10        |
 * 1,2,3,NULL,4 from basket_a, 1,2,3,4,5,NULL,6,NULL from basket_b, but NULL not counted
| id |
|----|
| 1  |
| 2  |
| 3  |
|    |
| 4  |
| 1  |
| 2  |
| 3  |
| 4  |
| 5  |
|    |
| 6  |
|    |
*/

SELECT count(id) FROM (
    SELECT DISTINCT id FROM basket_a
    UNION ALL
    SELECT DISTINCT id FROM basket_b
) t;
-- Output=10, same logic as above but one less NULL

SELECT count(id) FROM (
    SELECT id FROM basket_a
    UNION ALL
    SELECT id FROM basket_b
) t;
-- Output=11, same logic as above but multiple 1s from basket_a

SELECT count(DISTINCT id) FROM (
    SELECT id FROM basket_a
    UNION ALL
    SELECT id FROM basket_b
) t;
-- Output=6, same logic as above but no duplicates, so ids are only integers 1-6 once

-- REMEMBER LIKE IS DIFFERENT IN SQLITE3 AND PSQL
SELECT count(DISTINCT id) FROM (
    SELECT id FROM basket_a
    WHERE
        fruit_a LIKE '%a%'
    UNION ALL
    SELECT id FROM basket_b
    WHERE
        fruit_b LIKE '%A%'
) t;

-- PSQL: output=3, since A does not capture orange, watermelon, or pear
-- sqlite3: output=5, since A captures the above, but NULL:pear is not counted

SELECT 'Apple' UNION SELECT 'Orange';

/*
| 'Apple' |
|---------|
| Apple   |
| Orange  |
*/

-- INTERSECT ALL returns all rows that are in both queries
-- INTERSECT also removes duplicates
-- INTERSECT ALL does not work in sqlite3!
SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    INTERSECT
    SELECT fruit_b FROM basket_b
) t;

/* Output=3
 fruit_a
---------

 Orange
 Apple
*/

SELECT count(*) FROM (
    SELECT id, fruit_a FROM basket_a
    INTERSECT
    SELECT id, fruit_b FROM basket_b
) t;
/* NULL counted since count(*)
 id | fruit_a
----+---------
    |
  1 | Apple
(2 rows)
*/

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    INTERSECT ALL
    SELECT fruit_b FROM basket_b
) t;

/* 2 Apples, 2 NULLs in each table
 fruit_a
---------


 Orange
 Apple
 Apple
(5 rows)
*/

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    INTERSECT
    SELECT fruit_a FROM basket_a
    WHERE id < 5
) t;

/* Intersect on itself, NULL id considered < 5
 fruit_a
---------

 Banana
 Orange
 Apple
(4 rows)
*/

-- EXCEPT ALL returns all rows that are in the first query but not the second
-- EXCEPT also removes duplicates
-- EXCEPT ALL not in sqlite3

SELECT count(*)
FROM (
    SELECT fruit_a FROM basket_a
    EXCEPT ALL
    SELECT fruit_b FROM basket_b
) t;

/* output:2
 fruit_a
----------
 Banana
 Cucumber
(2 rows)
*/

SELECT count(DISTINCT fruit_a)
FROM (
    SELECT fruit_a FROM basket_a
    EXCEPT
    SELECT fruit_b FROM basket_b
    WHERE fruit_b IS NOT NULL
) t;

/* Output=2, since NULL entry is not counted for count(col)
 * Same as above, but NULL in fruit_a not found in fruit_b
 fruit_a
----------

 Banana
 Cucumber
(3 rows)
*/

SELECT count(*)
FROM (
    SELECT fruit_b FROM basket_b
    EXCEPT
    SELECT fruit_a FROM basket_a
    WHERE fruit_a IS NOT NULL
) t;

/* Output=3
  fruit_b
------------

 Watermelon
 Pear
(3 rows)
*/

SELECT count(*) FROM (
    SELECT fruit_b FROM basket_b
    EXCEPT
    SELECT NULL
) t;

/* All nonnull fruit_b, removing duplicates
  fruit_b
------------
 Orange
 Watermelon
 Pear
 Apple
(4 rows)
*/

-- The IN operator lets you compare to a "list"
-- See: <https://www.postgresql.org/docs/15/functions-comparisons.html#FUNCTIONS-COMPARISONS-IN-SCALAR>
/*
A IN (a, b, c)
is syntactic sugar for
A = a OR A = b OR A = c
*/

-- Know how IN interacts with NULL
-- Does not work if NULL is the only item in list
-- Works if NULL is item in list along with other Non NULL items

SELECT count(*) FROM basket_a WHERE id      IN (3, 4);
-- Output=2
-- Equivalent: SELECT count(*) FROM basket_a WHERE id = 3 or id = 4;
SELECT count(*) FROM basket_a WHERE fruit_a IN ('Apple', 'Orange');
-- Output=3
SELECT count(*) FROM basket_a WHERE fruit_a IN (NULL);
-- Output=0
SELECT count(*) FROM basket_a WHERE id      NOT IN (3, 4);
-- Output=3, NULL ids not considered
SELECT count(*) FROM basket_a WHERE fruit_a NOT IN ('Apple', 'Orange');
-- Output=2, NULL fruit_as not considered
SELECT count(*) FROM basket_a WHERE fruit_a NOT IN (NULL);
-- Output=0, IN NULL will not be evaluated
SELECT count(*) FROM basket_a WHERE NOT id      IN (3, 4);
-- Output=3, same behavior as NOT IN
SELECT count(*) FROM basket_a WHERE NOT fruit_a IN ('Apple', 'Orange');
-- Output=2, same behavior as NOT IN
SELECT count(*) FROM basket_a WHERE NOT fruit_a IN (NULL);
-- Output=0, same behavior as NOT IN

-- A common use-case for subqueries is to populate the "list" to the right of the IN operator
-- These subqueries can only have a single column and do not require a name

SELECT count(*) FROM basket_a WHERE id      IN (SELECT  3      UNION SELECT 4       );
-- Output=2
SELECT count(*) FROM basket_a WHERE fruit_a IN (SELECT 'Apple' UNION SELECT 'Orange');
-- Output=3

SELECT count(*)                 FROM basket_a WHERE fruit_a IN (SELECT fruit_b  FROM basket_b);
-- Output=3, Apple, Apple, Orange from fruit_a IN fruit_b
SELECT count(*)                 FROM basket_a WHERE fruit_a IN (SELECT DISTINCT fruit_b  FROM basket_b);
-- Same as above

-- adding the DISTINCT keyword into the subquery to the right of an IN clause will never change the results
-- Since OR clauses only evaluates each item once

SELECT count(*)                 FROM basket_a WHERE id      IN (SELECT id       FROM basket_b);
-- Output=5, 1,1,2,3,4 are id from a in b
SELECT count(fruit_a)           FROM basket_a WHERE id      IN (SELECT id       FROM basket_b);
-- Output=4, same as above but 4:NULL not counted since fruit_a is NULL
SELECT count(DISTINCT fruit_a)  FROM basket_a WHERE id      IN (SELECT id       FROM basket_b);
-- Output=3, same as above but 2 Apples counted once
/*
| id | fruit_a |
|----|---------|
| 1  | Apple   |
| 1  | Apple   |
| 2  | Orange  |
| 3  | Banana  |
| 4  |         |
*/

-- We've already seen that the INNER JOIN is syntactic sugar over the cross join plus a condition;
-- that is, the following two statements are equivalent:
--
--     SELECT * FROM a JOIN b ON (condition);
--     SELECT * FROM a,b WHERE condition;
--
-- Outer joins are syntactic sugar for INNER JOIN plus a set operation;
-- The left outer join given by
--
--     SELECT * FROM a LEFT JOIN b ON (condition);
--
-- is equivalent to
--
--     SELECT * FROM a JOIN b ON (condition) (inner join)
--     UNION ALL
--     (
--     SELECT a.*,NULL,NULL,NULL,... FROM a         -- there should be one NULL for each column in b
--     EXCEPT ALL
--     SELECT a.*,NULL,NULL,NULL,... FROM a JOIN b ON (condition)
--     ); (all rows in table a not captured by the join)
--
-- when `condition` is an equality of the form `a.c1=b.c2` and there are no NULL values, then the following is also equivalent:
--
--     SELECT * FROM a JOIN b ON (a.c1 = b.c2)
--     UNION ALL
--     SELECT * FROM a WHERE a.c1 NOT IN (SELECT b.c2 FROM b);

-- LEFT JOIN is inner join a,b with condition plus all rows in a not in b. For the additional rows, NULL values will fill the other columns from b

SELECT count(*)
FROM basket_a
JOIN basket_b USING (id);
/*
| id | fruit_a | fruit_b |
|----|---------|---------|
| 1  | Apple   | Apple   |
| 1  | Apple   | Apple   |
| 2  | Orange  | Apple   |
| 3  | Banana  | Orange  |
| 4  |         | Orange  |
*/

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b USING (id);
-- Output=7, since 1,1,2,3,4 match ids, plus the 2 NULL id rows from basket_a are added
/*
| id | fruit_a  | fruit_b |
|----|----------|---------|
| 1  | Apple    | Apple   |
| 1  | Apple    | Apple   |
| 2  | Orange   | Apple   |
| 3  | Banana   | Orange  |
|    | Cucumber |         |
| 4  |          | Orange  |
|    |          |         |
*/

SELECT count(fruit_b)
FROM basket_a
LEFT JOIN basket_b USING (id);
-- Output=5, see above

SELECT count(DISTINCT fruit_b)
FROM basket_a
LEFT JOIN basket_b USING (id);
-- Output=2, see above

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b USING (id)
WHERE
    fruit_b LIKE '%a%';
-- psql: output=2
-- sqlite: output=5
-- see above


SELECT count(*)
FROM basket_a
LEFT JOIN basket_b USING (id)
WHERE
    id > 1;
-- Output=3, see above

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (fruit_a = fruit_b);
-- Output=10
/*
 id | fruit_a  | id | fruit_b
----+----------+----+---------
  1 | Apple    |  2 | Apple
  1 | Apple    |  1 | Apple
  1 | Apple    |  2 | Apple
  1 | Apple    |  1 | Apple
  2 | Orange   |  4 | Orange
  2 | Orange   |  3 | Orange
  3 | Banana   |    |
    | Cucumber |    |
  4 |          |    |
    |          |    |
(10 rows)
*/

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (fruit_a = fruit_b AND basket_a.id = basket_b.id);
-- Output=7, only 1:Apple are joined, the other 6 rows of basket_a added as part of left join

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (fruit_a = fruit_b OR basket_a.id = basket_b.id);
-- Output=11
/*
 id | fruit_a  | id | fruit_b
----+----------+----+---------
  1 | Apple    |  1 | Apple
  1 | Apple    |  2 | Apple
  1 | Apple    |  1 | Apple
  1 | Apple    |  2 | Apple
  2 | Orange   |  2 | Apple
  2 | Orange   |  3 | Orange
  2 | Orange   |  4 | Orange
  3 | Banana   |  3 | Orange
    | Cucumber |    |        - From left join
  4 |          |  4 | Orange
    |          |    |        - From left join
(11 rows)
*/



SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (basket_a.id < basket_b.id);
-- Output=21
/*
 id | fruit_a  | id |  fruit_b
----+----------+----+------------
  1 | Apple    |  2 | Apple
  1 | Apple    |  3 | Orange
  1 | Apple    |  4 | Orange
  1 | Apple    |  5 | Watermelon
  1 | Apple    |  6 |
  1 | Apple    |  2 | Apple
  1 | Apple    |  3 | Orange
  1 | Apple    |  4 | Orange
  1 | Apple    |  5 | Watermelon
  1 | Apple    |  6 |
  2 | Orange   |  3 | Orange
  2 | Orange   |  4 | Orange
  2 | Orange   |  5 | Watermelon
  2 | Orange   |  6 |
  3 | Banana   |  4 | Orange
  3 | Banana   |  5 | Watermelon
  3 | Banana   |  6 |
    | Cucumber |    |               -From left join
  4 |          |  5 | Watermelon
  4 |          |  6 |
    |          |    |               -From left join
(21 rows)
*/


-- A RIGHT JOIN B is equivalent to B LEFT JOIN A

SELECT count(*)
FROM basket_a
RIGHT JOIN basket_b USING (id);
-- Output=9
/*
 id | fruit_a |  fruit_b
----+---------+------------
  1 | Apple   | Apple
  1 | Apple   | Apple
  2 | Orange  | Apple
  3 | Banana  | Orange
  4 |         | Orange
  5 |         | Watermelon  -RIGHT
    |         | Pear        -RIGHT
  6 |         |             -RIGHT
    |         |             -RIGHT
(9 rows)
*/
-- A FULL JOIN is like a "right join plus a left join"

SELECT count(*)
FROM basket_a
FULL JOIN basket_b USING (id);
-- Output=11
/*
 id | fruit_a  |  fruit_b
----+----------+------------
  1 | Apple    | Apple
  1 | Apple    | Apple
  2 | Orange   | Apple
  3 | Banana   | Orange
    | Cucumber |            -LEFT
  4 |          | Orange
    |          |            -LEFT
    |          |            -RIGHT
    |          | Pear       -RIGHT
  5 |          | Watermelon -RIGHT
  6 |          |            -RIGHT
(11 rows)
*/

-- The LEFT, RIGHT, and FULL JOINs are all examples of OUTER JOINs.
-- The OUTER keyword can be added without changing the meaning.

SELECT count(*)
FROM basket_a
FULL OUTER JOIN basket_b USING (id);
-- Output=11
SELECT count(*)
FROM basket_a
LEFT OUTER JOIN basket_b USING (id);
-- Output=7
SELECT count(*)
FROM basket_a
RIGHT OUTER JOIN basket_b USING (id);
-- Output=9

-- The "natural" join is syntactic sugar over the USING clause:
-- it is equivalent to using the USING clause over all columns with the same name;
-- The natural join is not a separate type of join, and can be combined with INNER/LEFT/RIGHT joins

SELECT count(*) FROM basket_a NATURAL JOIN basket_b; -- 5
SELECT count(*) FROM basket_a NATURAL LEFT JOIN basket_b; -- 7
SELECT count(*) FROM basket_a NATURAL LEFT OUTER JOIN basket_b; -- 7
SELECT count(*) FROM basket_a NATURAL RIGHT JOIN basket_b; -- 9
SELECT count(*) FROM basket_a NATURAL RIGHT OUTER JOIN basket_b; -- 9
SELECT count(*) FROM basket_a NATURAL FULL JOIN basket_b; -- 11
SELECT count(*) FROM basket_a NATURAL FULL OUTER JOIN basket_b; -- 11

SELECT sum(DISTINCT id) FROM basket_a NATURAL RIGHT JOIN basket_b; -- 21, 1+2+3+4+5+6+7

-- outer joins can be chained together,
-- and the same table can be used multiple times

SELECT count(*)
FROM basket_a a1
LEFT JOIN basket_a a2 USING (id)
LEFT JOIN basket_a a3 USING (id);
/* 1:Apple gets duplicated each time
 id | fruit_a  | fruit_a | fruit_a
----+----------+---------+---------
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  2 | Orange   | Orange  | Orange
  3 | Banana   | Banana  | Banana
    | Cucumber |         |
  4 |          |         |
    |          |         |
(13 rows)
*/

SELECT count(*)
FROM basket_b b1
LEFT JOIN basket_b b2 USING (id)
LEFT JOIN basket_b b3 USING (id);
/*
 id |  fruit_b   |  fruit_b   |  fruit_b
----+------------+------------+------------
  1 | Apple      | Apple      | Apple
  2 | Apple      | Apple      | Apple
  3 | Orange     | Orange     | Orange
  4 | Orange     | Orange     | Orange
  5 | Watermelon | Watermelon | Watermelon
    | Pear       |            |
  6 |            |            |
    |            |            |
(8 rows)
*/

-- OUTER JOIN order is not commutative

SELECT count(*)
FROM basket_a a
LEFT JOIN basket_b b1 USING (id)
LEFT JOIN basket_b b2 USING (id);
/*
 id | fruit_a  | fruit_b | fruit_b
----+----------+---------+---------
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  2 | Orange   | Apple   | Apple
  3 | Banana   | Orange  | Orange
    | Cucumber |         |
  4 |          | Orange  | Orange
    |          |         |
(7 rows)
*/

SELECT count(*)
FROM basket_b b1
LEFT JOIN basket_a a USING (id)
LEFT JOIN basket_b b2 USING (id);
/*
 id |  fruit_b   | fruit_a |  fruit_b
----+------------+---------+------------
  1 | Apple      | Apple   | Apple
  1 | Apple      | Apple   | Apple
  2 | Apple      | Orange  | Apple
  3 | Orange     | Banana  | Orange
  4 | Orange     |         | Orange
  5 | Watermelon |         | Watermelon
    | Pear       |         |
  6 |            |         |
    |            |         |
(9 rows)
*/


SELECT count(*)
FROM basket_b b1
LEFT JOIN basket_b b2 USING (id)
LEFT JOIN basket_a a USING (id);
/*
 id |  fruit_b   |  fruit_b   | fruit_a
----+------------+------------+---------
  1 | Apple      | Apple      | Apple
  1 | Apple      | Apple      | Apple
  2 | Apple      | Apple      | Orange
  3 | Orange     | Orange     | Banana
  4 | Orange     | Orange     |
  5 | Watermelon | Watermelon |
    | Pear       |            |
  6 |            |            |
    |            |            |
(9 rows)
*/


-- when an outer join is combined with any other type of join,
-- then the joins are no longer associative

SELECT count(*) FROM basket_b b1 LEFT JOIN basket_a a USING (id) JOIN basket_b b2 USING (id); -- 7
SELECT count(*) FROM (basket_b b1 LEFT JOIN basket_a a USING (id)) JOIN basket_b b2 USING (id); -- 7
SELECT count(*) FROM basket_b b1 LEFT JOIN (basket_a a JOIN basket_b b2 USING (id)) USING (id); -- 9

-- As discussed above, every LEFT/RIGHT JOIN can be written in terms of a subquery;
-- subqueries are strictly more powerful, however;
-- if a subquery contains an aggregate function, then it cannot be re-written as a join

SELECT count(*) FROM (
    SELECT sum(id) FROM basket_a
    UNION
    SELECT sum(id) FROM basket_b
) t;

/*
 sum
-----
  11
  21
(2 rows)
*/
SELECT count(*) FROM (
    SELECT sum(DISTINCT id) FROM basket_a
    UNION
    SELECT sum(id) FROM basket_b WHERE id < 5
) t;
/* Both subqueries output 10, so UNION combines them
 * Output=1
 sum
-----
  10
(1 row)
*/

SELECT count(*) FROM (
    SELECT count(id) FROM basket_a
    UNION
    SELECT id FROM basket_b
) t;

/* Output=7
 count
-------

     5
     4
     6
     2
     1
     3
(7 rows)
*/


SELECT count(*)
FROM basket_a
WHERE id NOT IN (SELECT sum(id) FROM basket_b WHERE fruit_b ILIKE '%a%');

/*
 * Equiv to
 * SELECT count(*)
FROM basket_a
WHERE id NOT IN (15);
 id | fruit_a
----+---------
  1 | Apple
  1 | Apple
  2 | Orange
  3 | Banana
  4 |
(5 rows)
*/

SELECT count(*)
FROM basket_b
WHERE id IN (SELECT count(id) FROM basket_b WHERE fruit_b ILIKE '%a%');
-- Output=1
/*
 * Equiv to SELECT count(*)                                              FROM basket_b
WHERE id IN (5);
*/


SELECT count(*)
FROM basket_b
WHERE id IN (SELECT count(id) FROM basket_a WHERE id < 5);
-- Output=5
/*
 * Equiv to
 * SELECT count(*)
FROM basket_b
WHERE id IN (5);
*/


-- subqueries can be combined with JOINs

SELECT count(*)
FROM basket_b
WHERE id IN (
    SELECT count(id)
    FROM basket_a
    JOIN basket_b USING (id)
    WHERE id < 5
);
-- Output=1
/* Equiv to
 * SELECT count(*)
FROM basket_b
WHERE id IN (5);
*/


SELECT count(*)
FROM basket_b, basket_a
WHERE basket_b.id IN (
    SELECT count(id)
    FROM basket_a
    JOIN basket_b USING (id)
    WHERE id < 5
);
-- Output=7 
/* Selects all cross joins with id=5
 id |  fruit_b   | id | fruit_a
----+------------+----+----------
  5 | Watermelon |  1 | Apple
  5 | Watermelon |  1 | Apple
  5 | Watermelon |  2 | Orange
  5 | Watermelon |  3 | Banana
  5 | Watermelon |    | Cucumber
  5 | Watermelon |  4 |
  5 | Watermelon |    |
(7 rows)
*/
SELECT count(*)
FROM basket_b
LEFT JOIN basket_a USING (id)
WHERE basket_b.id IN (
    SELECT count(id)
    FROM basket_a
    JOIN basket_b USING (id)
    WHERE id < 5
);
-- Output=1
-- Select all left joins entries with id=5

SELECT count(*)
FROM basket_b
RIGHT JOIN basket_a USING (id)
WHERE basket_b.id IN (
    SELECT count(id)
    FROM basket_a
    JOIN basket_b USING (id)
    WHERE id < 5
);
-- Output=0
-- Selects all right join entries with id=5, which none exist

SELECT count(*)
FROM basket_b
RIGHT JOIN basket_a USING (id)
WHERE basket_b.id IN (SELECT id FROM basket_a WHERE id < 5);
-- Output=5
-- RIGHT JOIN b, a ON id WHERE b.id IN (1,1,2,3,4)
/*
 id | fruit_b | fruit_a
----+---------+---------
  1 | Apple   | Apple
  1 | Apple   | Apple
  2 | Apple   | Orange
  3 | Orange  | Banana
  4 | Orange  |
(5 rows)
*/
SELECT count(*)
FROM basket_b
LEFT JOIN basket_a USING (id)
WHERE basket_b.id IN (SELECT id FROM basket_a WHERE id < 5);
-- Output=5
-- LEFT JOIN b, a ON id WHERE b.id IN (1,1,2,3,4)
/*
 id | fruit_b | fruit_a
----+---------+---------
  1 | Apple   | Apple
  1 | Apple   | Apple
  2 | Apple   | Orange
  3 | Orange  | Banana
  4 | Orange  |
(5 rows)
*/
SELECT count(*)
FROM basket_b
LEFT JOIN basket_a ON (fruit_a = fruit_b)
WHERE basket_b.id IN (SELECT id FROM basket_a WHERE id < 5);
/*
 id | fruit_b | id | fruit_a
----+---------+----+---------
  2 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple
  2 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple
  4 | Orange  |  2 | Orange
  3 | Orange  |  2 | Orange
(6 rows)
*/


SELECT count(*)
FROM basket_b
RIGHT JOIN basket_a ON (fruit_a = fruit_b)
WHERE basket_b.id IN (SELECT id FROM basket_a WHERE id < 5);
/*
 id | fruit_b | id | fruit_a
----+---------+----+---------
  2 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple
  2 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple
  4 | Orange  |  2 | Orange
  3 | Orange  |  2 | Orange
(6 rows)
*/
