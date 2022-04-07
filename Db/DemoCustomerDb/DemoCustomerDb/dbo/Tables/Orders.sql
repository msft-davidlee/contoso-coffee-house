CREATE TABLE [dbo].[Orders] (
    [Id]             UNIQUEIDENTIFIER NOT NULL,
    [MemberId]       VARCHAR (10)     NOT NULL,
    [ProductId]      VARCHAR (5)      NOT NULL,
    [Created]        DATETIME         NOT NULL,
    [TrackingNumber] VARCHAR (20)     NULL,
    [Shipped]        DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

