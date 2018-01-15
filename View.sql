drop view if exists allFlights;

create view allFlights(departure_city_name,
destination_city_name,
departure_time,
departure_day,
departure_week,
departure_year,
nr_of_free_seats,
current_price_per_seat) as
select 
D1.city,
D2.city,
A.departuretime,
A.weekday,
B.week,
A.year,
calculateFreeSeats(B.fl_id),
calculatePrice(B.fl_id)
from weeklyschedule A, flight B, routes C, airport D1, airport D2
where A.ws_id = B.ws_id
and A.ro_id = C.ro_id
and C.depa_ap_id = D1.ap_id
and C.dest_ap_id = D2.ap_id
order by year, week asc;

#select * from allFlights;
