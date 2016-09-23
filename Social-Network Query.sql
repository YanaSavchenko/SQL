/* Delete the tables if they already exist */
if OBJECT_ID('Highschooler', 'U') is not null drop table Highschooler;
if OBJECT_ID('Friend', 'U') is not null drop table Friend;
if OBJECT_ID('Likes', 'U') is not null drop table Likes;

/* Create the schema for our tables */
create table Highschooler(ID int, name varchar(100), grade int);
create table Friend(ID1 int, ID2 int);
create table Likes(ID1 int, ID2 int);

/* Populate the tables with our data */
insert into Highschooler values (1510, 'Jordan', 9);
insert into Highschooler values (1689, 'Gabriel', 9);
insert into Highschooler values (1381, 'Tiffany', 9);
insert into Highschooler values (1709, 'Cassandra', 9);
insert into Highschooler values (1101, 'Haley', 10);
insert into Highschooler values (1782, 'Andrew', 10);
insert into Highschooler values (1468, 'Kris', 10);
insert into Highschooler values (1641, 'Brittany', 10);
insert into Highschooler values (1247, 'Alexis', 11);
insert into Highschooler values (1316, 'Austin', 11);
insert into Highschooler values (1911, 'Gabriel', 11);
insert into Highschooler values (1501, 'Jessica', 11);
insert into Highschooler values (1304, 'Jordan', 12);
insert into Highschooler values (1025, 'John', 12);
insert into Highschooler values (1934, 'Kyle', 12);
insert into Highschooler values (1661, 'Logan', 12);

insert into Friend values (1510, 1381);
insert into Friend values (1510, 1689);
insert into Friend values (1689, 1709);
insert into Friend values (1381, 1247);
insert into Friend values (1709, 1247);
insert into Friend values (1689, 1782);
insert into Friend values (1782, 1468);
insert into Friend values (1782, 1316);
insert into Friend values (1782, 1304);
insert into Friend values (1468, 1101);
insert into Friend values (1468, 1641);
insert into Friend values (1101, 1641);
insert into Friend values (1247, 1911);
insert into Friend values (1247, 1501);
insert into Friend values (1911, 1501);
insert into Friend values (1501, 1934);
insert into Friend values (1316, 1934);
insert into Friend values (1934, 1304);
insert into Friend values (1304, 1661);
insert into Friend values (1661, 1025);
insert into Friend select ID2, ID1 from Friend;

insert into Likes values(1689, 1709);
insert into Likes values(1709, 1689);
insert into Likes values(1782, 1709);
insert into Likes values(1911, 1247);
insert into Likes values(1247, 1468);
insert into Likes values(1641, 1468);
insert into Likes values(1316, 1304);
insert into Likes values(1501, 1934);
insert into Likes values(1934, 1501);
insert into Likes values(1025, 1101);

/* Q1 - Find the names of all students who are friends with someone named Gabriel */
select h.name
from Friend as f
inner join
Highschooler as h
on f.ID1 = h.ID
where f.ID2 in (
    select ID
    from Highschooler
    where name = 'Gabriel'
);

/* Q2 - For every student who likes someone 2 or more grades younger than themselves, 
return that student's name and grade, and the name and grade of the student they like */
select h1.name, 
	h1.grade, 
	h2.name,
	h2.grade
from Highschooler as h1,
    Highschooler as h2,
    Likes as l
where h1.ID = l.ID1 
    and h2.ID = l.ID2
    and h1.grade - h2.grade >= 2

/* Q3 - For every pair of students who both like each other, return the name and grade of both students. 
Include each pair only once, with the two names in alphabetical order */
select h1.name, 
	h1.grade, 
	h2.name, 
	h2.grade
from Likes as l1,
    Likes as l2,
    Highschooler as h1,
    Highschooler as h2
where l1.ID1 = l2.ID2 
    and l1.ID2 = l2.ID1
    and h1.ID = l1.ID1
    and h2.ID = l1.ID2
    and h1.name < h2.name

/* Q4 -Find all students who do not appear in the Likes table (as a student who likes or is liked) 
and return their names and grades. Sort by grade, then by name within each grade */
select name, 
	grade
from Highschooler
where ID not in (
    select ID1 
    from Likes
    union
    select ID2
    from Likes
)
order by grade, name

/* Q5 - For every situation where student A likes student B, but we have no information about whom B likes 
(that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades */
select h1.name, 
	h1.grade, 
	h2.name,
	h2.grade
from Highschooler as h1,
    Highschooler as h2,
    Likes as l
where h1.ID = l.ID1
    and h2.ID = l.ID2
    and h2.ID not in (
        select ID1
        from Likes
    )

/* Q6 - Find names and grades of students who only have friends in the same grade. 
Return the result sorted by grade, then by name within each grade */
select name, 
	grade
from Highschooler
where ID not in (
    select h1.ID
    from Highschooler as h1,
        Highschooler as h2,
        Friend as f
    where h1.ID = f.ID1
        and h2.ID = f.ID2
        and h1.grade <> h2.grade
)
order by grade, name

/* Q7 - For each student A who likes a student B where the two are not friends, 
find if they have a friend C in common (who can introduce them!). 
For all such trios, return the name and grade of A, B, and C */
select distinct h1.name, 
	h1.grade, 
	h2.name, 
	h2.grade, 
	h3.name, 
	h3.grade
from Highschooler as h1, 
	Highschooler as h2, 
	Highschooler as h3, 
	Likes as l, 
	Friend as f1, 
	Friend as f2
where h1.ID = l.ID1 
	and l.ID2 = h2.ID 
	and h2.ID not in (
		select ID2 
		from Friend 
		where ID1 = h1.ID
	) 
	and h1.ID = f1.ID1 
	and f1.ID2 = h3.ID 
	and h3.ID = f2.ID1 
	and f2.ID2 = h2.ID;

/* Q8 - Find the difference between the number of students in the school and the number of different first names */
select (t1.total - count(t2.name)) as difference 
from (
    select distinct count(ID) as 'total'
    from Highschooler
) as t1,
(
    select distinct name
    from Highschooler
) as t2

/* Q9 - Find the name and grade of all students who are liked by more than one other student */
select h.name, 
	h.grade
from Likes as l,
    Highschooler as h
where h.ID = l.ID2
group by l.ID2
having count(*) > 1
