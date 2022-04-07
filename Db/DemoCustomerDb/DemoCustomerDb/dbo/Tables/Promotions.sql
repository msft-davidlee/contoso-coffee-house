CREATE TABLE [dbo].[Promotions]
(
	[SKU] VARCHAR (10) NOT NULL PRIMARY KEY, 
	[Multiplier] INT, 
	[Start] DATETIME NULL, 
	[End] DATETIME NULL
)
