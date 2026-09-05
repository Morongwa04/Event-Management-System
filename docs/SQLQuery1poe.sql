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

/* =========================================================
6. RouteWeather
========================================================= */
CREATE TABLE dbo.RouteWeather (
RouteWeatherId INT IDENTITY(1,1) PRIMARY KEY,
EventId INT NOT NULL,
Forecast NVARCHAR(200) NULL,
Temperature DECIMAL(4,1) NULL,
RouteDescription NVARCHAR(1000) NULL,
RouteMapUrl NVARCHAR(500) NULL,
CONSTRAINT FK_RouteWeather_Event FOREIGN KEY (EventId)
REFERENCES dbo.Event(EventId)
);
GO

/* =========================================================
Seed data
========================================================= */

-- Users: 2 Organisers, 2 Participants
INSERT INTO dbo.[User] (Name, Email, PasswordHash, Role) VALUES
('Thabo Mokoena', 'thabo.mokoena@raceday.co.za', 'HASH_PLACEHOLDER_1', 'Organiser'),
('Lindiwe Nkosi', 'lindiwe.nkosi@raceday.co.za', 'HASH_PLACEHOLDER_2', 'Organiser'),
('Sipho Dlamini', 'sipho.dlamini@example.com', 'HASH_PLACEHOLDER_3', 'Participant'),
('Anna van der Merwe','anna.vdm@example.com', 'HASH_PLACEHOLDER_4', 'Participant');
GO

-- Events: 3 events, organised by the two organisers above
INSERT INTO dbo.Event (OrganiserId, Name, Description, EventDate, Location) VALUES
(1, 'Joburg City Marathon', 'Annual road marathon through the streets of Johannesburg.', '2026-11-15', 'Johannesburg, Gauteng'),
(1, 'Durban Beachfront Fun Run', 'Family-friendly fun run along the Durban promenade.', '2026-10-04', 'Durban, KwaZulu-Natal'),
(2, 'Cape Winelands Cycle Challenge', 'Scenic cycling event through the Cape Winelands.', '2026-09-27', 'Stellenbosch, Western Cape');
GO

-- Categories: at least one per event
INSERT INTO dbo.Category (EventId, Name, Distance, EntryFee) VALUES
(1, '42km', 42.20, 350.00),
(1, '21km', 21.10, 250.00),
(2, '5km', 5.00, 100.00),
(2, '10km', 10.00, 150.00),
(3, '60km', 60.00, 400.00);
GO

-- Enrolments: sample participant enrolments
INSERT INTO dbo.Enrolment (ParticipantId, CategoryId, Status) VALUES
(3, 1, 'Confirmed'), -- Sipho enters the 42km
(4, 2, 'Confirmed'), -- Anna enters the 21km
(3, 5, 'Confirmed'); -- Sipho enters the 60km cycle
GO

-- Results: sample captured results for a completed enrolment
INSERT INTO dbo.Result (EnrolmentId, FinishTime, Position, CapturedByOrganiserId) VALUES
(1, '03:45:12', 214, 1);
GO

-- RouteWeather: sample forecast/route info per event
INSERT INTO dbo.RouteWeather (EventId, Forecast, Temperature, RouteDescription, RouteMapUrl) VALUES
(1, 'Sunny, light wind', 22.5, 'Starts at FNB Stadium, loops through Soweto and back.', 'https://maps.example.com/joburg-marathon'),
(3, 'Partly cloudy', 19.0, 'Rolling hills through Stellenbosch wine estates.', 'https://maps.example.com/winelands-cycle');
GO

SELECT * FROM dbo.[User];
SELECT * FROM dbo.Event;
SELECT * FROM dbo.Enrolment;