IF NOT EXISTS (SELECT 1 from sysobjects where name='RewardCustomers' and xtype='U')
	CREATE TABLE RewardCustomers ([MemberId] VARCHAR(10) NOT NULL, FirstName VARCHAR(25), LastName VARCHAR(25), PRIMARY KEY (MemberId))
GO

IF ((SELECT COUNT(1) FROM RewardCustomers) = 0)
BEGIN
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('1320122100', 'David', 'Lee')
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('7611334511','John', 'West')
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('8549494944','Mary', 'Lynn')
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('5454667577','Will', 'Smith')
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('6523454446','Henry', 'Jackson')
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('4335353354','Susan', 'Pang')
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('5657677755','Moe', 'Williamson')
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('4648889113','Jack', 'Williamson')
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('5484873335','Hami', 'Young')
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('6543554443','Linda', 'Peters')
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('5325553353','Frank', 'Chang')
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('5325553303','Mike', 'Chang')
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('5325553323','Larry', 'Chang')
    INSERT INTO RewardCustomers(MemberId,FirstName,LastName) VALUES('5325553313','Hong', 'Chang')
END

IF NOT EXISTS (SELECT 1 from sysobjects where name='RewardCustomerPoints' and xtype='U')
	CREATE TABLE RewardCustomerPoints ([MemberId] VARCHAR(10) NOT NULL, [Points] INT, PRIMARY KEY (MemberId))
GO

IF ((SELECT COUNT(1) FROM RewardCustomerPoints) = 0)
BEGIN
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('1320122100', FLOOR(RAND()*(1300-5+1)+5))
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('7611334511', FLOOR(RAND()*(300-0+1)+0))
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('8549494944', FLOOR(RAND()*(300-0+1)+0))
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('5454667577', FLOOR(RAND()*(1300-0+1)+0))
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('6523454446', FLOOR(RAND()*(300-0+1)+0))
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('4335353354', FLOOR(RAND()*(300-0+1)+0))
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('5657677755', FLOOR(RAND()*(300-20+1)+20))
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('4648889113', FLOOR(RAND()*(300-20+1)+20))
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('5484873335', FLOOR(RAND()*(2000-100+1)+100))
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('6543554443', FLOOR(RAND()*(300-0+1)+0))
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('5325553353', FLOOR(RAND()*(300-10+1)+10))
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('5325553303', FLOOR(RAND()*(300-10+1)+10))
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('5325553323', FLOOR(RAND()*(300-10+1)+10))
    INSERT INTO RewardCustomerPoints(MemberId, Points) VALUES('5325553313', FLOOR(RAND()*(300-10+1)+10))
END

IF NOT EXISTS (SELECT 1 from sysobjects where name='RewardItems' and xtype='U')
	CREATE TABLE RewardItems ([Id] VARCHAR(5) NOT NULL, [Name] VARCHAR(100) NOT NULL, [ImageUrl] VARCHAR(400), [Points] INT, PRIMARY KEY (Id))
GO

IF ((SELECT COUNT(1) FROM RewardItems) = 0)
BEGIN
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('COF01','Large Coffee Mug', 40)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('COF02','Medium Coffee Mug', 30)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('COF03','Small Coffee Mug', 15)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('PCF01','Premium Coffee X-Large Bag', 130)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('PCF02','Premium Coffee Large Bag', 120)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('PCF03','Premium Coffee Medium Bag', 110)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('PCF04','Premium Coffee Small Bag', 90)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('GTE01','Large Green Tea Flavored Candy Bag', 40)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('GTE02','Medium Green Tea Flavored Candy Bag', 30)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('GTE03','Small Green Tea Flavored Candy Bag', 15)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('PGT01','Premium Green Tea X-Large Bag', 130)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('PGT02','Premium Green Tea Large Bag', 120)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('PGT03','Premium Green Tea Medium Bag', 110)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('PGT04','Premium Green Tea Small Bag', 90)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('BTE01','Large Black Tea Flavored Candy Bag', 40)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('BTE02','Medium Black Tea Flavored Candy Bag', 30)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('BTE03','Small Black Tea Flavored Candy Bag', 15)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('PBT01','Premium Black Tea X-Large Bag', 130)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('PBT02','Premium Black Tea Large Bag', 120)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('PBT03','Premium Black Tea Medium Bag', 110)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('PBT04','Premium Black Tea Small Bag', 90)      
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('TMG01','Large Travel Laptop case', 30)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('PMG01','Small Travel Laptop case', 15)
    INSERT INTO RewardItems([Id],[Name],[Points]) VALUES('ECM01','Espresso Coffee Machine', 600)
END

IF NOT EXISTS (SELECT 1 from sysobjects where name='Products' and xtype='U')
	CREATE TABLE Products ([Id] VARCHAR(5) NOT NULL, [Quantity] INT, [Active] BIT, PRIMARY KEY (Id))
GO

IF ((SELECT COUNT(1) FROM Products) = 0)
BEGIN
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('COF01',10,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('COF02',12,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('COF03',10,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('PCF01',10,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('PCF02',1,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('PCF03',1,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('PCF04',3,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('GTE01',4,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('GTE02',0,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('GTE03',0,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('PGT01',3,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('PGT02',5,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('PGT03',3,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('PGT04',0,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('BTE01',0,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('BTE02',0,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('BTE03',6,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('PBT01',5,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('PBT02',5,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('PBT03',0,0)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('PBT04',0,0)      
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('TMG01',4,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('PMG01',3,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('ECM01',1,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('FFF01',9000000,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('FFF02',9999999,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('FFF03',8999999,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('FFF04',7999999,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('FFF05',5999999,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('FFF06',6999999,1)
    INSERT INTO Products([Id],[Quantity],[Active]) VALUES('FFF07',9999999,1)
END

IF NOT EXISTS (SELECT 1 from sysobjects where name='Orders' and xtype='U')
	CREATE TABLE Orders ([Id] UNIQUEIDENTIFIER PRIMARY KEY, [MemberId] VARCHAR(10) NOT NULL, [ProductId] VARCHAR(5) NOT NULL, [Created] DATETIME NOT NULL, [TrackingNumber] VARCHAR(20), [Shipped] DATETIME)
GO

IF NOT EXISTS (SELECT 1 from sysobjects where name='AlternateIds' and xtype='U')
	CREATE TABLE AlternateIds ([Id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,[MemberId] VARCHAR(10) NOT NULL, [Value] VARCHAR(6))
GO

IF ((SELECT COUNT(1) FROM AlternateIds) = 0)
BEGIN
    INSERT INTO AlternateIds(MemberId,[Value]) VALUES('1320122100', '854123')
    INSERT INTO AlternateIds(MemberId,[Value]) VALUES('7611334511','456121')
    INSERT INTO AlternateIds(MemberId,[Value]) VALUES('8549494944','909212')
    INSERT INTO AlternateIds(MemberId,[Value]) VALUES('5454667577','788112')
END

SELECT COUNT(1) AS TOTAL_RewardCustomer FROM RewardCustomers
SELECT COUNT(1) AS TOTAL_RewardItem FROM RewardItems
SELECT COUNT(1) AS TOTAL_Products FROM Products
SELECT COUNT(1) AS TOTAL_AlternateCustomer FROM AlternateIds