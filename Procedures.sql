-- drop procedures

drop procedure if exists addYear;
drop procedure if exists addDay;
drop procedure if exists addDestination;
drop procedure if exists addRoute;
drop procedure if exists addFlight;

-- insert a year

delimiter //
create procedure addYear(in year int, in factor double)
begin
  insert into profitfactor(year, profitfactor)
  values (year, factor);
end;
//
delimiter ;

#call addYear(2017, 2);
#select * from profitfactor;

-- insert a day

delimiter //
create procedure addDay(in year int, in day varchar(10), in factor double)
begin
  insert into weekdays(year, weekday, pricingfactor)
  values (year, day, factor);
end;
//
delimiter ;

#call addDay(2016, 'Monday', 5.122);
#select * from weekdays;

-- Insert a destination

delimiter //
create procedure addDestination(in airport_code varchar(3),in name varchar(30),in country varchar(30))
begin
  insert into airport(ap_id, city, country)
  values (airport_code, name, country);

end;
//
delimiter ;

#call addDestination('ARN', 'Stockholm', 'Sweden');
#call addDestination('CPH', 'Copenhagen', 'Denmark');
#select * from airport;


-- Insert a route

delimiter //
create procedure addRoute(in airport_code_dept varchar(3), in airport_code_dest varchar(3),
in year int, in routeprice double)
begin
  insert into routes(depa_ap_id, dest_ap_id, year, price)
  values (airport_code_dept, airport_code_dest, year, routeprice);


  
end;
//
delimiter ;

#call addRoute('ARN', 'CPH', 2016, 50000);
#select * from routes;

delimiter //
create procedure addFlight(in departure_airport_code varchar(3),
in arrival_airport_code varchar(3),
in year int, in day varchar(10), in departure_time time)

begin
  declare m int;
  declare wsid int;
  declare c int default 1;

  select ro_id into m from routes A where 
  departure_airport_code = A.depa_ap_id 
  and arrival_airport_code = A.dest_ap_id
  and A.year = year;

  insert into weeklyschedule(departuretime, ro_id, year, weekday)
  values(departure_time, m, year, day);



  select ws_id into wsid from weeklyschedule A
    where A.departuretime = departure_time
    and A.ro_id = m
    and A.year = year
    and A.weekday = day;


  while c < 53 do 
  insert into flight(ws_id, week)
    value(wsid, c);
  set c = c + 1;
  end while;

end;
//
delimiter ;

#call addFlight('ARN', 'CPH', 2016, 'Monday', '15:15:00');
#select * from weeklyschedule;


#CREATE RESERVATION ON FLIGHT

drop procedure if exists addReservation;

delimiter //

create procedure addReservation(
in departure_airport_code varchar(3), in arrival_airport_code varchar(3),
in year int, in week int, in day varchar(10), in time time,
in number_of_passengers int, out output_reservation_nr int)

begin
  declare InFlight int;
  declare reservationid int;
  set InFlight = NULL;
  
  select fl_id into InFlight from flight A
    where A.week = week
    and A.ws_id in (select ws_id from weeklyschedule B where
    B.year = year 
    and B.weekday = day 
    and B.departuretime = time
    and B.ro_id in (select ro_id from routes C where
    C.depa_ap_id = departure_airport_code
    and C.dest_ap_id = arrival_airport_code));

   if(InFlight IS NULL) then
     select 'There exist no flight for the given route, date and time' as 'message';
   elseif ( number_of_passengers > (calculateFreeSeats(InFlight))) then
      select 'Flight is fully booked.' as 'Message';
   else
       insert into reservation(fl_id, no_passengers) values (InFlight, number_of_passengers);
       select max(re_id) into reservationid from reservation
         where InFlight = fl_id and no_passengers = number_of_passengers;

       set output_reservation_nr = reservationid;
   end if;

end;

// 
delimiter ;

#CREATE ADD PASSENGER ON RESERVATION

drop procedure if exists addPassenger;

delimiter //

create procedure addPassenger(in reservation_nr int, 
in passport_number int, in name varchar(30))
begin
 declare nopassenger int;
 declare bookedpassenger int;
 declare ifpaid int;
 set ifpaid = NULL;
 set nopassenger = NULL;

 select no_passengers into nopassenger from reservation where re_id = reservation_nr;
 select count(re_id) into bookedpassenger from passenger where re_id = reservation_nr;
 select count(re_id) into ifpaid from payment where re_id = reservation_nr;

 #select nopassenger, bookedpassenger;

 if(nopassenger IS NULL) then
   select 'The given reservation number does not exist';
 elseif (ifpaid = 1)then
   select 'The booking has already been payed and no futher passengers can be added' as 'message';
 elseif (nopassenger < bookedpassenger)then
   select 'Reservation has reachead maximum number of passengers.' as 'Message';
 else
   insert passenger(re_id, name, passport)
   values (reservation_nr, name, passport_number);
 end if;

end;

// 
delimiter ;


#CREATE ADD CONTACT ON RESERVATION

drop procedure if exists addContact;

delimiter //

create procedure addContact(in reservation_nr int,
in passport_number int, in email varchar(30),
in phone bigint)
begin

declare reservationValid int;
declare passengerValid int;
set reservationValid = NULL;
set passengerValid = NULL;

select count(*) into reservationValid from passenger where reservation_nr = re_id;
select count(*) into passengerValid from passenger where passport_number = passport;

#select * from passenger;
#select reservationValid, passengerValid;

if(reservationValid = 0)then
  select 'The given reservation number does not exist' as 'message';
elseif(passengerValid = 0)then
  select 'The person is not a passenger of the reservation' as 'message';
else
  insert into contactinfo(re_id, passport, phone, email)
  values (reservation_nr, passport_number, phone, email);
end if;

end;

// 
delimiter ;


#CREATE ADD PAYMEMT ON RESERVATION

drop procedure if exists addPayment;

delimiter //

create procedure addPayment(in reservation_nr int,
in cardholder_name varchar(30),
in credit_card_number bigint)
begin

declare price double;
declare flight int;
declare contact int;
declare number_of_passengers int;

select fl_id into flight from reservation where re_id = reservation_nr;

set price = calculatePrice(flight);
#select price;
set flight = NULL;
set contact = NULL;

select fl_id into flight from reservation where reservation_nr = re_id;
select count(*) into contact from contactinfo where reservation_nr = re_id;

select no_passengers into number_of_passengers from reservation where reservation_nr = re_id;

if(flight IS NULL)then
  select 'The given reservation number does not exist' as 'message';
elseif (contact <> 1) then
  select 'The reservation has no contact yet' as 'message';
elseif ( number_of_passengers > (calculateFreeSeats(flight))) then
  select 'Flight is fully booked, payment declined.' as 'Message';
else
  insert into payment(creditcard, name, amount, re_id)
  values(credit_card_number, cardholder_name, price, reservation_nr);
end if;

end;

// 
delimiter ;



