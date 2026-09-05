--RaceDay Database Schema - Part 1 (SSMS / SQL Server)

IF DB_ID('RaceDayDB') IS NULL
BEGIN
CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

/* Drop tables if they already exist (child tables first) */
IF OBJECT_ID('dbo.RouteWeather', 'U') IS NOT NULL DROP TABLE dbo.RouteWeather;
IF OBJECT_ID('dbo.Result', 'U') IS NOT NULL DROP TABLE dbo.Result;
IF OBJECT_ID('dbo.Enrolment', 'U') IS NOT NULL DROP TABLE dbo.Enrolment;
IF OBJECT_ID('dbo.Category', 'U') IS NOT NULL DROP TABLE dbo.Category;
IF OBJECT_ID('dbo.Event', 'U') IS NOT NULL DROP TABLE dbo.Event;
IF OBJECT_ID('dbo.[User]', 'U') IS NOT NULL DROP TABLE dbo.[User];
GO

/* =========================================================
1. User
========================================================= */
CREATE TABLE dbo.[User] (
UserId INT IDENTITY(1,1) PRIMARY KEY,
Name NVARCHAR(100) NOT NULL,
Email NVARCHAR(150) NOT NULL UNIQUE,
PasswordHash NVARCHAR(255) NOT NULL,
Role NVARCHAR(20) NOT NULL
CONSTRAINT CK_User_Role CHECK (Role IN ('Organiser', 'Participant')),
CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

/* =========================================================
2. Event
========================================================= */
CREATE TABLE dbo.Event (
EventId INT IDENTITY(1,1) PRIMARY KEY,
OrganiserId INT NOT NULL,
Name NVARCHAR(150) NOT NULL,
Description NVARCHAR(1000) NULL,
EventDate DATE NOT NULL,
Location NVARCHAR(200) NOT NULL,
CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
CONSTRAINT FK_Event_Organiser FOREIGN KEY (OrganiserId)
REFERENCES dbo.[User](UserId)
);
GO

/* =========================================================
3. Category
========================================================= */
CREATE TABLE dbo.Category (
CategoryId INT IDENTITY(1,1) PRIMARY KEY,
EventId INT NOT NULL,
Name NVARCHAR(50) NOT NULL,
Distance DECIMAL(6,2) NOT NULL,
EntryFee DECIMAL(8,2) NOT NULL DEFAULT 0,
CONSTRAINT FK_Category_Event FOREIGN KEY (EventId)
REFERENCES dbo.Event(EventId)
);
GO

/* =========================================================
4. Enrolment
========================================================= */
CREATE TABLE dbo.Enrolment (
EnrolmentId INT IDENTITY(1,1) PRIMARY KEY,
ParticipantId INT NOT NULL,
CategoryId INT NOT NULL,
EnrolmentDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
Status NVARCHAR(20) NOT NULL DEFAULT 'Confirmed'
CONSTRAINT CK_Enrolment_Status CHECK (Status IN ('Confirmed', 'Cancelled')),
CONSTRAINT FK_Enrolment_Participant FOREIGN KEY (ParticipantId)
REFERENCES dbo.[User](UserId),
CONSTRAINT FK_Enrolment_Category FOREIGN KEY (CategoryId)
REFERENCES dbo.Category(CategoryId),
CONSTRAINT UQ_Enrolment_Participant_Category UNIQUE (ParticipantId, CategoryId)
);
GO

/* =========================================================
5. Result (1:1 with Enrolment - enforced via UNIQUE FK)
========================================================= */
CREATE TABLE dbo.Result (
ResultId INT IDENTITY(1,1) PRIMARY KEY,
EnrolmentId INT NOT NULL UNIQUE,
FinishTime TIME(0) NULL,
Position INT NULL,
CapturedByOrganiserId INT NOT NULL,
CONSTRAINT FK_Result_Enrolment FOREIGN KEY (EnrolmentId)
REFERENCES dbo.Enrolment(EnrolmentId),
CONSTRAINT FK_Result_Organiser FOREIGN KEY (CapturedByOrganiserId)
REFERENCES dbo.[User](UserId)
);
GO