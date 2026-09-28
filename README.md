Project Title: SMART PARKING SYSTEM
DESCRIPTION: Web-based smart parking management system using Flask, Python, HTML/CSS and MySQL
TECHNOLOGY
The Smart Parking System was developed using the following technologies:
- Python – Main programming language.
- Flask – Python web framework used to develop the backend and handle application routes.
- MySQL – Database management system used to store users, vehicles, parking slots, reservations, parking sessions, payments, and violations.
- HTML5 – Used to structure the web pages and user interfaces.
- CSS3 – Used to style and format the web interface.
- Jinja2 – Used with Flask to create dynamic HTML pages and display database information.
- MySQL Connector/Python – Used to connect the Flask application to the MySQL database.
- Git & GitHub – Used for version control and project management.
  MAIN FEATURES:
- User Registration and Login – Allows users to create accounts and securely access the system.
- Vehicle Registration – Allows clients to register and manage their vehicles.
- Parking Slot Management – Displays available, occupied, and reserved parking slots.
- Parking Reservations – Allows clients to reserve parking slots for a specified date and time.
- Reservation Cancellation – Allows clients to cancel reservations before the scheduled reservation period.
- Parking Sessions – Allows clients to start and end parking sessions.
- Automatic Parking Fee Calculation – Calculates parking charges based on the vehicle type and parking duration.
- Payment Management – Records and displays parking payments and payment information.
- Parking Rates – Provides different parking rates for different vehicle types, including cars and motorcycles.
- Violation Management – Records and manages parking violations.
- Client Dashboard – Provides users with access to their vehicles, reservations, parking sessions, payments, and other parking information.
- Database Management – Stores and manages system information using MySQL.
- Database Setup

The Smart Parking System uses MySQL to store user accounts, vehicles, parking slots, reservations, parking sessions, payments, and parking violations.

1. Create the Database

Open MySQL or MySQL Workbench and create the project database:

CREATE DATABASE smart_parking_system;

Select the database:

USE smart_parking_system;

2. Create the Required Tables

Import or execute the provided SQL database file to create the required tables and their relationships.

The database contains tables for:

- Users
- Vehicles
- Parking Slots
- Reservations
- Parking Sessions
- Payments
- Violations

3. Configure the Database Connection

Update the database connection settings in the Flask application with your own MySQL credentials.

The configuration should contain:

- MySQL host
- Database name
- MySQL username
- MySQL password

Important: Do not upload or share your actual MySQL password on GitHub.

4. Verify the Database

After creating the database and tables, confirm that all required tables have been created successfully.

You can check them using:

SHOW TABLES;

The Flask application can then connect to the database and perform operations such as vehicle registration, reservations, parking sessions, payments, and violation recording.
Installation & Setup

Prerequisites

Before installing the Smart Parking System, make sure you have the following installed:

- Python 3.x
- MySQL Server
- Git
- A modern web browser

1. Clone the Repository

Clone the project from GitHub and navigate into the project directory:

git clone <your-github-repository-url>
cd smart_parking_system

2. Create a Virtual Environment

Create a Python virtual environment:

python -m venv venv

Activate the virtual environment on Windows:

venv\Scripts\activate

3. Install Dependencies

Install the required Python packages:

pip install -r requirements.txt

4. Configure the MySQL Database

Create the required database in MySQL and import the provided database schema.

Update the application's database configuration with your own MySQL credentials.

Note: Do not share or commit your database password or other sensitive credentials to GitHub.

5. Run the Application

Start the Flask application:

python app.py

Once the application is running, open your web browser and visit:

http://127.0.0.1:5000/

The Smart Parking System should now be ready to use.
