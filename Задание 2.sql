-- Задание 2.1
-- Выбор всех анкет определённого магазина-партнёра и отображение суммы кредита, статус (в процессе обработки/одобрен/отказ == 0/1/2), ФИО и номер телефона
SELECT ps.org_name, bcrf.monies_amount, bcrf.status, c.full_name, bcrf.phone_number
FROM credit_scoring.bank_credit_request_forms bcrf 
	INNER JOIN credit_scoring.partners_stores ps ON ( bcrf.store_id = ps.store_id  )  
	INNER JOIN credit_scoring.clients c ON ( bcrf.b_client_id = c.b_client_id  )  
WHERE ps.org_name = 'Магазин4'
	GROUP BY bcrf.monies_amount, bcrf.phone_number, bcrf.status, c.full_name;
-- Если заключить запрос в скобки и убрав лишнее взять от неё SELECT COUNT(*), в результате на выходе будет число записей по выбранному статусу
SELECT count(*) 
FROM credit_scoring.bank_credit_request_forms bcrf 
	INNER JOIN credit_scoring.partners_stores ps ON ( bcrf.store_id = ps.store_id  )  
WHERE ps.org_name = 'Магазин4';

SELECT ps.org_name, bcrf.monies_amount, bcrf.status, c.full_name, bcrf.phone_number
FROM credit_scoring.bank_credit_request_forms bcrf 
	INNER JOIN credit_scoring.partners_stores ps ON ( bcrf.store_id = ps.store_id  )  
	INNER JOIN credit_scoring.clients c ON ( bcrf.b_client_id = c.b_client_id  )  
WHERE bcrf.status = '1' AND
	ps.org_name = 'Магазин4'
	GROUP BY bcrf.monies_amount, bcrf.phone_number, bcrf.status, c.full_name;
	
-- Взяв сумму по таблице с денежными значениями SELECT sum(bcrf.monies_amount) получим общюю сумму выданных кредитов
    SELECT sum(bcrf.monies_amount)
    FROM credit_scoring.bank_credit_request_forms bcrf 
        INNER JOIN credit_scoring.partners_stores ps ON ( bcrf.store_id = ps.store_id  )  
    WHERE bcrf.status = '1' AND
        ps.org_name = 'Магазин4';
	
SELECT count(*) 
    FROM credit_scoring.bank_credit_request_forms bcrf 
        INNER JOIN credit_scoring.partners_stores ps ON ( bcrf.store_id = ps.store_id  )  
    WHERE bcrf.status = '1' AND
        ps.org_name = 'Магазин4'
	
SELECT ps.org_name, bcrf.monies_amount, bcrf.status, c.full_name, bcrf.phone_number
FROM credit_scoring.bank_credit_request_forms bcrf 
	INNER JOIN credit_scoring.partners_stores ps ON ( bcrf.store_id = ps.store_id  )  
	INNER JOIN credit_scoring.clients c ON ( bcrf.b_client_id = c.b_client_id  )  
WHERE bcrf.status = '2' AND
	ps.org_name = 'Магазин4'
	GROUP BY bcrf.monies_amount, bcrf.phone_number, bcrf.status, c.full_name
	
SELECT count(*) 
        FROM credit_scoring.bank_credit_request_forms bcrf 
            INNER JOIN credit_scoring.partners_stores ps ON ( bcrf.store_id = ps.store_id  )  
        WHERE bcrf.status = '1' AND
            ps.org_name = 'Магазин4';
            
-- Задание 2.2
/*Что бы получить статистику по всем заявкам от конкретного портнёра, достаточно запросить целиком таблицу 
в которую записываются параметры анкет (bank_credit_request_forms) и внутренний список клиентов банка (clients), 
с фильтром из таблицы партнёров (partners_stores)*/

SELECT bcrf.form_id, bcrf.store_id, bcrf.b_client_id, bcrf.date_opened, bcrf.date_current_status, bcrf.monies_amount, bcrf.income_per_year, bcrf.income_source, bcrf.phone_number, bcrf.status, bcrf.nginfo, ps.org_name, c.full_name, c.passport_number, c.black_list
FROM credit_scoring.bank_credit_request_forms bcrf 
	INNER JOIN credit_scoring.partners_stores ps ON ( bcrf.store_id = ps.store_id  )  
	INNER JOIN credit_scoring.clients c ON ( bcrf.b_client_id = c.b_client_id  )  
WHERE ps.org_name = 'Магазин4'
	GROUP BY bcrf.form_id, bcrf.store_id, bcrf.b_client_id, bcrf.date_opened, bcrf.date_current_status, bcrf.monies_amount, bcrf.income_per_year, bcrf.income_source, bcrf.phone_number, bcrf.status, bcrf.nginfo, ps.org_name, c.full_name, c.passport_number, c.black_list