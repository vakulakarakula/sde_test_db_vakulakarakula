drop table bookings.results;
create table bookings.results
(id int,
response text);

--1.	Вывести максимальное количество человек в одном бронировании
insert into bookings.results

select 1 as test_number, max(chislo) as otvet from (select book_ref, count (*) as chislo from bookings.tickets group by book_ref) as tsd;

--2.	Вывести количество бронирований с количеством людей больше среднего значения людей на одно бронирование
insert into bookings.results

select 2 as test_number, count (book_ref) as otvet from
(select book_ref, chislo from
(select book_ref, count (*) as chislo from bookings.tickets group by book_ref) as dst
where chislo > (select avg(chislo) as otvet from (select book_ref, count (*) as chislo from bookings.tickets group by book_ref) as fdr)) as otvet;

--3.	Вывести количество бронирований, у которых состав пассажиров повторялся два и более раза, среди бронирований с максимальным количеством людей (п.1)?

--4.	Вывести номера брони и контактную информацию по пассажирам в брони (passenger_id, passenger_name, contact_data) с количеством людей в брони = 3
insert into bookings.results

select 4 as test_number, book_ref||'|'||passenger_id||'|'||passenger_name||'|'||contact_data as result from
(select
dst.book_ref as book_ref,
t.passenger_id as passenger_id,
t.passenger_name as passenger_name,
t.contact_data as contact_data
from 
(select dst.book_ref from
(select book_ref, count (*) as chislo from bookings.tickets group by book_ref) as dst
where chislo = 3) as dst
left join tickets t 
on dst.book_ref = t.book_ref
order by 1 asc,2 asc,3 asc,4 asc) as concatination;

--5.	Вывести максимальное количество перелётов на бронь
insert into bookings.results

select 5 as test_number, max(chislo) as otvet from 
(select b_book_ref, count(tf_flight_id) as chislo from
(select 
b.book_ref as b_book_ref,
tf.flight_id as tf_flight_id
from bookings.bookings b
left join bookings.tickets t on b.book_ref = t.book_ref
left join bookings.ticket_flights tf on t.ticket_no = tf.ticket_no) as tsd
group by b_book_ref) as dst;

--6.	Вывести максимальное количество перелётов на пассажира в одной брони
insert into bookings.results

select 6 as test_number, max(chislo) as otvet from 
(select b_book_ref, count(tf_flight_id) as chislo from
(select distinct 
b.book_ref as b_book_ref,
tf.flight_id as tf_flight_id
from bookings.bookings b
left join bookings.tickets t on b.book_ref = t.book_ref
left join bookings.ticket_flights tf on t.ticket_no = tf.ticket_no) as tsd
group by b_book_ref) as dst;


--7.	Вывести максимальное количество перелётов на пассажира
insert into bookings.results

select
7 as test_number,
count (*) as max_kolvo_pereletov
from bookings.ticket_flights as ticket_flights
left join bookings.tickets as tickets
on ticket_flights.ticket_no = tickets.ticket_no
group by tickets.passenger_id
order by 2 desc
limit 1;

/*
select
7 as test_number, 
max(kolvo_pereletov) as max_kolvo_pereletov
from
(select
passenger_id,
count (*) as kolvo_pereletov
from
(select
ticket_flights.flight_id,
ticket_flights.ticket_no,
tickets.passenger_id 
from bookings.ticket_flights as ticket_flights
left join bookings.tickets as tickets
on ticket_flights.ticket_no = tickets.ticket_no
--where ticket_flights.ticket_no = '0005435787387'
--where tickets.passenger_id = '8601 131152'
) as prom_table
group by passenger_id) as prom_table2;
*/

--8.	Вывести контактную информацию по пассажиру(ам) (passenger_id, passenger_name, contact_data) и общие траты на билеты, для пассажира потратившему минимальное количество денег на перелеты
insert into bookings.results

select
8 as test_number,
prom_table1.passenger_id||'|'||prom_table1.passenger_name||'|'||prom_table1.contact_data||'|'||prom_table1.amount_all_tickets as passenger_and_amount
from
(select
tickets.passenger_id,
tickets.passenger_name,
tickets.contact_data,
sum (ticket_flights.amount) as amount_all_tickets
from bookings.ticket_flights as ticket_flights
left join bookings.tickets as tickets
on ticket_flights.ticket_no = tickets.ticket_no
group by tickets.passenger_id,tickets.passenger_name,tickets.contact_data) as prom_table1
where amount_all_tickets =
(select min (amount_all_tickets)
from
(select
tickets.passenger_id,
sum (ticket_flights.amount) as amount_all_tickets
from bookings.ticket_flights as ticket_flights
left join bookings.tickets as tickets
on ticket_flights.ticket_no = tickets.ticket_no
group by tickets.passenger_id
order by amount_all_tickets) as prom_table2)
order by prom_table1.passenger_id,prom_table1.passenger_name,prom_table1.contact_data;

--9.	Вывести контактную информацию по пассажиру(ам) (passenger_id, passenger_name, contact_data) и общее время в полётах, для пассажира, который провёл максимальное время в полётах
insert into bookings.results

select
9 as test_number,
prom_table2.passenger_id||'|'||prom_table2.passenger_name||'|'||prom_table2.contact_data||'|'||prom_table2.sum_flight_time
from
(select
prom_table1.passenger_id,
prom_table1.passenger_name,
prom_table1.contact_data,
sum (prom_table1.flight_time) as sum_flight_time
from
(select
flights.flight_id,
flights.flight_no,
(flights.actual_arrival - flights.actual_departure) as flight_time,
ticket_flights.ticket_no,
tickets.passenger_id,
tickets.passenger_name,
tickets.contact_data
from bookings.flights as flights
join bookings.ticket_flights as ticket_flights on flights.flight_id = ticket_flights.flight_id
join bookings.tickets as tickets on ticket_flights.ticket_no = tickets.ticket_no 
where flights.actual_arrival is not null) as prom_table1
group by prom_table1.passenger_id, prom_table1.passenger_name, prom_table1.contact_data) as prom_table2
where prom_table2.sum_flight_time =
(select 
max (prom_table4.sum_flight_time)
from
(select
prom_table3.passenger_id,
prom_table3.passenger_name,
prom_table3.contact_data,
sum (prom_table3.flight_time) as sum_flight_time
from
(select
flights.flight_id,
flights.flight_no,
(flights.actual_arrival - flights.actual_departure) as flight_time,
ticket_flights.ticket_no,
tickets.passenger_id,
tickets.passenger_name,
tickets.contact_data
from bookings.flights as flights
join bookings.ticket_flights as ticket_flights on flights.flight_id = ticket_flights.flight_id
join bookings.tickets as tickets on ticket_flights.ticket_no = tickets.ticket_no 
where flights.actual_arrival is not null) as prom_table3
group by prom_table3.passenger_id, prom_table3.passenger_name, prom_table3.contact_data) as prom_table4)
order by prom_table2.passenger_id,prom_table2.passenger_name,prom_table2.contact_data;


--10.	Вывести город(а) с количеством аэропортов больше одного
insert into bookings.results

select 10 as test_number, city
from
(select
city,
count(*) as kolvo_airports
from bookings.airports
group by city) as prom_table
where kolvo_airports > 1
order by city asc;
--11.	Вывести город(а), у которого самое меньшее количество городов прямого сообщения
select 11 as test_number, departure_city from 
	(select
	departure_city,
	count (*) as kolvo_rourov2
	from
		(select distinct
		departure_city,
		arrival_city
		from bookings.routes) as prom_table3
	group by departure_city) asprom_table4
	where kolvo_rourov2 = (select min(kolvo_rourov) from
(select
departure_city,
count (*) as kolvo_rourov
from
(select distinct
departure_city,
arrival_city
from bookings.routes) as prom_table1
group by departure_city) as prom_table2)
order by 1;


--12.	Вывести пары городов, у которых нет прямых сообщений исключив реверсные дубликаты
--https://qna.habr.com/q/905713
insert into bookings.results

select
12 as test_number, 
result_table.departure_city||'|'||result_table.arrival_city from
--Исходная таблица с городами, между которыми есть авиасообщение
(with avia_pair as
(select distinct
departure_city,
arrival_city 
from bookings.routes)
--Из исходной таблицы делаем список возможных пар городов без реверсивных дубликатов
select distinct
a.departure_city,
b.arrival_city
from avia_pair a join avia_pair b
on a.departure_city < b.arrival_city
--Из списка возможных пар вычитаем пары, между которыми есть авиасообщение
--https://oracleplsql.ru/except-sql.html
except
select * from avia_pair
order by 1,2) as result_table;

--13.	Вывести города, до которых нельзя добраться без пересадок из Москвы?
insert into bookings.results

select 13 as test_number, prom_table.arrival_city from
--Список всех arrival_city
(select distinct
arrival_city
from bookings.routes
--Вычитаем из списка arrival_city те, для которых Москва - это departure_city
except
select distinct
arrival_city
from bookings.routes
where departure_city like 'Москва') as prom_table
--Исключаем из итоговой таблицы саму Москву
where prom_table.arrival_city not like 'Москва'
order by 2;


--14.	Вывести модель самолета, который выполнил больше всего рейсов
insert into bookings.results

with prom_table as 
(select
flights.aircraft_code,
count(*)
from bookings.flights
where actual_arrival is not null
group by aircraft_code
limit 1)
select
14 as test_number,
b.model
from prom_table
join bookings.aircrafts b on prom_table.aircraft_code = b.aircraft_code;

--15.	Вывести модель самолета, который перевез больше всего пассажиров
insert into bookings.results

select 15 as test_number, aircrafts.model from
(with pass_vs_aircraft as
(select
a.flight_id,
a.aircraft_code,
b.boarding_no
from bookings.flights_v as a
join bookings.boarding_passes as b on a.flight_id = b.flight_id
where a.status like 'Arrived')
select
aircraft_code,
count(*)
from pass_vs_aircraft
group by aircraft_code
order by 2 desc limit 1) as summ_pass
join bookings.aircrafts as aircrafts
on summ_pass.aircraft_code = aircrafts.aircraft_code;


--16.	Вывести отклонение в минутах суммы запланированного времени перелета от фактического по всем перелётам
insert into bookings.results

select
16 as test_number,
extract (epoch from (sum(scheduled_duration) - sum(actual_duration)))/60
from bookings.flights_v
where status like 'Arrived';

--17.	Вывести города, в которые осуществлялся перелёт из Санкт-Петербурга 2016-09-13
insert into bookings.results

select distinct 17 as test_number, arrival_city from bookings.flights_v 
where departure_city like 'Санкт%' and date(actual_departure) = '2016-09-13'
order by arrival_city;


--19.	Выбрать дни в которых было осуществлено минимальное количество перелётов
insert into bookings.results

with day_and_fly as
	(select
	date(actual_departure),
	count(*) as kolvo_pereletov
	from bookings.flights_v
	where status like 'Arrived'
	group by date(actual_departure))
		select 19 as test_number, text(date) from day_and_fly
		where kolvo_pereletov = 
			(select min(kolvo_pereletov) from
				(select
				date(actual_departure),
				count(*) as kolvo_pereletov
				from bookings.flights_v
				where status like 'Arrived'
				group by date(actual_departure)) as minimum);
