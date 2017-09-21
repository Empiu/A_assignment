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

