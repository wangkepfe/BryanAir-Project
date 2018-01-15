drop function if exists calculateFreeSeats;
drop function if exists calculatePrice;


delimiter //
create function calculateFreeSeats(flightnumber int)
returns int

begin
declare n int;
select count(ticket) into n from passenger
where re_id in
(select re_id from reservation where fl_id = flightnumber);

return (40 - n);

end;
// 
delimiter ;


delimiter //
create function calculatePrice(flightnumber int)
returns double

begin

declare Arouteprice double;
declare Bweeklyfactor double;
declare Cbookedpassenger int;
declare Dprofitfactor double;

select price into Arouteprice from routes
where ro_id = (select ro_id from weeklyschedule
where ws_id = (select ws_id from flight
where fl_id = flightnumber));

select pricingfactor into Bweeklyfactor from weekdays
where weekday = (select weekday from weeklyschedule
where ws_id = (select ws_id from flight
where fl_id = flightnumber));

select count(*) into Cbookedpassenger from passenger
where re_id in (select re_id from reservation where fl_id = flightnumber)
and ticket is not null;

select profitfactor into Dprofitfactor from profitfactor
where year = (select year from weeklyschedule
where ws_id = (select ws_id from flight
where fl_id = flightnumber));

return Arouteprice * Bweeklyfactor * (Cbookedpassenger + 1)/40 * Dprofitfactor;

end;
// 
delimiter ;

