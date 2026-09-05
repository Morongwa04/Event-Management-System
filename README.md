RaceDay - Event Management System

System Overview
RaceDay is a full-stack web-based event management system designed specifically for the South African road running, walking, and cycling community. The platform enables Event Organisers to create and manage events, categories, and participant results, while Participants can browse upcoming events, enter events, track their personal performance history, and prepare for race day using live weather and route information.

User Roles
Organiser
Create, edit, and delete events
Manage event categories
Capture participant results
View all event enrolments
Access route and weather information

Participant
Create an account
Browse events
Enter events by selecting a category
View own enrolments
Track personal results
Access event details including route and weather information

System Architecture
The system follows a three-tier architecture:
Database Layer: SQL Server database with 6 entities
API Layer: RESTful API built with C#
Presentation Layer: MVC web application

Database Schema
The database consists of the following entities:
User: Stores user accounts with role-based access
Event: Contains event details organised by users
Category: Event categories with distance and entry fee
Enrolment: Participant registrations for event categories
Result: Participant results with finish times and positions
RouteWeather: Weather forecasts and route descriptions for events

Entity Relationships
User (Organiser) 1 → Many Event
Event 1 → Many Category
User (Participant) 1 → Many Enrolment
Category 1 → Many Enrolment
Enrolment 1 → 1 Result
Event 1 → 1 RouteWeather

API Endpoint Plan
All endpoints are prefixed with /api/ and follow RESTful conventions.

Authentication
Method	Route	Description	Role Required	Request Body	Expected Response
POST	/api/auth/register	Creates a new user account	None (public)	{name, email, password, role}	201 Created - user record (no password) / 409 Conflict - email already in use
POST	/api/auth/login	Authenticates user and returns JWT token	None (public)	{email, password}	200 Ok - token + user details / 401 Unauthorized - invalid credentials
User Profile
Method	Route	Description	Role Required	Request Body	Expected Response
GET	/api/users/{id}	Retrieves user's own profile	Any (owner only)	None	200 Ok - user profile / 404 Not Found - user does not exist
PUT	/api/users/{id}	Updates user's own profile	Any (owner only)	{name, email}	200 Ok - updated profile / 400 Bad Request - invalid data
Events
Method	Route	Description	Role Required	Request Body	Expected Response
GET	/api/events	Lists all upcoming events with optional filters	None (public)	None	200 Ok - array of events
GET	/api/events/{id}	Retrieves full details for a single event including categories	None (public)	None	200 Ok - event details / 404 Not Found - event does not exist
POST	/api/events	Creates a new event	Organiser	{name, description, eventDate, location}	201 Created - new event / 400 Bad Request - invalid data
PUT	/api/events/{id}	Updates an event	Organiser	{name, description, eventDate, location}	200 Ok - updated event / 403 Forbidden - not the owner / 404 Not Found
DELETE	/api/events/{id}	Deletes an event	Organiser	None	204 No Content / 403 Forbidden - not the owner / 404 Not Found
Categories
Method	Route	Description	Role Required	Request Body	Expected Response
GET	/api/events/{eventId}/categories	Lists all categories for a specific event	None (public)	None	200 Ok - array of categories
POST	/api/events/{eventId}/categories	Adds a new category to an event	Organiser	{name, distance, entryFee}	201 Created - new category / 404 Not Found - event does not exist
PUT	/api/categories/{id}	Updates an existing category	Organiser	{name, distance, entryFee}	200 Ok - updated category / 403 Forbidden - not the owner
DELETE	/api/categories/{id}	Removes a category from an event	Organiser	None	204 No Content / 403 Forbidden - not the owner
Enrolments
Method	Route	Description	Role Required	Request Body	Expected Response
POST	/api/enrolments	Enrols the logged-in participant into a category	Participant	{categoryId}	201 Created - enrolment record / 409 Conflict - already enrolled
GET	/api/enrolments/my	Lists all enrolments for the logged-in participant	Participant	None	200 Ok - array of enrolments
GET	/api/events/{eventId}/enrolments	Lists all participants enrolled in a specific event	Organiser	None	200 Ok - array of enrolments / 403 Forbidden - not the owner
DELETE	/api/enrolments/{id}	Cancels an enrolment	Participant	None	204 No Content / 403 Forbidden - not the owner
Results
Method	Route	Description	Role Required	Request Body	Expected Response
POST	/api/results	Captures finish time and position for a participant	Organiser	{enrolmentId, finishTime, position}	201 Created - result recorded / 404 Not Found - enrolment does not exist
GET	/api/results/{enrolmentId}	Retrieves the result for a specific enrolment	Any (logged in)	None	200 Ok - result details / 404 Not Found - no result yet
GET	/api/participants/{id}/results	Retrieves participant's full result history	Any (owner or organiser)	None	200 Ok - array of results
Technical Documentation
Database Setup
The SQL script creates and populates the RaceDay database with realistic South African sample data including:
2 Organisers (Thabo Mokoena, Lindiwe Nkosi)
2 Participants (Sipho Dlamini, Anna van der Merwe)
3 Events (Joburg City Marathon, Durban Beachfront Fun Run, Cape Winelands Cycle Challenge)
Categories for each event with appropriate distances and fees
Sample enrolments and results

## CI/CD Pipeline
This project uses GitHub Actions for continuous integration and deployment:

### Part 1 - Repository Validation
- Validates the existence of required documentation files
- Checks folder structure and file naming conventions
- Runs on every push and pull request

### Part 2 - API Build and Test
- Builds the .NET API
- Runs unit and integration tests
- Generates code coverage reports
- Builds Docker images for the API
- Deploys to staging environment (develop branch)
- Deploys to production environment (main/master branch)

### Part 3 - Full Stack Deployment
- Builds both API and MVC applications
- Bundles frontend assets
- Builds production Docker images
- Runs security scans (Trivy, OWASP ZAP)
- Deploys to Azure Web App
- Configures Azure Blob Storage
- Performs load testing
- Sends deployment notifications

### CI/CD Status

<img width="1004" height="335" alt="Screenshot 2026-09-05 200241" src="https://github.com/user-attachments/assets/916a8136-2aeb-4162-ba4b-a6355d490aa4" />


### Deployment Environments

- **Development**: Automatically deployed from `develop` branch
- **Staging**: Automatically deployed from `feature/*` branches
- **Production**: Automatically deployed from `main` and `master` branches

Folder Structure
/
├── docs/
│   ├── ERD.png
│   ├── API_ENDPOINT_PLAN.pdf
│   └── RaceDayDB_Schema.sql
├── .github/
│   └── workflows/
│       └── validate-structure.yml
└── README.md

Prerequisites
.NET 8 SDK
SQL Server (or SQL Server Express)
SQL Server Management Studio (SSMS)
Git

Docker Desktop (for Part 3)
Node.js (for frontend assets)

Setup Instructions
1. Clone the Repository
bash
git clone https://github.com/Morongwa04/Event-Management-System.git
cd Event-Management-System
2. Database Setup
bash
# Open SSMS and run the SQL script
# File: docs/RaceDayDB_Schema.sql
# The script will create and populate the RaceDayDB database
3. API Setup (Part 2)
bash
# Restore dependencies
dotnet restore

# Build the API
dotnet build --configuration Release

# Run the API
cd RaceDay.API
dotnet run
4. MVC Application Setup (Part 3)
bash
# Restore dependencies
dotnet restore

# Build the MVC application
dotnet build --configuration Release

# Install npm dependencies
cd RaceDay.MVC
npm install

# Run the MVC application
dotnet run
5. Docker Setup (Part 3)
bash
# Build Docker image
docker build -t raceday-app .

# Run Docker container
docker run -d -p 8080:80 --name raceday-container raceday-app

Contributors
Morongwa04
