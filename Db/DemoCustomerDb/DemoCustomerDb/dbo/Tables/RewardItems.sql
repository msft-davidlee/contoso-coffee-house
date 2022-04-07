CREATE TABLE [dbo].[RewardItems] (
    [Id]       VARCHAR (5)   NOT NULL,
    [Name]     VARCHAR (100) NOT NULL,
    [ImageUrl] VARCHAR (400) NULL,
    [Points]   INT           NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

