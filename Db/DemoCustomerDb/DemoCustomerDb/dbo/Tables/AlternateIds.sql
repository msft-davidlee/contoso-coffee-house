CREATE TABLE [dbo].[AlternateIds] (
    [Id]       INT          IDENTITY (1, 1) NOT NULL,
    [MemberId] VARCHAR (10) NOT NULL,
    [Value]    VARCHAR (6)  NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

