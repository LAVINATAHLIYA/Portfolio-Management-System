CREATE DATABASE StockMarketDB;
USE StockMarketDB;

-- Users Table
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stocks Table
CREATE TABLE Stocks (
    stock_id INT PRIMARY KEY AUTO_INCREMENT,
    stock_name VARCHAR(255) NOT NULL,
    NSE_code VARCHAR(20) UNIQUE,
    BSE_code INT UNIQUE,
    ISIN VARCHAR(20) UNIQUE NOT NULL,
    industry_name VARCHAR(255) NOT NULL,
    sector_name VARCHAR(255) NOT NULL
);

-- Stock Prices Table
CREATE TABLE Stock_Prices (
    price_id INT PRIMARY KEY AUTO_INCREMENT,
    stock_id INT,
    current_price DECIMAL(10,2) NOT NULL,
    market_cap DECIMAL(15,2) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stock_id) REFERENCES Stocks(stock_id) ON DELETE CASCADE
);

-- Portfolios Table
CREATE TABLE Portfolios (
    portfolio_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    portfolio_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Portfolio Transactions Table
CREATE TABLE Portfolio_Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    portfolio_id INT,
    stock_id INT,
    transaction_type ENUM('Buy', 'Sell') NOT NULL,
    transaction_date DATE NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    price_per_unit DECIMAL(10,2) NOT NULL,
    total_cost DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (portfolio_id) REFERENCES Portfolios(portfolio_id) ON DELETE CASCADE,
    FOREIGN KEY (stock_id) REFERENCES Stocks(stock_id) ON DELETE CASCADE
);

-- Financials Table (Optional for advanced analysis)
CREATE TABLE Financials (
    finance_id INT PRIMARY KEY AUTO_INCREMENT,
    stock_id INT,
    revenue_qtr DECIMAL(15,2),
    net_profit_qtr DECIMAL(15,2),
    revenue_growth_qtr_yoy DECIMAL(5,2),
    net_profit_growth_qtr_yoy DECIMAL(5,2),
    FOREIGN KEY (stock_id) REFERENCES Stocks(stock_id) ON DELETE CASCADE
);

-- Valuation Table (Optional for advanced analysis)
CREATE TABLE Valuation (
    valuation_id INT PRIMARY KEY AUTO_INCREMENT,
    stock_id INT,
    PE_TTM DECIMAL(5,2),
    price_to_book DECIMAL(5,2),
    FOREIGN KEY (stock_id) REFERENCES Stocks(stock_id) ON DELETE CASCADE
);

-- Performance Table (Optional for advanced analysis)
CREATE TABLE Performance (
    performance_id INT PRIMARY KEY AUTO_INCREMENT,
    stock_id INT,
    ROE_annual DECIMAL(5,2),
    ROA_annual DECIMAL(5,2),
    FOREIGN KEY (stock_id) REFERENCES Stocks(stock_id) ON DELETE CASCADE
);

-- Shareholding Table (Optional for advanced analysis)
CREATE TABLE Shareholding (
    shareholding_id INT PRIMARY KEY AUTO_INCREMENT,
    stock_id INT,
    promoter_holding DECIMAL(5,2),
    mf_holding DECIMAL(5,2),
    FOREIGN KEY (stock_id) REFERENCES Stocks(stock_id) ON DELETE CASCADE
);

-- Trading Volumes Table (Optional for advanced analysis)
CREATE TABLE Trading_Volumes (
    volume_id INT PRIMARY KEY AUTO_INCREMENT,
    stock_id INT,
    day_volume BIGINT,
    FOREIGN KEY (stock_id) REFERENCES Stocks(stock_id) ON DELETE CASCADE
);



select * from Portfolio_Transactions;
DROP TABLE IF EXISTS Stock_Prices;

SELECT s.stock_name, pt.quantity, pt.price_per_unit, sp.current_price
FROM Portfolio_Transactions pt
JOIN Stocks s ON pt.stock_id = s.stock_id
JOIN Stock_Prices sp ON s.stock_id = sp.stock_id
WHERE pt.portfolio_id = 2;

INSERT INTO Stocks (stock_name, NSE_code, BSE_code, ISIN, industry_name, sector_name) VALUES
('HDFC Bank', 'HDFCBANK', 500180, 'INE040A01034', 'Banking', 'Financial Services'),
('Infosys', 'INFY', 500209, 'INE009A01021', 'IT Services', 'Technology'),
('Tata Steel', 'TATASTEEL', 500470, 'INE081A01020', 'Steel', 'Metals & Mining'),
('ICICI Bank', 'ICICIBANK', 532174, 'INE090A01021', 'Banking', 'Financial Services'),
('Bharti Airtel', 'BHARTIARTL', 532454, 'INE397D01024', 'Telecommunications', 'Telecom');

INSERT INTO Stock_Prices (stock_id, current_price, market_cap) VALUES
(1, 1550.00, 8000000000000.00),  -- HDFC Bank
(2, 1750.25, 7000000000000.00),  -- Infosys
(3, 1300.75, 6500000000000.00),  -- Tata Steel
(4, 1050.50, 9000000000000.00),  -- ICICI Bank
(5, 880.40, 5000000000000.00);   -- Bharti Airtel

INSERT INTO Portfolio_Transactions 
(portfolio_id, stock_id, transaction_type, transaction_date, quantity, price_per_unit, total_cost) 
VALUES
(1, 1, 'Buy', '2024-01-15', 10, 1500.00, 15000.00), -- Rahul bought HDFC Bank
(1, 3, 'Buy', '2024-02-05', 15, 1250.00, 18750.00), -- Rahul bought Tata Steel
(2, 2, 'Buy', '2024-01-10', 20, 1700.00, 34000.00), -- Ananya bought Infosys
(2, 4, 'Buy', '2024-03-01', 10, 1025.00, 10250.00), -- Ananya bought ICICI Bank
(1, 5, 'Buy', '2024-02-20', 12, 850.00, 10200.00);  -- Rahul bought Bharti Airtel


INSERT INTO Financials (stock_id, revenue_qtr, net_profit_qtr, revenue_growth_qtr_yoy, net_profit_growth_qtr_yoy) VALUES
(1, 45000000000.00, 12000000000.00, 7.5, 10.0),  -- HDFC Bank
(2, 50000000000.00, 15000000000.00, 6.8, 12.0),  -- Infosys
(3, 30000000000.00, 5000000000.00, 5.0, 7.5),    -- Tata Steel
(4, 48000000000.00, 13000000000.00, 8.2, 9.8),   -- ICICI Bank
(5, 25000000000.00, 4000000000.00, 4.5, 6.0);    -- Bharti Airtel

INSERT INTO Valuation (stock_id, PE_TTM, price_to_book) VALUES
(1, 20.5, 3.8),  -- HDFC Bank
(2, 28.2, 4.2),  -- Infosys
(3, 15.6, 2.1),  -- Tata Steel
(4, 22.4, 3.5),  -- ICICI Bank
(5, 18.0, 2.9);  -- Bharti Airtel
INSERT INTO Performance (stock_id, ROE_annual, ROA_annual) VALUES
(1, 17.5, 12.0),  -- HDFC Bank
(2, 24.3, 15.2),  -- Infosys
(3, 10.5, 7.8),   -- Tata Steel
(4, 19.8, 14.1),  -- ICICI Bank
(5, 12.4, 8.6);   -- Bharti Airtel
INSERT INTO Shareholding (stock_id, promoter_holding, mf_holding) VALUES
(1, 26.0, 18.5),  -- HDFC Bank
(2, 28.5, 20.0),  -- Infosys
(3, 29.2, 17.8),  -- Tata Steel
(4, 24.7, 16.3),  -- ICICI Bank
(5, 32.0, 21.4);  -- Bharti Airtel
INSERT INTO Trading_Volumes (stock_id, day_volume) VALUES
(1, 500000),  -- HDFC Bank
(2, 350000),  -- Infosys
(3, 420000),  -- Tata Steel
(4, 600000),  -- ICICI Bank
(5, 300000);  -- Bharti Airtel
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Portfolio_Transactions;
TRUNCATE TABLE Portfolios;
TRUNCATE TABLE Stock_Prices;
TRUNCATE TABLE Stocks;
TRUNCATE TABLE Financials;
TRUNCATE TABLE Valuation;
TRUNCATE TABLE Performance;
TRUNCATE TABLE Shareholding;
TRUNCATE TABLE Trading_Volumes;
TRUNCATE TABLE Users;
SET FOREIGN_KEY_CHECKS = 1;
select * FROM Users;
SELECT  * FROM Stocks;
SELECT * FROM Stock_Prices;
SELECT * FROM Portfolios;
SELECT * FROM Portfolio_Transactions;
SELECT  * FROM Financials;
SELECT * FROM Valuation;
SELECT * FROM Performance;
SELECT * FROM Shareholding;
SELECT * FROM Trading_Volumes;

ALTER TABLE Portfolios ADD COLUMN total_investment DECIMAL(10,2) DEFAULT 0;
ALTER TABLE Portfolios ADD COLUMN total_profit DECIMAL(10,2) DEFAULT 0;

DELIMITER //

CREATE TRIGGER before_user_insert
BEFORE INSERT ON Users
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.password_hash) < 8 OR 
    NEW.password_hash NOT REGEXP '[!@#$%^&*(),.?":{}|<>]' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Password must be at least 8 characters long and contain at least one special character!';
    END IF;
END;
//

DELIMITER ;

SELECT COUNT(*) FROM Stocks;
SELECT s.stock_name, sp.current_price 
FROM Stocks s 
JOIN Stock_Prices sp ON s.stock_id = sp.stock_id;

DELIMITER $$

CREATE PROCEDURE add_stock(
    IN p_user_id INT,
    IN p_stock_name VARCHAR(255),
    IN p_purchase_price DECIMAL(10,2),
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock_id INT;
    DECLARE v_portfolio_id INT;

    -- Check if stock exists
    SELECT stock_id INTO v_stock_id FROM Stocks WHERE stock_name = p_stock_name;
    IF v_stock_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock not found!';
    END IF;

    -- Get user's portfolio ID
    SELECT portfolio_id INTO v_portfolio_id FROM Portfolios WHERE user_id = p_user_id;

    -- Insert Buy Transaction
    INSERT INTO Portfolio_Transactions (portfolio_id, stock_id, transaction_type, transaction_date, quantity, price_per_unit, total_cost)
    VALUES (v_portfolio_id, v_stock_id, 'Buy', CURDATE(), p_quantity, p_purchase_price, p_purchase_price * p_quantity);
END $$

DELIMITER ;


DELIMITER $$

CREATE FUNCTION calculate_profit_loss(p_user_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_portfolio_id INT;
    DECLARE v_total_profit_loss DECIMAL(10,2);

    -- Get portfolio ID
    SELECT portfolio_id INTO v_portfolio_id FROM Portfolios WHERE user_id = p_user_id;

    -- Calculate total profit/loss
    SELECT IFNULL(SUM(CASE 
        WHEN transaction_type = 'Sell' THEN total_cost 
        WHEN transaction_type = 'Buy' THEN -total_cost 
        ELSE 0 END), 0)
    INTO v_total_profit_loss
    FROM Portfolio_Transactions 
    WHERE portfolio_id = v_portfolio_id;

    RETURN v_total_profit_loss;
END $$

DELIMITER ;

CREATE VIEW stock_profit_loss AS
SELECT 
    p.user_id,
    s.stock_name,
    SUM(CASE WHEN pt.transaction_type = 'Buy' THEN pt.total_cost ELSE 0 END) AS total_bought,
    SUM(CASE WHEN pt.transaction_type = 'Sell' THEN pt.total_cost ELSE 0 END) AS total_sold,
    SUM(CASE WHEN pt.transaction_type = 'Sell' THEN pt.total_cost ELSE 0 END) - 
    SUM(CASE WHEN pt.transaction_type = 'Buy' THEN pt.total_cost ELSE 0 END) AS profit_loss
FROM Portfolio_Transactions pt
JOIN Portfolios p ON pt.portfolio_id = p.portfolio_id
JOIN Stocks s ON pt.stock_id = s.stock_id
GROUP BY p.user_id, s.stock_name;

ALTER TABLE Portfolios MODIFY portfolio_name VARCHAR(255) DEFAULT 'My Portfolio';



SELECT * FROM Transaction;

-- Additional Stocks
INSERT INTO Stocks (stock_name, NSE_code, BSE_code, ISIN, industry_name, sector_name) VALUES
('Reliance Industries', 'RELIANCE', 500325, 'INE002A01018', 'Conglomerate', 'Diversified'),
('TCS', 'TCS', 532540, 'INE467B01029', 'IT Services', 'Technology'),
('HUL', 'HINDUNILVR', 500696, 'INE030A01027', 'FMCG', 'Consumer Goods'),
('ITC', 'ITC', 500875, 'INE154A01025', 'FMCG', 'Consumer Goods'),
('SBI', 'SBIN', 500112, 'INE062A01020', 'Banking', 'Financial Services'),
('Wipro', 'WIPRO', 507685, 'INE075A01022', 'IT Services', 'Technology'),
('HCL Tech', 'HCLTECH', 532281, 'INE860A01027', 'IT Services', 'Technology'),
('Bajaj Finance', 'BAJFINANCE', 500034, 'INE296A01024', 'NBFC', 'Financial Services'),
('Asian Paints', 'ASIANPAINT', 500820, 'INE021A01026', 'Paints', 'Chemicals'),
('Nestle India', 'NESTLEIND', 500790, 'INE239A01016', 'FMCG', 'Consumer Goods');

-- Additional Stock Prices
INSERT INTO Stock_Prices (stock_id, current_price, market_cap) VALUES
(6, 2850.00, 18000000000000.00),  -- Reliance Industries
(7, 3800.50, 14000000000000.00),  -- TCS
(8, 2450.75, 5500000000000.00),   -- HUL
(9, 420.25, 3500000000000.00),    -- ITC
(10, 650.80, 5000000000000.00),   -- SBI
(11, 480.60, 2500000000000.00),   -- Wipro
(12, 1250.30, 3500000000000.00),  -- HCL Tech
(13, 7800.00, 4500000000000.00),  -- Bajaj Finance
(14, 3200.50, 3000000000000.00),  -- Asian Paints
(15, 21500.00, 2000000000000.00); -- Nestle India

-- Additional Portfolio Transactions
INSERT INTO Portfolio_Transactions 
(portfolio_id, stock_id, transaction_type, transaction_date, quantity, price_per_unit, total_cost) 
VALUES
(1, 6, 'Buy', '2024-03-10', 5, 2800.00, 14000.00),    -- Rahul bought Reliance
(1, 8, 'Buy', '2024-03-15', 8, 2400.00, 19200.00),    -- Rahul bought HUL
(2, 7, 'Buy', '2024-02-20', 3, 3750.00, 11250.00),    -- Ananya bought TCS
(2, 10, 'Buy', '2024-03-05', 15, 620.00, 9300.00),    -- Ananya bought SBI
(1, 12, 'Buy', '2024-01-25', 10, 1200.00, 12000.00),  -- Rahul bought HCL Tech
(2, 14, 'Buy', '2024-02-10', 6, 3100.00, 18600.00),   -- Ananya bought Asian Paints
(1, 15, 'Buy', '2024-03-01', 2, 21000.00, 42000.00), -- Rahul bought Nestle
(2, 9, 'Buy', '2024-01-30', 20, 400.00, 8000.00),    -- Ananya bought ITC
(1, 11, 'Buy', '2024-02-15', 12, 470.00, 5640.00),   -- Rahul bought Wipro
(2, 13, 'Buy', '2024-03-20', 4, 7700.00, 30800.00);  -- Ananya bought Bajaj Finance

-- Additional Financials
INSERT INTO Financials (stock_id, revenue_qtr, net_profit_qtr, revenue_growth_qtr_yoy, net_profit_growth_qtr_yoy) VALUES
(6, 220000000000.00, 18000000000.00, 12.5, 15.0),   -- Reliance
(7, 55000000000.00, 12000000000.00, 8.5, 10.2),     -- TCS
(8, 12000000000.00, 2200000000.00, 6.2, 8.5),       -- HUL
(9, 15000000000.00, 4000000000.00, 5.8, 7.2),       -- ITC
(10, 90000000000.00, 10000000000.00, 9.5, 12.0),    -- SBI
(11, 22000000000.00, 3500000000.00, 4.5, 6.0),      -- Wipro
(12, 28000000000.00, 5000000000.00, 7.8, 9.5),      -- HCL Tech
(13, 12000000000.00, 3000000000.00, 25.0, 30.0),    -- Bajaj Finance
(14, 7000000000.00, 1200000000.00, 10.5, 12.8),     -- Asian Paints
(15, 4500000000.00, 800000000.00, 8.8, 10.5);       -- Nestle

-- Additional Valuation
INSERT INTO Valuation (stock_id, PE_TTM, price_to_book) VALUES
(6, 25.8, 2.8),   -- Reliance
(7, 32.5, 15.2),  -- TCS
(8, 60.2, 20.5),  -- HUL
(9, 25.0, 6.8),   -- ITC
(10, 12.5, 1.8),  -- SBI
(11, 20.8, 3.5),  -- Wipro
(12, 25.6, 5.2),  -- HCL Tech
(13, 45.2, 12.5), -- Bajaj Finance
(14, 75.0, 25.8), -- Asian Paints
(15, 85.2, 35.4); -- Nestle

-- Additional Performance
INSERT INTO Performance (stock_id, ROE_annual, ROA_annual) VALUES
(6, 12.8, 8.5),   -- Reliance
(7, 35.2, 20.5),  -- TCS
(8, 65.8, 25.4),  -- HUL
(9, 28.5, 15.2),  -- ITC
(10, 14.2, 0.9),  -- SBI
(11, 18.5, 12.8), -- Wipro
(12, 30.2, 18.5), -- HCL Tech
(13, 22.8, 4.5),  -- Bajaj Finance
(14, 32.5, 20.8), -- Asian Paints
(15, 95.2, 25.8); -- Nestle

-- Additional Shareholding
INSERT INTO Shareholding (stock_id, promoter_holding, mf_holding) VALUES
(6, 50.2, 15.8),  -- Reliance
(7, 72.5, 8.5),   -- TCS
(8, 62.8, 12.5),  -- HUL
(9, 0.0, 25.8),   -- ITC (no promoter)
(10, 58.5, 18.2), -- SBI
(11, 74.2, 10.5), -- Wipro
(12, 60.8, 15.2), -- HCL Tech
(13, 55.5, 20.8), -- Bajaj Finance
(14, 65.2, 18.5), -- Asian Paints
(15, 62.8, 15.8); -- Nestle

-- Additional Trading Volumes
INSERT INTO Trading_Volumes (stock_id, day_volume) VALUES
(6, 1200000),  -- Reliance
(7, 800000),   -- TCS
(8, 450000),   -- HUL
(9, 950000),   -- ITC
(10, 1500000), -- SBI
(11, 600000),  -- Wipro
(12, 750000),  -- HCL Tech
(13, 350000),  -- Bajaj Finance
(14, 280000),  -- Asian Paints
(15, 150000);  -- Nestle











