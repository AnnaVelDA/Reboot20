--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task1 (lesson5)
-- Компьютерная фирма: Сделать view (pages_all_products), в которой будет постраничная разбивка всех продуктов 
--(не более двух продуктов на одной странице). Вывод: все данные из laptop, номер страницы, список всех страниц
--drop view pages_all_products;
create view pages_all_products
as (
	select *, ceiling((row_number() over (order by "type", code) + 1)/2) as list_num, ceiling(COUNT(*) OVER() /2) as list_cnt
	from (
		select code, 'pc' as "type", model, speed, ram, hd, price, null as screen
		from pc
		union 
		
		select code, 'laptop' as "type", model, speed, ram, hd, price, screen
		from laptop
		union
		
		select code, 'printer' as "type", model, null as speed, null as ram, null as hd, price, null as screen
		from printer
	) as t1
);

SELECT * FROM pages_all_products;

--variant 2
create view pages_all_products
as (
	SELECT code, model, speed, ram, hd, price, screen, 
	      CASE WHEN num % 2 = 0 THEN num/2 ELSE num/2 + 1 END AS page_num, 
	      CASE WHEN total % 2 = 0 THEN total/2 ELSE total/2 + 1 END AS num_of_pages
	FROM (
		SELECT *, ROW_NUMBER() OVER(ORDER BY price DESC) AS num, COUNT(*) OVER() AS total 
	    FROM (
	    	select code, model, speed, ram, hd, price, null as screen
			from pc
			union 
		
			select code, model, speed, ram, hd, price, screen
			from laptop
			union
			
			select code, model, null as speed, null as ram, null as hd, price, null as screen
			from printer
		) t1
	) t2
);
select * from pages_all_products

--task2 (lesson5)
-- Компьютерная фирма: Сделать view (distribution_by_type), в рамках которого будет процентное соотношение всех 
--товаров по типу устройства. Вывод: производитель,
--drop view distribution_by_type
create view distribution_by_type
as
(
select maker, type, cast(100.0*type_cnt/maker_cnt as numeric(5,2)) as part from (
	select t2.*, t3.maker_cnt from (
		select maker, t1.type, max(type_cnt) type_cnt from (
			select maker, type, row_number() over(partition by maker, type) as type_cnt from product p 
		) t1
		group by maker, type
	) t2
	join (
		select maker, count(*) as maker_cnt from product p
		group by maker 
	) t3
	on t2.maker = t3.maker
) t_res
);
select * from distribution_by_type;
--task3 (lesson5)
-- Компьютерная фирма: Сделать на базе предыдущенр view график - круговую диаграмму

--task4 (lesson5)
-- Корабли: Сделать копию таблицы ships (ships_two_words), но у название корабля должно состоять из двух слов
create table ships_two_words
as
(
Select *
from ships
where name like '% %'
);

select * from ships_two_words;
 
--task5 (lesson5)
-- Корабли: Вывести список кораблей, у которых class отсутствует (IS NULL) и название начинается с буквы "S"
select name
from ships
where class is null and name like 'S%';

--task6 (lesson5)
-- Компьютерная фирма: Вывести все принтеры производителя = 'A' со стоимостью выше средней по принтерам производителя = 'C'
-- и три самых дорогих (через оконные функции). Вывести model
select model from 
(
	select pr.*, avg(price) over(order by maker='C') as avg_price_c
	from printer pr
	join product p
	on p.model=pr.model
	where maker ='A'
) a 
where price > avg_price_c
union all

select model from (
	select *, row_number() over (order by price desc) as exp_price
	from printer
) a1
where exp_price < 4;


