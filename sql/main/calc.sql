drop table bookings.results;

create table bookings.results
(id int,
response text);

/*1.	Вывести максимальное количество человек в одном бронировании*/
insert into bookings.results

select
	1 as test_number,
	max(chislo) as test_1_result
from
	(
	select
		book_ref,
		count (passenger_id) as chislo
	from
		bookings.tickets
	group by
		book_ref) as prom_table;
	


/*2.	Вывести количество бронирований с количеством людей больше среднего значения людей на одно бронирование*/
insert into bookings.results

select
	2 as test_number,
	count (book_ref) as test_2_result
from
	(
	select
		book_ref,
		chislo
	from
--Базовая таблица с номером брони и количеством пассажиров в брони	
		(
		select
			book_ref,
			count (*) as chislo
		from
			bookings.tickets
		group by
			book_ref) as prom_table
	where
		chislo > 
--Среднее количество людей на бронирование		
		(
		select
			avg(chislo) as otvet
		from
--Базовая таблица с номером брони и количеством пассажиров в брони
			(
			select
				book_ref,
				count (*) as chislo
			from
				bookings.tickets
			group by
				book_ref) as prom_table)) as otvet;
   

   
/*3.	Вывести количество бронирований, у которых состав пассажиров повторялся два и более раза, среди бронирований с максимальным количеством людей (п.1)?*/
insert into bookings.results

select 3 as test_number, count (*) as test_3_result from
--Считаем количество повторов каждого массива с id пассажиров и фильтруем только те массивы, которые повторяются 2 и более раз
  (select
    prom_table2.array_pass_id,
    count (prom_table2.book_ref) as kolvo_povtorov
      from
--Результат джойна базовой таблицы и массива с id пассажиров, результат - таблица с номером брони с мак. кол-вом пассажиров и списком id этих пасажиров
      (select
        join_table1.book_ref,
    join_table2.array_pass_id
      from
--Базовая таблица с book_ref, в которых chislo = максимальному количеству людей в брони
      (with t1 as
  (select book_ref, count (*) as chislo from bookings.tickets group by book_ref)
select distinct
  t1.book_ref
from t1
  join bookings.tickets t2
  on t1.book_ref=t2.book_ref
where chislo = (select  max(chislo) as otvet from (select book_ref, count (*) as chislo from bookings.tickets group by book_ref) as prom_table1)) as join_table1
  join
--Джойним массив c id пассажиров, в массиве упорядочиваем id по возрастанию
      (select
        book_ref,
        array_agg (passenger_id order by passenger_id) array_pass_id
          from bookings.tickets
      group by book_ref)as join_table2
  on join_table1.book_ref = join_table2.book_ref) as prom_table2
  group by prom_table2.array_pass_id
  having count (prom_table2.book_ref) >= 2) as prom_table3;

 
 
 
/*4.	Вывести номера брони и контактную информацию по пассажирам в брони (passenger_id, passenger_name, contact_data) с количеством людей в брони = 3*/
insert into bookings.results

select
      4 as test_number,
      prom_table1.book_ref||'|'||t.passenger_id||'|'||t.passenger_name||'|'||t.contact_data as contact_data
    from
      (
--Считаем количество пассажиров на бронь и фильтруем только тебронирования, где 3 пассажира
            select
              book_ref,
              count (*) as kolvo_passenger
            from
              bookings.tickets
            group by tickets.book_ref
            having count (*) = 3
      ) as prom_table1
--Джойним контакты пассажиров
      left join tickets t on prom_table1.book_ref = t.book_ref
    order by contact_data asc;

   
 


/*5.	Вывести максимальное количество перелётов на бронь*/
insert into bookings.results

 select
      5 as test_number,
      count(tf_flight_id) as chislo
    from
      (
--Базовая таблица, к номеру брони джойним номера билетов, к номерам билетов джойним id перелета
        select
          b.book_ref as b_book_ref,
          tf.flight_id as tf_flight_id
        from
          bookings.bookings b
          left join bookings.tickets t on b.book_ref = t.book_ref
          left join bookings.ticket_flights tf on t.ticket_no = tf.ticket_no
      ) as prom_table
    group by b_book_ref
    order by chislo desc
    limit 1;

/*
select
  5 as test_number,
  max(chislo) as otvet
from
--Считаем количество перелетов, которое приходится на бронь  
 (
    select
      b_book_ref,
      count(tf_flight_id) as chislo
    from
      (
--Базовая таблица, к номеру брони джойним номера билетов, к номерам билетов джойним id перелета
        select
          b.book_ref as b_book_ref,
          tf.flight_id as tf_flight_id
        from
          bookings.bookings b
          left join bookings.tickets t on b.book_ref = t.book_ref
          left join bookings.ticket_flights tf on t.ticket_no = tf.ticket_no
      ) as prom_table
    group by
      b_book_ref
  ) as dst;
*/

   
   

/*6.	Вывести максимальное количество перелётов на пассажира в одной брони*/
insert into bookings.results

select 6 as test_number, max(chislo) as otvet from
  (select b_book_ref, t_passenger_id, count(tf_flight_id) as chislo from
    (select distinct
      b.book_ref as b_book_ref,
      tf.flight_id as tf_flight_id,
      t.passenger_id as t_passenger_id
        from bookings.bookings b
        join bookings.tickets t on b.book_ref = t.book_ref
    join bookings.ticket_flights tf on t.ticket_no = tf.ticket_no) as tsd
  group by b_book_ref, t_passenger_id) as dst;
 

/*
 select 6 as test_number, count(tf_flight_id) as chislo from
    (select distinct
      b.book_ref as b_book_ref,
      tf.flight_id as tf_flight_id,
      t.passenger_id as t_passenger_id
        from bookings.bookings b
        join bookings.tickets t on b.book_ref = t.book_ref
    join bookings.ticket_flights tf on t.ticket_no = tf.ticket_no) as tsd
  group by b_book_ref, t_passenger_id
  order by chislo desc
  limit 1;
*/


/*7.	Вывести максимальное количество перелётов на пассажира*/
insert into bookings.results

select
  7 as test_number,
  count (*) as max_kolvo_pereletov
from
  bookings.ticket_flights as ticket_flights
  join bookings.tickets as tickets on ticket_flights.ticket_no = tickets.ticket_no
group by
  tickets.passenger_id
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




/*8.	Вывести контактную информацию по пассажиру(ам) (passenger_id, passenger_name, contact_data) и общие траты на билеты, для пассажира потратившему минимальное количество денег на перелеты*/
insert into bookings.results

select
  8 as test_number,
  prom_table1.passenger_id || '|' || prom_table1.passenger_name || '|' || prom_table1.contact_data || '|' || prom_table1.amount_all_tickets as passenger_and_amount
from
--Базовая таблица с контактами пассажиров и суммой, потраченной на все билеты
  (
    select
      tickets.passenger_id,
      tickets.passenger_name,
      tickets.contact_data,
      sum (ticket_flights.amount) as amount_all_tickets
    from
      bookings.ticket_flights as ticket_flights
      join bookings.tickets as tickets on ticket_flights.ticket_no = tickets.ticket_no
    group by
      tickets.passenger_id,
      tickets.passenger_name,
      tickets.contact_data
  ) as prom_table1
--Выбираем только тех, кто потратил минимум на все билеты
where
  amount_all_tickets = 
  (
    select
      min (amount_all_tickets)
    from
      (
        select
          tickets.passenger_id,
          sum (ticket_flights.amount) as amount_all_tickets
        from
          bookings.ticket_flights as ticket_flights
          join bookings.tickets as tickets on ticket_flights.ticket_no = tickets.ticket_no
        group by
          tickets.passenger_id
      ) as prom_table2
  )
order by
  prom_table1.passenger_id,
  prom_table1.passenger_name,
  prom_table1.contact_data;

 
 
 
 
/*9.	Вывести контактную информацию по пассажиру(ам) (passenger_id, passenger_name, contact_data) и общее время в полётах, для пассажира, который провёл максимальное время в полётах*/
insert into bookings.results

select
  9 as test_number,
  prom_table2.passenger_id || '|' || prom_table2.passenger_name || '|' || prom_table2.contact_data || '|' || prom_table2.sum_flight_time
from
  (
    select
      prom_table1.passenger_id,
      prom_table1.passenger_name,
      prom_table1.contact_data,
      sum (prom_table1.flight_time) as sum_flight_time
    from
      (
        select
          flights.flight_id,
          flights.flight_no,
          (flights.actual_arrival - flights.actual_departure) as flight_time,
          ticket_flights.ticket_no,
          tickets.passenger_id,
          tickets.passenger_name,
          tickets.contact_data
        from
          bookings.flights as flights
          join bookings.ticket_flights as ticket_flights on flights.flight_id = ticket_flights.flight_id
          join bookings.tickets as tickets on ticket_flights.ticket_no = tickets.ticket_no
        where
          flights.actual_arrival is not null
      ) as prom_table1
    group by
      prom_table1.passenger_id,
      prom_table1.passenger_name,
      prom_table1.contact_data
  ) as prom_table2
where
  prom_table2.sum_flight_time = (
    select
      max (prom_table4.sum_flight_time)
    from
      (
        select
          prom_table3.passenger_id,
          prom_table3.passenger_name,
          prom_table3.contact_data,
          sum (prom_table3.flight_time) as sum_flight_time
        from
          (
            select
              flights.flight_id,
              flights.flight_no,
              (flights.actual_arrival - flights.actual_departure) as flight_time,
              ticket_flights.ticket_no,
              tickets.passenger_id,
              tickets.passenger_name,
              tickets.contact_data
            from
              bookings.flights as flights
              join bookings.ticket_flights as ticket_flights on flights.flight_id = ticket_flights.flight_id
              join bookings.tickets as tickets on ticket_flights.ticket_no = tickets.ticket_no
            where
              flights.actual_arrival is not null
          ) as prom_table3
        group by
          prom_table3.passenger_id,
          prom_table3.passenger_name,
          prom_table3.contact_data
      ) as prom_table4
  )
order by
  prom_table2.passenger_id,
  prom_table2.passenger_name,
  prom_table2.contact_data;


/*10.	Вывести город(а) с количеством аэропортов больше одного*/
insert into bookings.results

select
	10 as test_number,
	city
from
	(
	select
		city,
		count(*) as kolvo_airports
	from
		bookings.airports
	group by
		city) as prom_table
where
	kolvo_airports > 1
order by
	city asc;


/*11.	Вывести город(а), у которого самое меньшее количество городов прямого сообщения*/
insert into bookings.results

select
	11 as test_number,
	departure_city
from 
	(
	select
		departure_city,
		count (*) as kolvo_routov2
	from
		(
		select distinct
		departure_city,
			arrival_city
		from
			bookings.routes) as prom_table3
	group by
		departure_city) asprom_table4
where
	kolvo_routov2 = (
	select
		min(kolvo_routov)
	from
		(
		select
			departure_city,
			count (*) as kolvo_routov
		from
			(
			select distinct
departure_city,
				arrival_city
			from
				bookings.routes) as prom_table1
		group by
			departure_city) as prom_table2)
order by 1;


/*12.	Вывести пары городов, у которых нет прямых сообщений исключив реверсные дубликаты*/
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

/*13.	Вывести города, до которых нельзя добраться без пересадок из Москвы?*/
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


/*14.	Вывести модель самолета, который выполнил больше всего рейсов*/
insert into bookings.results

with prom_table as 
(
select
	flights.aircraft_code,
	count(*)
from
	bookings.flights
where
	actual_arrival is not null
group by
	aircraft_code
limit 1)
select
	14 as test_number,
	b.model
from
	prom_table
join bookings.aircrafts b on
	prom_table.aircraft_code = b.aircraft_code;



/*15.	Вывести модель самолета, который перевез больше всего пассажиров*/
insert into bookings.results


select
	15 as test_number,
	aircrafts.model
from
	(with pass_vs_aircraft as
(
	select
		a.flight_id,
		a.aircraft_code,
		b.boarding_no
	from
		bookings.flights_v as a
	join bookings.boarding_passes as b on
		a.flight_id = b.flight_id
	where
		a.status like 'Arrived')
	select
		aircraft_code,
		count(*)
	from
		pass_vs_aircraft
	group by
		aircraft_code
	order by
		2 desc
	limit 1) as summ_pass
join bookings.aircrafts as aircrafts
on
	summ_pass.aircraft_code = aircrafts.aircraft_code;


/*16.	Вывести отклонение в минутах суммы запланированного времени перелета от фактического по всем перелётам*/
insert into bookings.results

select
	16 as test_number,
	cast ((extract (epoch from (sum(scheduled_duration) - sum(actual_duration)))/ 60) as smallint) as otklon
from
	bookings.flights_v
where
	status like 'Arrived';



/*17.	Вывести города, в которые осуществлялся перелёт из Санкт-Петербурга 2016-09-13*/
insert into bookings.results

select
	distinct 17 as test_number,
	arrival_city
from
	bookings.flights_v
where
	departure_city like 'Санкт%'
	and date(actual_departure) = '2016-09-13'
order by
	arrival_city;




/*18.	Вывести перелёт(ы) с максимальной стоимостью всех билетов*/
insert into bookings.results

with teble_with_sum_price as
(
select
	flight_id,
	sum(amount) as sum_amount
from
	bookings.ticket_flights
group by
	flight_id)
select
	18 as test_number,
	flight_id
from
	teble_with_sum_price
where
	sum_amount =
(select
		max(sum_amount)
	from
		teble_with_sum_price)
order by
	flight_id;


/*19.	Выбрать дни в которых было осуществлено минимальное количество перелётов*/
insert into bookings.results

with day_and_fly as
	(
select
	date(actual_departure),
	count(*) as kolvo_pereletov
from
	bookings.flights_v
where
	status like 'Arrived'
group by
	date(actual_departure))
		select
	19 as test_number,
	text(date) as sleep_date
from
	day_and_fly
where
	kolvo_pereletov = 
			(
	select
		min(kolvo_pereletov)
	from
				(
		select
				date(actual_departure),
				count(*) as kolvo_pereletov
		from
			bookings.flights_v
		where
			status like 'Arrived'
		group by
			date(actual_departure)) as minimum);

			

/*20.	Вывести среднее количество вылетов в день из Москвы за 09 месяц 2016 года*/
insert into bookings.results			

with september_flights as
(
select
	date(actual_departure) as flight_date,
	count(*) as kolvo_flights
from
	bookings.flights_v
where
	status in ('Arrived')
	and departure_city like 'Москва'
	and date(actual_departure) between '2016-09-01' and '2016-09-30'
group by
	flight_date
	)
select
	20 as test_number,
	round (avg(kolvo_flights),0) as avg_kolvo_flights
from
	september_flights;


/*21.	Вывести топ 5 городов у которых среднее время перелета до пункта назначения больше 3 часов*/
insert into bookings.results

select
	21 as test_number,
	departure_city
from
	(
	select
		departure_city,
		avg(scheduled_duration) as avg_fly_time
	from
		bookings.flights_v
	group by
		departure_city
	having
		avg(scheduled_duration) > interval '3h'
	order by
		2 desc
	limit 5) as top_table
order by
	2;

/*
select
	21 as test_number,
	departure_city
from
	(with avg_flight_seconds as
(
	select
		departure_city,
		extract (epoch
	from
		avg(scheduled_duration)) as avg_fly_time
	from
		bookings.flights_v
	group by
		departure_city)
	select
		departure_city
	from
		avg_flight_seconds
	where
		avg_fly_time > 10800
	order by
		avg_fly_time desc
	limit 5) as top_table
order by
	2;
*/