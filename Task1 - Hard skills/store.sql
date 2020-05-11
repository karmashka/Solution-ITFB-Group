drop table if exists transaction_product;
drop table if exists product;
drop table if exists provider;
drop table if exists trademark;
drop table if exists transaction;
drop table if exists buyers;

CREATE TABLE provider (
    id SERIAL PRIMARY KEY,
    company_name text UNIQUE NOT NULL CHECK (company_name != ''),
    phonenumber text NOT NULL
);

CREATE TABLE trademark (
    id SERIAL PRIMARY KEY,
    trademark_name text NOT NULL,
    producer text NOT NULL,
    product_type text NOT NULL
);

CREATE TABLE product (
    id SERIAL PRIMARY KEY,
    provider_id INTEGER REFERENCES provider(id) ON UPDATE CASCADE ON DELETE SET NULL,
    price INTEGER CHECK (price > 0) NOT NULL,
    trademark_id INTEGER REFERENCES trademark(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    lot_size INTEGER NOT NULL CHECK (lot_size > 0),
    num_available INTEGER NOT NULL CHECK (num_available >= 0),
    arrival_date timestamp WITH time zone NOT NULL DEFAULT current_timestamp
);

CREATE TABLE buyers (
    id SERIAL PRIMARY KEY,
    name text NOT NULL,
    surname text NOT NULL,
    contact_number text
);

CREATE TABLE transaction (
    id SERIAL PRIMARY KEY,
    buyer_id INTEGER REFERENCES buyers(id) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    total_cost INTEGER NOT NULL CHECK (total_cost > 0) NOT NULL,
    time timestamp WITH time zone NOT NULL DEFAULT current_timestamp
);

CREATE TABLE transaction_product (
    transaction_id INTEGER REFERENCES transaction(id) NOT NULL, 
    product_id INTEGER REFERENCES product(id) ON UPDATE CASCADE NOT NULL,
    quantity INTEGER CHECK (quantity > 0) NOT NULL,
    PRIMARY KEY(transaction_id, product_id)
);

INSERT INTO trademark(trademark_name, producer, product_type) VALUES ('Увелка', 'ООО "Ресурс"', 'гречка'),
                                           ('Мелькруп', 'ООО "Селтинг"', 'гречка'),
                                           ('Увелка', 'ООО "Ресурс"', 'рис'),
                                           ('Гарнир', 'OOO "Гарнир"', 'гречка'), 
                                           ('Пластикс', '000 "Роспласт"', 'пакет маленький'),
                                           ('Мелькруп', 'ООО "Селтинг"', 'горох');

INSERT INTO provider (company_name, phonenumber) VALUES ('ООО Клиппер', '1 234 123 2324'),
                                            ('вкусноед', '+38 099 15 34 123'),
                                            ('ООО СМП Трейдинг', '+2 123 72 72 277');


INSERT INTO product(provider_id, price, trademark_id, lot_size, num_available) VALUES (2, 30, 1, 10, 10),
                                           (1, 92,  2, 20, 20),
                                           (3, 0.5, 5, 1000, 1000),
                                           (2, 25, 3, 20, 20),
                                           (1, 37, 4, 20, 20);

INSERT INTO buyers(name, surname, contact_number) VALUES ('Иван', 'Иванов', '+1 234 567 89 89'), 
                                                         ('Сергей', 'Петров', '+3 267 678 78 78'),
                                                         ('Анна', 'Пименова', '+8 562 326 23 67');

INSERT INTO transaction(buyer_id, total_cost) VALUES (1, 100), 
                                                     (2, 0.5), 
                                                     (3, 50),
                                                     (2, 0.5),
                                                     (1, 30);

INSERT INTO transaction_product(transaction_id, product_id, quantity) VALUES (1, 2, 1), 
                                                                             (1, 3, 16),
                                                                             (2, 3, 1),
                                                                             (3, 4, 2),
                                                                             (4, 3, 1),
                                                                             (5, 1, 1);
                                                                             


-- Requests

-- 1) Выбрать все марки гречки:
SELECT * FROM trademark WHERE product_type = 'гречка';
-- 2) Выбрать все транзакции с суммой менее 1 рубля:
SELECT * FROM transaction WHERE total_cost <= 1;
-- 3) Выбрать все транзакции постоянного покупателя Иванова:
SELECT * FROM transaction
JOIN (SELECT * FROM buyers WHERE surname = 'Иванов') AS buyer
ON buyer_id = buyer.id;
 -- 4) Выбрать топ-5 покупателей, которые совершили больше всего покупок:
SELECT * FROM buyers WHERE id IN (
	SELECT buyers.id FROM buyers
	JOIN transaction ON buyers.id = transaction.id
	GROUP BY buyers.id
	ORDER BY count(buyers.id) desc
	LIMIT 5
);
-- Сформировать выгрузку (отчет), в котором будет указано, сколько в среднем в месяц тратит Иванов в магазине:

SELECT AVG(s) FROM (SELECT sum(total_cost) as s FROM transaction
                    JOIN (SELECT * FROM buyers WHERE surname = 'Иванов') AS buyer
                    ON buyer_id = buyer.id 
                    GROUP BY date_trunc('month', time)) as sums_per_month;
    

