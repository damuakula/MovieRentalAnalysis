Use Sakila;

# 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(ucase(first_name), ' ', ucase(last_name)) AS "Actor Name" FROM actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, 
   "Joe." What is one query would you use to obtain this information? */
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

# 2b. Find all actors whose last name contain the letters GEN.
SELECT * FROM actor WHERE last_name LIKE '%GEN%';

/* 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, 
   in that order. */
SELECT actor_id, last_name, first_name, last_update FROM actor WHERE last_name LIKE '%LI%' order by last_name, first_name;

# 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China.
SELECT country_id, country
FROM country
WHERE country in ("Afghanistan", "Bangladesh", "China");

/* 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create 
   a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the 
   difference between it and VARCHAR are significant). */
ALTER TABLE actor ADD COLUMN description BLOB;

# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP COLUMN description;

# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS actors_with_this_lastname
FROM actor
GROUP BY last_name;

/* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at 
   least two actors */
SELECT last_name, COUNT(last_name) AS actors_with_this_lastname
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 2;

# 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT * FROM actor
WHERE first_name = "GROUCHO"
AND last_name = "WILLIAMS";

UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO"
AND last_name = "WILLIAMS";

/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a 
   single query, if the first name of the actor is currently HARPO, change it to GROUCHO. */
SELECT * FROM actor
WHERE first_name = "HARPO"
AND last_name = "WILLIAMS";

UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO"
AND last_name = "WILLIAMS";

# 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

# 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address.
SELECT s.first_name, s.last_name, a.address
FROM address a
INNER JOIN staff s
ON a.address_id = s.address_id;

# 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.staff_id AS "Staff Member", SUM(p.amount) AS "Total Amount"
FROM staff s
INNER JOIN (SELECT staff_id, amount
			FROM payment
            WHERE MONTH(payment_date) = 8 AND YEAR(payment_date) = 2005) p
ON s.staff_id = p.staff_id
GROUP BY s.staff_id;

# 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title as Title, COUNT(fa.actor_id) AS "Number of Actors"
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY f.title;

# 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inv.inventory_id) AS "Copies of Hunchback Impossible"
FROM film f
INNER JOIN inventory inv
ON f.film_id = inv.film_id
WHERE f.title = "Hunchback Impossible";

/* 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers 
   alphabetically by last name */
SELECT c.first_name AS "First Name", c.last_name AS "Last Name", SUM(p.amount) AS "Total Paid"
FROM customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

/* The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting 
    with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the
    letters K and Q whose language is English. */
SELECT a.title
FROM (SELECT title, language_id
      FROM film
      WHERE title like 'K%'
      OR title like 'Q%') a
INNER JOIN language l
ON a.language_id = l.language_id
WHERE l.name = "English";

#Use subqueries to display all actors who appear in the film Alone Trip.
SELECT CONCAT(a.first_name, ' ' ,a.last_name) AS "Actor Name"
FROM (SELECT ac.first_name, ac.last_name, ac.actor_id, fa.film_id
      FROM actor ac
      INNER JOIN film_actor fa
      ON ac.actor_id = fa.actor_id
      ) a
INNER JOIN film b
ON a.film_id = b.film_id
WHERE b.title = "Alone Trip";

/* You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all 
   Canadian customers. Use joins to retrieve this information. */
SELECT CONCAT(a.first_name, ' ' ,a.last_name) AS "Customer Name", a.email
FROM (SELECT c.first_name, c.last_name, c.email, adr.address_id, adr.city_id
      FROM customer c
      INNER JOIN address adr
      ON c.address_id = adr.address_id
      ) a
INNER JOIN city cy
ON a.city_id = cy.city_id
WHERE cy.country_id = (SELECT country_id FROM country where country = "Canada");

/* Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify 
   all movies categorized as family films. */
SELECT a.title
FROM (SELECT fl.film_id, fl.title, fc.category_id
	  FROM film fl
      INNER JOIN film_category fc
      ON fl.film_id = fc.film_id
      ) a
INNER JOIN category cat
ON a.category_id = cat.category_id
WHERE cat.name = "Family";

#Display the most frequently rented movies in descending order.
SELECT title AS Title, freq.FREQCNT AS Frequency
FROM film fl
INNER JOIN (SELECT film_id, COUNT(rental_date) as FREQCNT
FROM rental rntl
INNER JOIN inventory inv
ON rntl.inventory_id = inv.inventory_id
GROUP BY film_id) freq
ON fl.film_id = freq.film_id
ORDER BY Frequency DESC;

#Write a query to display how much business, in dollars, each store brought in.
SELECT a.store_id, SUM(a.amount)
FROM (SELECT pmt.amount, st.store_id
      FROM payment pmt
      INNER JOIN staff st
      ON pmt.staff_id = st.staff_id
      ) a
GROUP BY a.store_id;

#Write a query to display for each store its store ID, city, and country.
SELECT a.store_id, cy.city, cy.country
FROM (SELECT s.store_id, adr.address_id, adr.city_id
      FROM store s
      INNER JOIN address adr
      ON s.address_id = adr.address_id
      ) a
INNER JOIN (SELECT co.country, ct.city_id, ct.city
			FROM country co
            INNER JOIN city ct
            ON co.country_id = ct.country_id
            ) cy
ON a.city_id = cy.city_id;

/* List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: 
   category, film_category, inventory, payment, and rental.) */
SELECT cat.name as Genre, sum(pmnt.amount) AS "Gross Revenue"
FROM category cat
INNER JOIN (SELECT inv.inventory_id, fc.category_id
            FROM inventory inv
            INNER JOIN film_category fc
            ON inv.film_id = fc.film_id) filmcat
ON cat.category_id = filmcat.category_id
INNER JOIN (SELECT xmnt.amount, rntl.inventory_id
            FROM payment xmnt
            INNER JOIN rental rntl
            ON xmnt.rental_id = rntl.rental_id) pmnt
ON filmcat.inventory_id = pmnt.inventory_id
GROUP BY cat.name
ORDER BY sum(pmnt.amount) DESC
LIMIT 5;

/* In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
   Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query 
   to create a view.*/
CREATE VIEW `vw_top_five_genres` AS
SELECT cat.name as Genre, sum(pmnt.amount) AS "Gross Revenue"
FROM category cat
INNER JOIN (SELECT inv.inventory_id, fc.category_id
            FROM inventory inv
            INNER JOIN film_category fc
            ON inv.film_id = fc.film_id) filmcat
ON cat.category_id = filmcat.category_id
INNER JOIN (SELECT xmnt.amount, rntl.inventory_id
            FROM payment xmnt
            INNER JOIN rental rntl
            ON xmnt.rental_id = rntl.rental_id) pmnt
ON filmcat.inventory_id = pmnt.inventory_id
GROUP BY cat.name
ORDER BY sum(pmnt.amount) DESC
LIMIT 5;

#How would you display the view that you just created for Top five genres?
SELECT * FROM vw_top_five_genres;

#You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW vw_top_five_genres;



