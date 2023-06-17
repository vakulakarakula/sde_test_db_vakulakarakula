--1.	Вывести максимальное количество человек в одном бронировании
select max(chislo) as otvet from (select book_ref, count (*) as chislo from bookings.tickets group by book_ref) as tsd;
--2.	Вывести количество бронирований с количеством людей больше среднего значения людей на одно бронирование
select count (book_ref) as otvet from
(select book_ref, chislo from
(select book_ref, count (*) as chislo from bookings.tickets group by book_ref) as dst
where chislo > (select avg(chislo) as otvet from (select book_ref, count (*) as chislo from bookings.tickets group by book_ref) as fdr)) as otvet;
--3.	Вывести количество бронирований, у которых состав пассажиров повторялся два и более раза, среди бронирований с максимальным количеством людей (п.1)?
--4.	Вывести номера брони и контактную информацию по пассажирам в брони (passenger_id, passenger_name, contact_data) с количеством людей в брони = 3
select
dst.book_ref,
t.passenger_id,
t.passenger_name,
t.contact_data 
from 
(select dst.book_ref from
(select book_ref, count (*) as chislo from bookings.tickets group by book_ref) as dst
where chislo = 3) as dst
left join tickets t 
on dst.book_ref = t.book_ref
order by 1 asc,2 asc,3 asc,4 asc;
--5.	Вывести максимальное количество перелётов на бронь
select max(chislo) as otvet from 
(select b_book_ref, count(tf_flight_id) as chislo from
(select 
b.book_ref as b_book_ref,
tf.flight_id as tf_flight_id
from bookings.bookings b
left join bookings.tickets t on b.book_ref = t.book_ref
left join bookings.ticket_flights tf on t.ticket_no = tf.ticket_no) as tsd
group by b_book_ref) as dst;
--6.	Вывести максимальное количество перелётов на пассажира в одной брони
select max(chislo) as otvet from 
(select b_book_ref, count(tf_flight_id) as chislo from
(select distinct 
b.book_ref as b_book_ref,
tf.flight_id as tf_flight_id
from bookings.bookings b
left join bookings.tickets t on b.book_ref = t.book_ref
left join bookings.ticket_flights tf on t.ticket_no = tf.ticket_no) as tsd
group by b_book_ref) as dst;
--7.
