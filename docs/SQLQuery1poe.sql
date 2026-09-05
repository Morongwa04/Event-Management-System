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

