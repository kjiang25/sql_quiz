/* This set of notes explains the behavior of outer joins.
 * It uses a simplified version of the `create_tables.sql` data to make visualization easier.
 * For your quiz, you will still need to work with the full version of the data.
 *
 * COMMON SOURCES OF ERRORS
 *  - behavior when there are duplicate rows
 *  - behavior of NULL values
 */

CREATE TABLE basket_a (id INTEGER, fruit_a TEXT);
INSERT INTO basket_a (id, fruit_a) VALUES
    (1, 'Apple'),
    (1, 'Apple'),
    (2, 'Orange'),
 -- (3, 'Banana'),
    (NULL, 'Cucumber')
 -- (4, NULL),
 -- (NULL, NULL)
    ;

CREATE TABLE basket_b (id INTEGER, fruit_b TEXT);
INSERT INTO basket_b (id, fruit_b) VALUES
    (1, 'Apple'),
    (2, 'Apple'),
 -- (3, 'Orange'),
 -- (4, 'Orange'),
 -- (5, 'Watermelon'),
    (NULL, 'Pear');
 -- (6, NULL),
 -- (NULL, NULL)


SELECT * FROM basket_b, basket_a;
/*
  | id | fruit_b | id | fruit_a  |
  |----|---------|----|----------|
  | 1  | Apple   | 1  | Apple    |
  | 1  | Apple   | 1  | Apple    |
  | 1  | Apple   | 2  | Orange   |
  | 1  | Apple   |    | Cucumber |
  | 2  | Apple   | 1  | Apple    |
  | 2  | Apple   | 1  | Apple    |
  | 2  | Apple   | 2  | Orange   |
  | 2  | Apple   |    | Cucumber |
  |    | Pear    | 1  | Apple    |
  |    | Pear    | 1  | Apple    |
  |    | Pear    | 2  | Orange   |
  |    | Pear    |    | Cucumber |
*/

SELECT * FROM basket_b JOIN basket_a;
/*
  | id | fruit_b | id | fruit_a  |
  |----|---------|----|----------|
  | 1  | Apple   | 1  | Apple    |
  | 1  | Apple   | 1  | Apple    |
  | 1  | Apple   | 2  | Orange   |
  | 1  | Apple   |    | Cucumber |
  | 2  | Apple   | 1  | Apple    |
  | 2  | Apple   | 1  | Apple    |
  | 2  | Apple   | 2  | Orange   |
  | 2  | Apple   |    | Cucumber |
  |    | Pear    | 1  | Apple    |
  |    | Pear    | 1  | Apple    |
  |    | Pear    | 2  | Orange   |
  |    | Pear    |    | Cucumber |
*/

----------------------------------------
-- EXAMPLE: JOIN on id
----------------------------------------

SELECT * FROM basket_b JOIN basket_a ON basket_b.id = basket_a.id;
/*
  | id | fruit_b | id | fruit_a  |
  |----|---------|----|----------|
  | 1  | Apple   | 1  | Apple    |
  | 1  | Apple   | 1  | Apple    |
- | 1  | Apple   | 2  | Orange   |
- | 1  | Apple   |    | Cucumber |
- | 2  | Apple   | 1  | Apple    |
- | 2  | Apple   | 1  | Apple    |
  | 2  | Apple   | 2  | Orange   |
- | 2  | Apple   |    | Cucumber |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 2  | Orange   |
- |    | Pear    |    | Cucumber |
*/

-- Conditions do not affect Outer join, whatever rows from a not in b will get added to output, even NULL values
SELECT * FROM basket_b LEFT JOIN basket_a ON basket_b.id = basket_a.id;
/*
  | id | fruit_b | id | fruit_a  |
  |----|---------|----|----------|
  | 1  | Apple   | 1  | Apple    |
  | 1  | Apple   | 1  | Apple    |
- | 1  | Apple   | 2  | Orange   |
- | 1  | Apple   |    | Cucumber |
- | 2  | Apple   | 1  | Apple    |
- | 2  | Apple   | 1  | Apple    |
  | 2  | Apple   | 2  | Orange   |
- | 2  | Apple   |    | Cucumber |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 2  | Orange   |
- |    | Pear    |    | Cucumber |
+ |    | Pear    |    |          |
*/

/*
 * SELECT * FROM basket_a LEFT JOIN basket_b ON basket_a.id = basket_b.id;
 */

SELECT * FROM basket_b RIGHT JOIN basket_a ON basket_b.id = basket_a.id;
/*
  | id | fruit_b | id | fruit_a  |
  |----|---------|----|----------|
  | 1  | Apple   | 1  | Apple    |
  | 1  | Apple   | 1  | Apple    |
- | 1  | Apple   | 2  | Orange   |
- | 1  | Apple   |    | Cucumber |
- | 2  | Apple   | 1  | Apple    |
- | 2  | Apple   | 1  | Apple    |
  | 2  | Apple   | 2  | Orange   |
- | 2  | Apple   |    | Cucumber |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 2  | Orange   |
- |    | Pear    |    | Cucumber |
+ |    |         |    | Cucumber |
*/

----------------------------------------
-- EXAMPLE: JOIN on fruit
----------------------------------------

SELECT * FROM basket_b JOIN basket_a ON basket_b.fruit_b = basket_a.fruit_a;
/*
  | id | fruit_b | id | fruit_a  |
  |----|---------|----|----------|
  | 1  | Apple   | 1  | Apple    |
  | 1  | Apple   | 1  | Apple    |
- | 1  | Apple   | 2  | Orange   |
- | 1  | Apple   |    | Cucumber |
  | 2  | Apple   | 1  | Apple    |
  | 2  | Apple   | 1  | Apple    |
- | 2  | Apple   | 2  | Orange   |
- | 2  | Apple   |    | Cucumber |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 2  | Orange   |
- |    | Pear    |    | Cucumber |
*/

SELECT * FROM basket_b LEFT JOIN basket_a ON basket_b.fruit_b = basket_a.fruit_a;
/*
  | id | fruit_b | id | fruit_a  |
  |----|---------|----|----------|
  | 1  | Apple   | 1  | Apple    |
  | 1  | Apple   | 1  | Apple    |
- | 1  | Apple   | 2  | Orange   |
- | 1  | Apple   |    | Cucumber |
  | 2  | Apple   | 1  | Apple    |
  | 2  | Apple   | 1  | Apple    |
- | 2  | Apple   | 2  | Orange   |
- | 2  | Apple   |    | Cucumber |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 2  | Orange   |
- |    | Pear    |    | Cucumber |
+ |    | Pear    |    |          |
*/

SELECT * FROM basket_b RIGHT JOIN basket_a ON basket_b.fruit_b = basket_a.fruit_a;
/*
  | id | fruit_b | id | fruit_a  |
  |----|---------|----|----------|
  | 1  | Apple   | 1  | Apple    |
  | 1  | Apple   | 1  | Apple    |
- | 1  | Apple   | 2  | Orange   |
- | 1  | Apple   |    | Cucumber |
  | 2  | Apple   | 1  | Apple    |
  | 2  | Apple   | 1  | Apple    |
- | 2  | Apple   | 2  | Orange   |
- | 2  | Apple   |    | Cucumber |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 2  | Orange   |
- |    | Pear    |    | Cucumber |
+ |    |         | 2  | Orange   |
+ |    |         |    | Cucumber |
*/

SELECT * FROM basket_b FULL JOIN basket_a ON basket_b.fruit_b = basket_a.fruit_a;
/*
  | id | fruit_b | id | fruit_a  |
  |----|---------|----|----------|
  | 1  | Apple   | 1  | Apple    |
  | 1  | Apple   | 1  | Apple    |
- | 1  | Apple   | 2  | Orange   |
- | 1  | Apple   |    | Cucumber |
  | 2  | Apple   | 1  | Apple    |
  | 2  | Apple   | 1  | Apple    |
- | 2  | Apple   | 2  | Orange   |
- | 2  | Apple   |    | Cucumber |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 2  | Orange   |
- |    | Pear    |    | Cucumber |
+ |    | Pear    |    |          |    -- LEFT
+ |    |         | 2  | Orange   |    -- RIGHT
+ |    |         |    | Cucumber |    -- RIGHT
*/

----------------------------------------
-- intuition:
-- LEFT/RIGHT JOIN + IS NULL "like" WHERE NOT IN + subquery
----------------------------------------

SELECT basket_a.* FROM basket_b RIGHT JOIN basket_a ON basket_b.fruit_b = basket_a.fruit_a
WHERE fruit_b IS NULL;

/*
| id | fruit_a  |
|----|----------|
| 2  | Orange   |
|    | Cucumber |
*/

SELECT * FROM basket_a
WHERE fruit_a NOT IN (SELECT fruit_b FROM basket_b);

/*
| id | fruit_a  |
|----|----------|
| 2  | Orange   |
|    | Cucumber |
*/

-- the intuition will be violated when there are NULL values in columns

SELECT basket_b.* 
FROM basket_b 
LEFT JOIN basket_a ON basket_b.id = basket_a.id
WHERE fruit_a IS NULL;

/*
| id | fruit_b |
|----|---------|
|    | Pear    | 
*/

SELECT * 
FROM basket_b
WHERE id NOT IN (SELECT id FROM basket_a);

/*
This query returns no rows. Why? Look at the subquery:

SELECT id FROM basket_a
| id |
|----|
| 1  |
| 1  |
| 2  |
|    | <-- NULL

So the expression

WHERE id NOT IN (SELECT id FROM basket_a);

is equivalent to

WHERE id != 1 AND id != 1 AND id != 2 AND id != NULL

which always evaluates to NULL.

----------

This problem is not easy to fix by modifying the subquery.  For example, 

SELECT * FROM basket_b
WHERE id NOT IN (SELECT id FROM basket_a WHERE id IS NOT NULL);

still does not work.

----------

TAKE AWAY POINT:
If you actually want to capture rows in one table, but not in another table,
then you should probably use a LEFT/RIGHT JOIN.
The NOT IN + subquery pattern is a "code smell" and likely cause for bugs.
*/

----------------------------------------
-- EXAMPLE: "complex" join clauses
----------------------------------------

SELECT * FROM basket_b FULL JOIN basket_a ON basket_b.id > basket_a.id;
/*
  | id | fruit_b | id | fruit_a  |
  |----|---------|----|----------|
- | 1  | Apple   | 1  | Apple    |
- | 1  | Apple   | 1  | Apple    |
- | 1  | Apple   | 2  | Orange   |
- | 1  | Apple   |    | Cucumber |
  | 2  | Apple   | 1  | Apple    |
  | 2  | Apple   | 1  | Apple    |
- | 2  | Apple   | 2  | Orange   |
- | 2  | Apple   |    | Cucumber |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 1  | Apple    |
- |    | Pear    | 2  | Orange   |
- |    | Pear    |    | Cucumber |
+ | 1  | Apple   |    |          |    -- LEFT
+ |    | Pear    |    |          |    -- LEFT
+ |    |         | 2  | Orange   |    -- RIGHT
+ |    |         |    | Cucumber |    -- RIGHT
*/
