-- Create Region table
CREATE TABLE Region (
    RegionID INT AUTO_INCREMENT PRIMARY KEY,
    RegionName VARCHAR(100) NOT NULL
);

-- Insert distinct RegionName from sales table into Region table
INSERT INTO Region (RegionName)
SELECT DISTINCT RegionName
FROM sales
WHERE RegionName IS NOT NULL;




-- Country Table
CREATE TABLE Country (
    CountryID INT auto_increment PRIMARY KEY,
    CountryName VARCHAR(100) NOT NULL,
    RegionID INT,
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);


INSERT INTO Country (CountryName, RegionID)
SELECT DISTINCT s.CountryName, r.RegionID
FROM sales s
JOIN Region r ON s.RegionName = r.RegionName
WHERE s.CountryName IS NOT NULL;

-- State/Province Table
CREATE TABLE StateProvince (
    StateID INT auto_increment PRIMARY KEY,
    StateName VARCHAR(100) NOT NULL,
    CountryID INT,
    FOREIGN KEY (CountryID) REFERENCES Country(CountryID)
);

INSERT INTO StateProvince (StateName, CountryID)
SELECT DISTINCT s.State, c.CountryID
FROM sales s
JOIN Country c ON s.CountryName = c.CountryName
WHERE s.State IS NOT NULL;

-- City Table
CREATE TABLE City (
    CityID INT auto_increment PRIMARY KEY,
    CityName VARCHAR(100) NOT NULL,
    StateID INT,
    FOREIGN KEY (StateID) REFERENCES StateProvince(StateID)
);

INSERT INTO City (CityName, StateID)
SELECT DISTINCT s.City, sp.StateID
FROM sales s
JOIN StateProvince sp ON s.State = sp.StateName
WHERE s.City IS NOT NULL;



-- Warehouse Table
CREATE TABLE Warehouse (
    WarehouseID INT auto_increment PRIMARY KEY,
    WarehouseAddress VARCHAR(255) NOT NULL,
    WarehouseName VARCHAR(100) NOT NULL,
    PostalCode VARCHAR(20),
    CityID INT,
    FOREIGN KEY (CityID) REFERENCES City(CityID)
);
INSERT INTO Warehouse (WarehouseName, WarehouseAddress, PostalCode, CityID)
SELECT DISTINCT s.WarehouseName, s.WarehouseAddress, s.PostalCode, c.CityID
FROM sales s
JOIN City c ON s.City = c.CityName
WHERE s.WarehouseName IS NOT NULL;

-- Employee Table
CREATE TABLE Employee (
    EmployeeID INT auto_increment PRIMARY KEY,
    EmployeeName VARCHAR(100) NOT NULL,
    EmployeeEmail VARCHAR(100),
    EmployeePhone VARCHAR(20),
    EmployeeHireDate DATE,
    EmployeeJobTitle VARCHAR(100),
    WarehouseID INT,
    FOREIGN KEY (WarehouseID) REFERENCES Warehouse(WarehouseID)
);
INSERT INTO Employee (EmployeeName, EmployeeEmail, EmployeePhone, EmployeeHireDate, EmployeeJobTitle, WarehouseID)
SELECT DISTINCT s.EmployeeName, s.EmployeeEmail, s.EmployeePhone, 
       STR_TO_DATE(s.EmployeeHireDate, '%d-%b-%y'), -- Convert the date format
       s.EmployeeJobTitle, w.WarehouseID
FROM sales s
JOIN Warehouse w ON s.WarehouseName = w.WarehouseName
WHERE s.EmployeeName IS NOT NULL;




-- Customer Table
CREATE TABLE Customer (
    CustomerID INT auto_increment PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    CustomerAddress VARCHAR(255) NOT NULL,
    CustomerCreditLimit DECIMAL(10,2),
    CustomerEmail VARCHAR(100),
    CustomerPhone VARCHAR(20),
    CityID INT,
    FOREIGN KEY (CityID) REFERENCES City(CityID)
);

INSERT INTO Customer (CustomerName, CustomerAddress, CustomerCreditLimit, CustomerEmail, CustomerPhone, CityID)
SELECT DISTINCT s.CustomerName, s.CustomerAddress, s.CustomerCreditLimit, s.CustomerEmail, s.CustomerPhone, c.CityID
FROM sales s
JOIN City c ON s.City = c.CityName
WHERE s.CustomerName IS NOT NULL;

-- Product Table
CREATE TABLE Product (
    ProductID INT auto_increment PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    ProductDescription TEXT,
    ProductStandardCost DECIMAL(10,2) NOT NULL,
    Profit DECIMAL(10,2) NOT NULL,
    ProductListPrice DECIMAL(10,2) NOT NULL,
    CategoryName VARCHAR(50) 
);

INSERT INTO Product (ProductName, ProductDescription, ProductStandardCost, Profit, ProductListPrice, CategoryName)
SELECT DISTINCT s.ProductName, s.ProductDescription, s.ProductStandardCost, s.Profit, s.ProductListPrice, s.CategoryName
FROM sales s
WHERE s.ProductName IS NOT NULL;


-- Order Table
CREATE TABLE `Order` (
    OrderID INT auto_increment PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerID INT,
    Status VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

INSERT INTO `Order` (OrderDate, CustomerID, Status)
SELECT DISTINCT 
    STR_TO_DATE(s.OrderDate, '%d-%b-%y'), -- Convert the date format
    c.CustomerID, 
    s.Status
FROM sales s
JOIN Customer c ON s.CustomerName = c.CustomerName
WHERE s.OrderDate IS NOT NULL;



-- OrderItem Table
CREATE TABLE OrderItem (
    OrderItemID INT auto_increment PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    OrderItemQuantity INT NOT NULL,
    PerUnitPrice DECIMAL(10,2) NOT NULL,
    TotalItemQuantity INT NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES `Order`(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

INSERT INTO OrderItem (OrderID, ProductID, OrderItemQuantity, PerUnitPrice, TotalItemQuantity)
SELECT DISTINCT o.OrderID, p.ProductID, s.OrderItemQuantity, s.PerUnitPrice, s.TotalItemQuantity
FROM sales s
JOIN `Order` o 
    ON STR_TO_DATE(s.OrderDate, '%d-%b-%y') = o.OrderDate 
    AND s.CustomerName = (SELECT c.CustomerName FROM Customer c WHERE c.CustomerID = o.CustomerID)
JOIN Product p 
    ON s.ProductName = p.ProductName
WHERE s.OrderItemQuantity IS NOT NULL;

-- Foreign Key Indexes
CREATE INDEX idx_country_regionid ON Country (RegionID);
CREATE INDEX idx_stateprovince_countryid ON StateProvince (CountryID);
CREATE INDEX idx_city_stateid ON City (StateID);
CREATE INDEX idx_warehouse_cityid ON Warehouse (CityID);
CREATE INDEX idx_employee_warehouseid ON Employee (WarehouseID);
CREATE INDEX idx_customer_cityid ON Customer (CityID);
CREATE INDEX idx_order_customerid ON `Order` (CustomerID);
CREATE INDEX idx_orderitem_orderid ON OrderItem (OrderID);
CREATE INDEX idx_orderitem_productid ON OrderItem (ProductID);

-- Filtering/Searching Indexes
CREATE INDEX idx_region_regionname ON Region (RegionName);
CREATE INDEX idx_country_countryname ON Country (CountryName);
CREATE INDEX idx_stateprovince_statename ON StateProvince (StateName);
CREATE INDEX idx_city_cityname ON City (CityName);
CREATE INDEX idx_warehouse_warehousename ON Warehouse (WarehouseName);
CREATE INDEX idx_warehouse_postalcode ON Warehouse (PostalCode);  
CREATE INDEX idx_employee_employeename ON Employee (EmployeeName);
CREATE INDEX idx_customer_customername ON Customer (CustomerName);
CREATE INDEX idx_product_productname ON Product (ProductName);
CREATE INDEX idx_order_orderdate ON `Order` (OrderDate); 

