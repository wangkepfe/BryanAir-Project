-- drop all table in order

drop table if exists contactinfo;
drop table if exists passenger;
drop table if exists payment;
drop table if exists reservation;
drop table if exists flight;
drop table if exists weeklyschedule;
drop table if exists weekdays;
drop table if exists routes;
drop table if exists airport;
drop table if exists profitfactor;

-- airport

create table airport(
  ap_id varchar(3),
  country varchar(30),
  city varchar(30),

  constraint pk_id
    primary key (ap_id)
);

-- routes

create table routes(
  ro_id integer auto_increment,
  depa_ap_id varchar(3),
  dest_ap_id varchar(3),
  year integer,
  price double,

  constraint pk_id
    primary key (ro_id),

  constraint fk_depa_ap_id
    foreign key (depa_ap_id) references airport(ap_id),

  constraint fk_dest_ap_id
    foreign key (dest_ap_id) references airport(ap_id)
);

-- weekdays

create table weekdays(
  weekday varchar(10),
  pricingfactor double,
  year integer,

  constraint pk_id
    primary key (weekday, year)
);

-- weeklyschedule

create table weeklyschedule(
  ws_id integer auto_increment,
  ro_id integer,
  year integer,
  weekday varchar(10),
  departuretime time,



  constraint pk_id
    primary key (ws_id),

  constraint fk_weekday
    foreign key (weekday, year) references weekdays(weekday, year),

  constraint fk_ro_id1
    foreign key (ro_id) references routes(ro_id)
);

-- flight


create table flight(
  fl_id integer auto_increment,
  ws_id integer,
  week integer,
  
  constraint pk_id
    primary key (fl_id),

  constraint fk_ws_id
    foreign key (ws_id) references weeklyschedule(ws_id)
);

-- reservation

create table reservation(
  re_id integer auto_increment,
  fl_id integer, 
  no_passengers integer,

  constraint pk_re_id
    primary key (re_id),

  constraint fk_fl_id
    foreign key (fl_id) references flight(fl_id)
);

-- passenger

create table passenger(
  passport integer,
  name varchar(30),
  re_id integer,
  ticket integer,

  constraint pk_passport
    primary key (passport, re_id),

  constraint fk_re_id
    foreign key (re_id) references reservation(re_id)
);

-- contactinfo

create table contactinfo( 
  re_id integer,
  passport integer, 
  phone bigint,
  email varchar(30),

  constraint pk_passport2
    primary key (passport, re_id),

  constraint fk_passport
    foreign key (passport) references passenger(passport),

  constraint fk_re_id1
    foreign key (re_id) references reservation(re_id)
);

-- payment

create table payment(
  creditcard bigint,
  name varchar(40),
  amount integer,
  re_id integer,

  constraint pk_re_id
    primary key (re_id),

  constraint fk_re_id2
    foreign key (re_id) references reservation(re_id)
);

-- profitfactor

create table profitfactor(
  year integer,
  profitfactor double,

  constraint pk_year
    primary key (year)
);



