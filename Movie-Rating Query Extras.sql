/* Delete the tables if they already exist */
if OBJECT_ID('Movie', 'U') is not null drop table Movie;
if OBJECT_ID('Reviewer', 'U') is not null drop table Reviewer;
if OBJECT_ID('Rating', 'U') is not null drop table Rating;

/* Create the schema for our tables */
create table Movie(mID int, title varchar(100), year int, director varchar(100));
create table Reviewer(rID int, name varchar(100));
create table Rating(rID int, mID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');

insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');

/* Q1 - Find the names of all reviewers who rated Gone with the Wind */
select distinct rw.name 
from Movie as m, 
	Reviewer as rw, 
	Rating as r
where m.title = 'Gone with the Wind' and
	m.mID = r.mID and
	rw.rID = r.rID; 


/* Q2 - For any rating where the reviewer is the same as the director of the movie, 
return the reviewer name, movie title, and number of stars */
select rw.name, m.title, r.stars 
from Movie as m, 
	Reviewer as rw, 
	Rating as r
where rw.rID = r.rID and
	m.mID = r.mID and
	m.director = rw.name;	


/* Q3 - Return all reviewer names and movie names together in a single list, 
alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine;
no need for special processing on last names or removing "The".)  */
select name
from Reviewer
union
select title
from Movie
order by name; 


/* Q4 - Find the titles of all movies not reviewed by Chris Jackson  */
select title
from Movie
where mID not in (
	select r.mID
	from Rating as r
	inner join
	Reviewer as rw
	on r.rid = rw.rID
	where rw.name = 'Chris Jackson'
);


/* Q5 - For all pairs of reviewers such that both reviewers gave a rating to the same movie, 
return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, 
and include each pair only once. For each pair, return the names in the pair in alphabetical order */
select distinct rw1.name, rw2.name 
from Reviewer as rw1, 
	Reviewer as rw2, 
	Rating as r1,
	Rating as r2
where r1.mID = r2.mID and
	r1.rID <> r2.rID and
	r1.rID = rw1.rID and
	r2.rID = rw2.rID and
	rw1.name < rw2.name; 


/* Q6 - For each rating that is the lowest (fewest stars) currently in the database, 
return the reviewer name, movie title, and number of stars */
select distinct rw.name, m.title, r.stars
from Movie as m,
	Reviewer as rw,
	Rating as r
where r.stars = (
	select min(stars)
	from Rating ) and 
	m.mID = r.mID and
	rw.rID = r.rID; 


/* Q7 - List movie titles and average ratings, from highest-rated to lowest-rated. 
If two or more movies have the same average rating, list them in alphabetical order  */
select m.title, avg(r.stars) as 'Avg stars'
from Movie as m
inner join
Rating as r
on m.mID = r.mID
group by title
order by [Avg stars] desc, title


/* Q8 - Find the names of all reviewers who have contributed three or more ratings */
select rw.name
from Reviewer as rw
inner join
(
select rID, count(rID) as rating 
from Rating
group by rID
) as r
on rw.rID = r.rID
where r.rating >= 3; 


/* Q9 - Some directors directed more than one movie. For all such directors, 
return the titles of all movies directed by them, along with the director name. 
Sort by director name, then movie title  */
select m.title, m.director
from Movie as m,
	(
		select director, count(title) as 'Number of movies'
		from Movie
		group by director
		having count(title) > 1
	) as t
where m.director = t.director
order by director, title;


/* Q10 - Find the movie(s) with the highest average rating. 
Return the movie title(s) and average rating */
select m.title, r.stars
from Movie as m
inner join
(
	select mID, avg(stars) as stars
	from Rating
	group by mID
) as r
on m.mID = r.mID
where stars = (
	select max(stars)
	from (
		select mID, avg(stars) as stars
		from Rating
		group by mID
 	) as t
); 


/* Q11 - Find the movie(s) with the lowest average rating. 
Return the movie title(s) and average rating  */
select m.title, r.stars
from Movie as m
inner join
(
	select mID, avg(stars) as stars
	from Rating
	group by mID
) as r
on m.mID = r.mID
where stars = (
	select min(stars)
	from (
		select mID, avg(stars) as stars
		from Rating
		group by mID
 	) as t
);


/* Q12 - For each director, return the director's name together with the title(s) 
of the movie(s) they directed that received the highest rating among all of their movies,
and the value of that rating. Ignore movies whose director is NULL */
select director, title, max(stars) as max_star
from Movie as m
inner join
Rating as r
on m.mID = r.mID
where director is not NULL
group by director;
