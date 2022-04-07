CREATE TABLE [dbo].[Products] (
    [Id]       VARCHAR (5) NOT NULL,
    [Quantity] INT         NULL,
    [Active]   BIT         NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

