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

/* Q1 - For every situation where student A likes student B, but student B likes 
a different student C, return the names and grades of A, B, and C */
select h1.name, 
	h1.grade, 
	h2.name, 
	h2.grade, 
	h3.name, 
	h3.grade
from Highschooler as h1,
    Highschooler as h2,
    Highschooler as h3,
    Likes as l1,
    Likes as l2
where h1.ID = l1.ID1
    and h2.ID = l1.ID2
    and h1.ID not in (select ID2 from Likes)
    and h2.ID = l2.ID1
    and h3.ID = l2.ID2

/* Q2 - Find those students for whom all of their friends are in different grades from 
themselves. Return the students' names and grades */
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
        and h1.grade = h2.grade
)

/* Q3 - What is the average number of friends per student? (Your result should be just one number.) */
select avg(t1.total) as avg 
from (
    select ID1, count(ID1) as 'total'
    from Friend
    group by ID1
) as t1

/* Q4 - Find the number of students who are either friends with Cassandra or are friends of 
friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend */
select count(ID2) as 'total' 
from Friend 
where ID1 in (
    select ID2 
    from Friend 
    where ID1 in (
        select ID 
        from Highschooler 
        where name = 'Cassandra'
    )
) and ID1 not in (
    select ID 
    from Highschooler 
    where name = 'Cassandra'
)

/* Q5 - Find the name and grade of the student(s) with the greatest number of friends */
select name, 
	grade
from Highschooler
where ID in (
    select ID1
    from (
        select ID1, count(ID1) as 'total'
        from Friend
        group by ID1
    ) as t1
    where total = ( 
        select max(total)
        from (
            select ID1, count(ID1) as 'total'
            from Friend
            group by ID1
        ) as t2  
    )
)
