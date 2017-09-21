CREATE SCHEMA credit_scoring;

CREATE TABLE credit_scoring.clients ( 
	b_client_id          int UNSIGNED NOT NULL  ,
	full_name            tinytext  NOT NULL  ,
	passport_number      varchar(11)  NOT NULL  ,
	passport_issue_date  date  NOT NULL  ,
	phone_number         tinytext  NOT NULL  ,
	black_list           tinyint UNSIGNED NOT NULL DEFAULT 0 ,
	CONSTRAINT pk_clients PRIMARY KEY ( b_client_id ),
	CONSTRAINT `passport_number_UNIQUE` UNIQUE ( passport_number ) 
 );

ALTER TABLE credit_scoring.clients MODIFY black_list tinyint UNSIGNED NOT NULL DEFAULT 0  COMMENT '0 - not in black list
1 - in';

CREATE TABLE credit_scoring.goods ( 
	serial_number        int UNSIGNED NOT NULL  ,
	name                 varchar(45)  NOT NULL  ,
	price                float(12,0) UNSIGNED NOT NULL  ,
	amount_available     int  NOT NULL  ,
	CONSTRAINT pk_goods PRIMARY KEY ( serial_number ),
	CONSTRAINT `name_UNIQUE` UNIQUE ( name ) 
 );

CREATE TABLE credit_scoring.partners_banks ( 
	bank_id              int  NOT NULL  ,
	org_name             varchar(45)    ,
	partnership_start    date  NOT NULL  ,
	partnership_end      date    ,
	info                 tinytext    ,
	CONSTRAINT pk_partners_banks PRIMARY KEY ( bank_id ),
	CONSTRAINT `org_name_UNIQUE` UNIQUE ( org_name ) 
 );

CREATE TABLE credit_scoring.partners_stores ( 
	store_id             int UNSIGNED NOT NULL  ,
	org_name             varchar(45)    ,
	partnership_start    date  NOT NULL  ,
	partnership_end      date    ,
	info                 tinytext    ,
	CONSTRAINT pk_partners_stores PRIMARY KEY ( store_id ),
	CONSTRAINT idx_org_name UNIQUE ( org_name ) 
 );

CREATE TABLE credit_scoring.store_credit_request_forms ( 
	form_id              int UNSIGNED NOT NULL  ,
	bank_id              int  NOT NULL  ,
	s_client_id          int  NOT NULL  ,
	date_opened          date  NOT NULL  ,
	date_current_status  date    ,
	monies_amount        int UNSIGNED NOT NULL  ,
	income_per_year      float(12,0)  NOT NULL  ,
	income_source        char(1)  NOT NULL  ,
	phone_number         text  NOT NULL  ,
	status               char(1)  NOT NULL  ,
	CONSTRAINT pk_store_credit_request_forms PRIMARY KEY ( form_id )
 );

CREATE INDEX bank_id ON credit_scoring.store_credit_request_forms ( bank_id );

ALTER TABLE credit_scoring.store_credit_request_forms MODIFY income_source char(1)  NOT NULL   COMMENT 'E - employed
P - private buisness
N - none';

ALTER TABLE credit_scoring.store_credit_request_forms MODIFY status char(1)  NOT NULL   COMMENT '0 - work in progress
1 - granted
2 - rejected';

CREATE TABLE credit_scoring.bank_credit_request_forms ( 
	form_id              int UNSIGNED NOT NULL  ,
	store_id             int UNSIGNED NOT NULL  ,
	b_client_id          int UNSIGNED NOT NULL  ,
	date_opened          date  NOT NULL  ,
	date_current_status  date    ,
	monies_amount        int UNSIGNED NOT NULL  ,
	income_per_year      float(12,0)  NOT NULL  ,
	income_source        char(1)  NOT NULL  ,
	phone_number         tinytext    ,
	status               char(1)  NOT NULL  ,
	nginfo               char(6)    ,
	CONSTRAINT pk_bank_credit_request_forms PRIMARY KEY ( form_id )
 );

CREATE INDEX credit_request_forms_ibfk_1 ON credit_scoring.bank_credit_request_forms ( b_client_id );

CREATE INDEX store_id_idx ON credit_scoring.bank_credit_request_forms ( store_id );

ALTER TABLE credit_scoring.bank_credit_request_forms MODIFY income_source char(1)  NOT NULL   COMMENT 'E - employed
P - private buisness
N - none';

ALTER TABLE credit_scoring.bank_credit_request_forms MODIFY status char(1)  NOT NULL   COMMENT '0 - work in progress
1 - credit granted
2 - rejected';

ALTER TABLE credit_scoring.bank_credit_request_forms MODIFY nginfo char(6)     COMMENT 'A1 - too young
A2 - too old
B - bad credit history
H - unemployed
T - non grata
L - in black list
ex: A2HT == Old unemployed terrorist';

CREATE TABLE credit_scoring.orders ( 
	order_id             int UNSIGNED NOT NULL  ,
	form_id              int UNSIGNED NOT NULL  ,
	s_client_id          int  NOT NULL  ,
	payment_method       boolean  NOT NULL  ,
	status               char(1)  NOT NULL  ,
	monies_amount        float(12,0) UNSIGNED NOT NULL  ,
	date_opened          date  NOT NULL  ,
	date_closed          date    ,
	CONSTRAINT pk_orders PRIMARY KEY ( order_id )
 );

CREATE INDEX form_id_idx ON credit_scoring.orders ( form_id );

ALTER TABLE credit_scoring.orders MODIFY payment_method boolean  NOT NULL   COMMENT '0 - cash
1 - credit';

ALTER TABLE credit_scoring.orders MODIFY status char(1)  NOT NULL   COMMENT '0 - work in progress
1 - granted
2 - rejected';

CREATE TABLE credit_scoring.order_lists ( 
	order_id             int UNSIGNED NOT NULL  ,
	serial_number        int UNSIGNED NOT NULL  ,
	quantity             int  NOT NULL DEFAULT 1 ,
	CONSTRAINT pk_order_lists PRIMARY KEY ( order_id, serial_number )
 );

CREATE INDEX idx_order_lists ON credit_scoring.order_lists ( order_id );

CREATE INDEX idx_order_lists_0 ON credit_scoring.order_lists ( serial_number );

ALTER TABLE credit_scoring.bank_credit_request_forms ADD CONSTRAINT bank_credit_request_forms_ibfk_1 FOREIGN KEY ( b_client_id ) REFERENCES credit_scoring.clients( b_client_id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE credit_scoring.bank_credit_request_forms ADD CONSTRAINT store_id FOREIGN KEY ( store_id ) REFERENCES credit_scoring.partners_stores( store_id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE credit_scoring.order_lists ADD CONSTRAINT fk_order_lists FOREIGN KEY ( order_id ) REFERENCES credit_scoring.orders( order_id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE credit_scoring.order_lists ADD CONSTRAINT fk_order_lists_0 FOREIGN KEY ( serial_number ) REFERENCES credit_scoring.goods( serial_number ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE credit_scoring.orders ADD CONSTRAINT form_id FOREIGN KEY ( form_id ) REFERENCES credit_scoring.store_credit_request_forms( form_id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE credit_scoring.store_credit_request_forms ADD CONSTRAINT store_credit_request_forms_ibfk_1 FOREIGN KEY ( bank_id ) REFERENCES credit_scoring.partners_banks( bank_id ) ON DELETE NO ACTION ON UPDATE NO ACTION;

INSERT INTO credit_scoring.clients( b_client_id, full_name, passport_number, passport_issue_date, phone_number, black_list ) VALUES ( 0, 'Abel Warren', '4501 558352', '2014-08-15', '+7-348-254-5341', 1 ); 
INSERT INTO credit_scoring.clients( b_client_id, full_name, passport_number, passport_issue_date, phone_number, black_list ) VALUES ( 1, 'Erick Valentine', '4509 647226', '2011-04-01', '+7-457-437-1425', 0 ); 
INSERT INTO credit_scoring.clients( b_client_id, full_name, passport_number, passport_issue_date, phone_number, black_list ) VALUES ( 2, 'Janice Payne', '4506 771518', '2001-06-02', '+7-815-357-4418', 0 ); 
INSERT INTO credit_scoring.clients( b_client_id, full_name, passport_number, passport_issue_date, phone_number, black_list ) VALUES ( 3, 'Gretchen Mason', '4507 294544', '2016-02-08', '+7-093-838-3460', 0 ); 
INSERT INTO credit_scoring.clients( b_client_id, full_name, passport_number, passport_issue_date, phone_number, black_list ) VALUES ( 4, 'Lawanda Noble', '4506 544775', '2001-05-05', '+7-146-334-4737', 0 ); 
INSERT INTO credit_scoring.clients( b_client_id, full_name, passport_number, passport_issue_date, phone_number, black_list ) VALUES ( 5, 'Robbie Baird', '4508 368937', '2011-08-21', '+7-724-167-6328', 0 ); 
INSERT INTO credit_scoring.clients( b_client_id, full_name, passport_number, passport_issue_date, phone_number, black_list ) VALUES ( 6, 'Carla Compton', '4506 569666', '2015-05-13', '+7-474-455-7963', 0 ); 
INSERT INTO credit_scoring.clients( b_client_id, full_name, passport_number, passport_issue_date, phone_number, black_list ) VALUES ( 7, 'Heath Stafford', '4508 798849', '2011-07-03', '+7-438-324-1225', 0 ); 
INSERT INTO credit_scoring.clients( b_client_id, full_name, passport_number, passport_issue_date, phone_number, black_list ) VALUES ( 8, 'Kendra Stevenson', '4505 247469', '2004-07-18', '+7-208-727-9537', 0 ); 
INSERT INTO credit_scoring.clients( b_client_id, full_name, passport_number, passport_issue_date, phone_number, black_list ) VALUES ( 9, 'Brandie Chase', '4504 772761', '2017-01-17', '+7-566-542-5343', 1 ); 

INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 110436, 'Randal Jackson', 8516910.0, 9990 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 132142, 'Heath Stafford', 747938.0, 298 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 133763, 'Ruth Simmons', 4603100.0, 3196 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 147952, 'Lawanda Noble', 8571240.0, 2273 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 196895, 'Gretchen Mason', 9858770.0, 7681 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 221827, 'Elena Huber', 506272.0, 5110 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 258347, 'Rex Galloway', 1237240.0, 4193 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 283776, 'Morgan Simon', 7245870.0, 2186 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 329774, 'Colby Wilkerson', 5619450.0, 935 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 358165, 'Kristen Wilson', 2668270.0, 1691 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 361326, 'Robbie Baird', 9874210.0, 6603 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 377020, 'Moses Downs', 9639220.0, 8905 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 383631, 'Rose Kirk', 305132.0, 1527 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 387519, 'Cameron Miranda', 3523890.0, 1584 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 407324, 'Arnold French', 9326630.0, 4685 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 424235, 'Roberta Harrison', 9936870.0, 5490 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 486567, 'Emma Anthony', 2531140.0, 538 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 488006, 'Lillian Duran', 5822720.0, 2865 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 490625, 'Frances Keller', 1428650.0, 5011 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 511676, 'Arlene Andersen', 6166420.0, 5716 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 512208, 'Joni Roberts', 7976570.0, 2600 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 522718, 'Lucas Rivers', 327638.0, 7478 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 533875, 'Luz Olson', 1309260.0, 4983 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 565537, 'Ernest Lam', 6916550.0, 9102 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 567373, 'Carl Nunez', 2272670.0, 2830 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 590623, 'Dwight Patton', 1075750.0, 1254 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 604863, 'Dianna Oliver', 8512430.0, 1692 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 608341, 'Brandie Chase', 9495830.0, 9453 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 613551, 'Cornelius Johnson', 4759850.0, 4433 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 628424, 'Damien Massey', 7893420.0, 8994 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 633769, 'Ivan Humphrey', 8393600.0, 9611 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 637722, 'Ismael Holt', 567471.0, 5399 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 652324, 'Franklin Jones', 2326260.0, 5357 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 690233, 'Erick Valentine', 9014480.0, 710 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 700523, 'Janice Payne', 4968230.0, 671 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 707782, 'Elisabeth Cole', 3452930.0, 5582 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 723362, 'Teddy Hoover', 494115.0, 4128 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 763125, 'Caroline Nash', 7719260.0, 7320 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 775875, 'Carla Compton', 2281580.0, 8066 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 785721, 'Noah Nolan', 4679530.0, 8427 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 800523, 'Sheldon Stuart', 2476190.0, 6907 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 825414, 'Jami Cuevas', 579258.0, 3352 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 826505, 'Melissa Atkinson', 1531860.0, 9431 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 838865, 'Andre Bush', 6889950.0, 3338 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 853172, 'Abel Warren', 7311470.0, 7310 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 888763, 'Keri Williams', 4082850.0, 9774 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 919789, 'Bobbi Haynes', 5544080.0, 4514 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 934704, 'Geoffrey Aguirre', 2286740.0, 4874 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 960476, 'Kendra Stevenson', 7431580.0, 8111 ); 
INSERT INTO credit_scoring.goods( serial_number, name, price, amount_available ) VALUES ( 977298, 'Kathleen Novak', 6088950.0, 2541 ); 

INSERT INTO credit_scoring.partners_banks( bank_id, org_name, partnership_start, partnership_end, info ) VALUES ( 0, 'Банк1', '2014-08-16', null, 'John is walking. Tony is walking. ' ); 
INSERT INTO credit_scoring.partners_banks( bank_id, org_name, partnership_start, partnership_end, info ) VALUES ( 1, 'Банк4', '2005-11-13', null, null ); 
INSERT INTO credit_scoring.partners_banks( bank_id, org_name, partnership_start, partnership_end, info ) VALUES ( 2, 'Банк3', '2018-01-11', null, 'Anne bought new car. Anne has free time. ' ); 
INSERT INTO credit_scoring.partners_banks( bank_id, org_name, partnership_start, partnership_end, info ) VALUES ( 4, 'Банк5', '2009-12-08', null, null ); 
INSERT INTO credit_scoring.partners_banks( bank_id, org_name, partnership_start, partnership_end, info ) VALUES ( 7, 'Банк2', '2000-08-31', null, 'Anne has free time. Anne bought new car. Tony bought new car. Tony is walking. John bought new car. ' ); 

INSERT INTO credit_scoring.partners_stores( store_id, org_name, partnership_start, partnership_end, info ) VALUES ( 0, 'Магазин1', '2014-08-16', '2011-04-01', 'John is walking. Tony is walking. ' ); 
INSERT INTO credit_scoring.partners_stores( store_id, org_name, partnership_start, partnership_end, info ) VALUES ( 1, 'Магазин4', '2005-11-13', null, null ); 
INSERT INTO credit_scoring.partners_stores( store_id, org_name, partnership_start, partnership_end, info ) VALUES ( 2, 'Магазин3', '2018-01-11', '2001-05-05', null ); 
INSERT INTO credit_scoring.partners_stores( store_id, org_name, partnership_start, partnership_end, info ) VALUES ( 4, 'Магазин5', '2009-12-08', '2011-07-03', null ); 
INSERT INTO credit_scoring.partners_stores( store_id, org_name, partnership_start, partnership_end, info ) VALUES ( 7, 'Магазин2', '2000-08-31', null, null ); 

INSERT INTO credit_scoring.store_credit_request_forms( form_id, status, bank_id, s_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number ) VALUES ( 0, '1', 1, 0, '2014-08-15', '2018-02-24', 7305198, 7307890.0, 'q', '+7-424-516-6082' ); 
INSERT INTO credit_scoring.store_credit_request_forms( form_id, status, bank_id, s_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number ) VALUES ( 1, '2', 0, 1, '2011-04-01', '2016-03-19', 882584, 5796250.0, 'a', '+7-827-925-5978' ); 
INSERT INTO credit_scoring.store_credit_request_forms( form_id, status, bank_id, s_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number ) VALUES ( 2, '2', 2, 2, '2001-06-02', '2004-05-09', 4889046, 7780120.0, 'm', '+7-393-857-4794' ); 
INSERT INTO credit_scoring.store_credit_request_forms( form_id, status, bank_id, s_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number ) VALUES ( 3, '2', 2, 3, '2016-02-08', '2005-09-08', 4618372, 1149970.0, 't', '+7-135-912-6578' ); 
INSERT INTO credit_scoring.store_credit_request_forms( form_id, status, bank_id, s_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number ) VALUES ( 4, '0', 7, 4, '2001-05-05', null, 4485984, 3379670.0, 'o', '+7-562-822-0555' ); 
INSERT INTO credit_scoring.store_credit_request_forms( form_id, status, bank_id, s_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number ) VALUES ( 5, '1', 0, 5, '2011-08-21', '2000-06-30', 6977124, 6790160.0, 'y', '+7-020-917-5874' ); 
INSERT INTO credit_scoring.store_credit_request_forms( form_id, status, bank_id, s_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number ) VALUES ( 6, '1', 7, 6, '2015-05-13', '2013-12-26', 2777673, 5422200.0, 'g', '+7-348-768-9707' ); 
INSERT INTO credit_scoring.store_credit_request_forms( form_id, status, bank_id, s_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number ) VALUES ( 7, '0', 1, 7, '2011-07-03', '2016-02-06', 7599608, 8948890.0, 'r', '+7-344-232-7068' ); 
INSERT INTO credit_scoring.store_credit_request_forms( form_id, status, bank_id, s_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number ) VALUES ( 8, '0', 4, 8, '2004-07-18', '2003-01-09', 2192445, 152073.0, 'r', '+7-411-516-6242' ); 
INSERT INTO credit_scoring.store_credit_request_forms( form_id, status, bank_id, s_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number ) VALUES ( 9, '2', 1, 9, '2017-01-17', '2018-06-29', 9204140, 9329150.0, 'd', '+7-106-932-2566' ); 

INSERT INTO credit_scoring.bank_credit_request_forms( form_id, store_id, b_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number, status, nginfo ) VALUES ( 0, 1, 5, '2014-08-15', '2018-02-24', 7305198, 7307890.0, 'q', '+7-560-482-3814', '1', null ); 
INSERT INTO credit_scoring.bank_credit_request_forms( form_id, store_id, b_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number, status, nginfo ) VALUES ( 1, 0, 8, '2011-04-01', '2016-03-19', 882584, 5796250.0, 'a', '+7-279-253-9783', '2', 'A2' ); 
INSERT INTO credit_scoring.bank_credit_request_forms( form_id, store_id, b_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number, status, nginfo ) VALUES ( 2, 2, 1, '2001-06-02', '2004-05-09', 4889046, 7780120.0, 'm', '+7-335-767-0228', '2', null ); 
INSERT INTO credit_scoring.bank_credit_request_forms( form_id, store_id, b_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number, status, nginfo ) VALUES ( 3, 2, 0, '2016-02-08', '2005-09-08', 4618372, 1149970.0, 't', null, '2', 'T' ); 
INSERT INTO credit_scoring.bank_credit_request_forms( form_id, store_id, b_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number, status, nginfo ) VALUES ( 4, 7, 6, '2001-05-05', null, 4485984, 3379670.0, 'o', '+7-204-053-7649', '0', null ); 
INSERT INTO credit_scoring.bank_credit_request_forms( form_id, store_id, b_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number, status, nginfo ) VALUES ( 5, 0, 7, '2011-08-21', '2000-06-30', 6977124, 6790160.0, 'y', '+7-182-205-5146', '1', null ); 
INSERT INTO credit_scoring.bank_credit_request_forms( form_id, store_id, b_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number, status, nginfo ) VALUES ( 6, 7, 1, '2015-05-13', '2013-12-26', 2777673, 5422200.0, 'g', '+7-392-181-1075', '1', null ); 
INSERT INTO credit_scoring.bank_credit_request_forms( form_id, store_id, b_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number, status, nginfo ) VALUES ( 7, 1, 0, '2011-07-03', '2016-02-06', 7599608, 8948890.0, 'r', '+7-768-970-5923', '0', null ); 
INSERT INTO credit_scoring.bank_credit_request_forms( form_id, store_id, b_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number, status, nginfo ) VALUES ( 8, 4, 7, '2004-07-18', '2003-01-09', 2192445, 152073.0, 'r', '+7-215-466-7269', '0', null ); 
INSERT INTO credit_scoring.bank_credit_request_forms( form_id, store_id, b_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number, status, nginfo ) VALUES ( 9, 1, 1, '2017-01-17', '2018-06-29', 9204140, 9329150.0, 'd', null, '2', 'A2' ); 
INSERT INTO credit_scoring.bank_credit_request_forms( form_id, store_id, b_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number, status, nginfo ) VALUES ( 10, 0, 1, '2013-03-16', '2015-04-11', 8860558, 5193950.0, 'd', '+7-484-027-1574', '2', 'BL' ); 
INSERT INTO credit_scoring.bank_credit_request_forms( form_id, store_id, b_client_id, date_opened, date_current_status, monies_amount, income_per_year, income_source, phone_number, status, nginfo ) VALUES ( 11, 0, 6, '2007-01-21', '2000-01-25', 2220016, 5661390.0, 't', '+7-212-666-0370', '2', 'T' ); 

INSERT INTO credit_scoring.orders( order_id, form_id, s_client_id, payment_method, status, monies_amount, date_opened, date_closed ) VALUES ( 0, 8, 0, 0, '2', 7305200.0, '2014-08-13', '2012-10-08' ); 
INSERT INTO credit_scoring.orders( order_id, form_id, s_client_id, payment_method, status, monies_amount, date_opened, date_closed ) VALUES ( 1, 5, 1, 1, '2', 882584.0, '2007-05-23', '2000-03-11' ); 
INSERT INTO credit_scoring.orders( order_id, form_id, s_client_id, payment_method, status, monies_amount, date_opened, date_closed ) VALUES ( 2, 9, 2, 1, '0', 4889050.0, '2011-08-05', '2009-10-23' ); 
INSERT INTO credit_scoring.orders( order_id, form_id, s_client_id, payment_method, status, monies_amount, date_opened, date_closed ) VALUES ( 3, 9, 3, 0, '1', 4618370.0, '2004-03-03', '2014-11-07' ); 
INSERT INTO credit_scoring.orders( order_id, form_id, s_client_id, payment_method, status, monies_amount, date_opened, date_closed ) VALUES ( 4, 0, 4, 1, '1', 4485980.0, '2015-07-24', '2011-05-20' ); 
INSERT INTO credit_scoring.orders( order_id, form_id, s_client_id, payment_method, status, monies_amount, date_opened, date_closed ) VALUES ( 5, 1, 5, 0, '2', 6977120.0, '2015-04-08', '2019-01-20' ); 
INSERT INTO credit_scoring.orders( order_id, form_id, s_client_id, payment_method, status, monies_amount, date_opened, date_closed ) VALUES ( 6, 7, 6, 0, '2', 2777670.0, '2002-04-20', '2005-01-19' ); 
INSERT INTO credit_scoring.orders( order_id, form_id, s_client_id, payment_method, status, monies_amount, date_opened, date_closed ) VALUES ( 7, 3, 7, 1, '1', 7599610.0, '2004-01-06', '2013-12-06' ); 
INSERT INTO credit_scoring.orders( order_id, form_id, s_client_id, payment_method, status, monies_amount, date_opened, date_closed ) VALUES ( 8, 6, 8, 0, '1', 2192440.0, '2006-10-04', null ); 
INSERT INTO credit_scoring.orders( order_id, form_id, s_client_id, payment_method, status, monies_amount, date_opened, date_closed ) VALUES ( 9, 8, 9, 0, '1', 9204140.0, '2012-10-18', '2018-07-29' ); 

INSERT INTO credit_scoring.order_lists( order_id, serial_number, quantity ) VALUES ( 0, 329774, 9 ); 
INSERT INTO credit_scoring.order_lists( order_id, serial_number, quantity ) VALUES ( 1, 838865, 10 ); 
INSERT INTO credit_scoring.order_lists( order_id, serial_number, quantity ) VALUES ( 2, 608341, 9 ); 
INSERT INTO credit_scoring.order_lists( order_id, serial_number, quantity ) VALUES ( 3, 383631, 4 ); 
INSERT INTO credit_scoring.order_lists( order_id, serial_number, quantity ) VALUES ( 4, 424235, 6 ); 
INSERT INTO credit_scoring.order_lists( order_id, serial_number, quantity ) VALUES ( 5, 888763, 1 ); 
INSERT INTO credit_scoring.order_lists( order_id, serial_number, quantity ) VALUES ( 6, 707782, 2 ); 
INSERT INTO credit_scoring.order_lists( order_id, serial_number, quantity ) VALUES ( 7, 490625, 5 ); 
INSERT INTO credit_scoring.order_lists( order_id, serial_number, quantity ) VALUES ( 8, 690233, 3 ); 
INSERT INTO credit_scoring.order_lists( order_id, serial_number, quantity ) VALUES ( 9, 522718, 7 ); 

