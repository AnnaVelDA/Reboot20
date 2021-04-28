--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing

--task1
--Корабли: Для каждого класса определите число кораблей этого класса, потопленных в сражениях. 
Вывести: класс и число потопленных кораблей.
select t1.class, count(t1.name)
from 
(
select name, class 
from ships s 

union

select o.ship as name, s.class
from outcomes o 
join ships s
on s.name=o.ship 
where o.result = 'sunk'
) t1
group by t1.class


--task2
--Корабли: Для каждого класса определите год, когда был спущен на воду первый корабль этого класса.
 Если год спуска на воду головного корабля неизвестен, определите минимальный год спуска на воду
 кораблей этого класса. Вывести: класс, год.

select class, min(launched) 
from ships s
group by "class" 
 
select *
from ships s 
where launched is null 

--task3
--Корабли: Для классов, имеющих потери в виде потопленных кораблей и не менее 3 кораблей в базе данных, 
вывести имя класса и число потопленных кораблей.

select class, count(name)
from ships s 
join outcomes o 
on s.name = o.ship 
where result = 'sunk'
ad class in (
	select class 
	from (
		select class, count(name) as cnt
		from ships s
		group by class
	) t2
	where t2.cnt >= 3
)
group by class

--task4
--Корабли: Найдите названия кораблей, имеющих наибольшее число орудий среди всех кораблей
 такого же водоизмещения (учесть корабли из таблицы Outcomes).
 

select name
from ships s 
where class = any(
	select class from (
		select class, max(numguns), displacement
 		from classes c 
 		group by class, displacement
 	) t1
)
and name = any(select ship
 from outcomes)


--task5
--Компьютерная фирма: Найдите производителей принтеров, которые производят ПК с наименьшим объемом RAM 
и с самым быстрым процессором среди всех ПК, имеющих наименьший объем RAM. Вывести: Maker

select distinct maker
from product p 
join printer pr 
on p.model = pr.model 
where maker = any(
	select distinct maker
	from product p 
	join pc 
	on p.model = pc.model
	where pc.ram in (
		select min_ram 
		from (
			select pc.model, min(ram) as min_ram, max(speed) as max_cpu 
			from pc
			group by pc.model 
		) as t_min_ram
	)
	and pc.speed in (
		select max_cpu from (
			select model, min(ram) as min_ram, max(speed) as max_cpu 
			from pc
			group by model
		) as t_max_cpu
	)
)



