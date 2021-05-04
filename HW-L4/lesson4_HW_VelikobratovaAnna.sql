--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task13 (lesson3)
--Компьютерная фирма: Вывести список всех продуктов и производителя с указанием типа продукта (pc, printer, laptop). Вывести: model, maker, type
select model, maker, type
from product p;

--task14 (lesson3)
--Компьютерная фирма: При выводе всех значений из таблицы printer дополнительно вывести для тех, у кого цена вышей средней PC - "1", 
--у остальных - "0"
select *, 
case
when price > (select avg(price) from printer)
then 1
else 0
end flag
from printer p; 

--task15 (lesson3)
--Корабли: Вывести список кораблей, у которых class отсутствует (IS NULL)
select *
from ships
where class is null;

--task16 (lesson3)
--Корабли: Укажите сражения, которые произошли в годы, не совпадающие ни с одним из годов спуска кораблей на воду.
select b.name, date
from battles b
where  date_part ('year', date) not in (select  launched from ships s);


--task17 (lesson3)
--Корабли: Найдите сражения, в которых участвовали корабли класса Kongo из таблицы Ships.
select battle
from outcomes o 
join ships s3 
on s3.name=o.ship
where class = 'Kongo';

--task1  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_300) для всех товаров (pc, printer, laptop) с флагом, если стоимость больше > 300.
-- Во view три колонки: model, price, flag
create view all_products_flag_300
as
(
select model, price,
case
	when price > 300 then 1
	else 0
end flag
from pc p
union 

select model, price,
case
	when price > 300 then 1
	else 0
end flag
from laptop l 
union 

select model, price,
case
	when price > 300 then 1
	else 0
end flag
from printer pr 
);

select *
from all_products_flag_300;
--task2  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_avg_price) для всех товаров (pc, printer, laptop) с флагом, 
--если стоимость больше cредней . Во view три колонки: model, price, flag
create view all_products_flag_avg_price
as
(
select p.model, price,
case
	when p.price > (select avg(p2.price) from pc p2)then 1
	else 0
end flag
from pc p
union 

select pr.model, price,
case
	when pr.price > (select avg(p.price) from printer p)then 1
	else 0
end flag
from printer pr
union 

select l.model, price,
case
	when l.price > (select avg(l2.price) from laptop l2)then 1
	else 0
end flag
from laptop l 
);

select *
from all_products_flag_avg_price;

--task3  (lesson4)
-- Компьютерная фирма: Вывести все принтеры производителя = 'A' со стоимостью выше средней по принтерам производителя = 'D' и 'C'.
-- Вывести model
select p.model
from printer p
join product p2 
on p.model=p2.model 
where price > (select avg(price)
			 from printer p3
			 join product p4 
			 on p3.model = p4.model 
			 where maker = 'D' or maker = 'C')
and maker = 'A';

--task4 (lesson4)
-- Компьютерная фирма: Вывести все товары производителя = 'A' со стоимостью выше средней по принтерам производителя = 'D' и 'C'. Вывести model
--task5 (lesson4)
-- Компьютерная фирма: Какая средняя цена среди уникальных продуктов производителя = 'A' (printer & laptop & pc)
select distinct p.model, avg(price)
from pc p 
join product p2 
on p.model=p2.model 
where p2.maker = 'A'
group by p.model
union 

select distinct p.model, avg(price)
from printer p 
join product p2 
on p.model=p2.model 
where p2.maker = 'A'
group by p.model
union

select distinct l.model, avg(price)
from laptop l 
join product p2 
on l.model=p2.model 
where p2.maker = 'A'
group by l.model;

-- variant 2
select avg(price) as avg_price from
(select distinct p.model, price
from pc p 
join product p2 
on p.model=p2.model 
where p2.maker = 'A'
union 
select distinct p.model, price
from printer p 
join product p2 
on p.model=p2.model 
where p2.maker = 'A'
union
select distinct l.model, price
from laptop l 
join product p2 
on l.model=p2.model 
where p2.maker = 'A') t1;

--task6 (lesson4)
-- Компьютерная фирма: Сделать view с количеством товаров (название count_products_by_makers) по каждому производителю. Во view: maker, count
create view count_products_by_makers
as
(select p.maker, count(p.model)
	from product p
	group by p.maker
);

select *
from count_products_by_makers;

--task7 (lesson4)
-- По предыдущему view (count_products_by_makers) сделать график в colab (X: maker, y: count)

--task8 (lesson4)
-- Компьютерная фирма: Сделать копию таблицы printer (название printer_updated) и удалить из нее все принтеры производителя 'D'
create table printer_updated as table printer;

delete
from printer_updated pr
where model in (
	select p.model 
	from product p
	where maker='D'
);
--task9 (lesson4)
-- Компьютерная фирма: Сделать на базе таблицы (printer_updated) view с дополнительной колонкой производителя 
--(название printer_updated_with_makers)
--drop view printer_updated_with_makers;
create view printer_updated_with_makers
as (
	select pu.*, p.maker 
	from printer_updated pu 
	join product p
	on pu.model=p.model
);

select *
from printer_updated_with_makers;
--task10 (lesson4)
-- Корабли: Сделать view c количеством потопленных кораблей и классом корабля (название sunk_ships_by_classes). Во view: count, class
-- (если значения класса нет/IS NULL, то заменить на 0)
create view sunk_ships_by_classes
as (
	select 
		case 
			when s.class is null then '0'
			else s.class
		end "class",
		count(o.ship)
	
	from outcomes o 
	left join ships s
	on s.name = o.ship
	
	where result='sunk'
	group by "class"
);

select * from sunk_ships_by_classes;

--task11 (lesson4)
-- Корабли: По предыдущему view (sunk_ships_by_classes) сделать график в colab (X: class, Y: count)

--task12 (lesson4)
-- Корабли: Сделать копию таблицы classes (название classes_with_flag) и добавить в нее flag: если количество орудий больше или равно 9 - то 1, 
--иначе 0

create table classes_with_flag
as (
	select c.*,
		case 
			when numguns >= 9 then 1
			else 0
		end flag
	from classes c 
);
select *
from classes_with_flag;
--task13 (lesson4)
-- Корабли: Сделать график в colab по таблице classes с количеством классов по странам (X: country, Y: count)

select  country, count(class)
from classes 
group by country; 

--task14 (lesson4)
-- Корабли: Вернуть количество кораблей, у которых название начинается с буквы "O" или "M".
select count(name)
from ships s
where name like 'O%' or name like 'M%' 

--task15 (lesson4)
-- Корабли: Вернуть количество кораблей, у которых название состоит из двух слов.
select count(name)
from ships s
where name like '% %'

--task16 (lesson4)
-- Корабли: Построить график с количеством запущенных на воду кораблей и годом запуска (X: year, Y: count)

select  s.launched as year, count(name)
from ships s 
group by year
order by year;

 