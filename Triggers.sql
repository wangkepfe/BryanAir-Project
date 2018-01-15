drop trigger if exists ticketnumber;

delimiter //
create trigger ticketnumber
after insert on payment
for each row
begin 

update passenger p
set ticket = rand()*100000
where p.re_id = new.re_id;

end;
// 
delimiter ;
