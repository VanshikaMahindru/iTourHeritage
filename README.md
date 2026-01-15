# iTour Heritage – Intelligent Travel & Heritage Management System

## Overview
iTour Heritage is a database-driven Flask web application designed for smart tourism and digital heritage management. It centralizes monument data, visitor records, guides, and bookings to improve travel planning, crowd control, and heritage monitoring.

---

## Features
- Centralized management of monuments, visitors, guides, and bookings  
- Intelligent itinerary and booking management  
- Conflict-free reservations using relational database constraints  
- Visitor tracking and basic tourism analytics  

---

## Technologies Used
- **Backend:** Python (Flask)  
- **Frontend:** HTML, CSS, JavaScript  
- **Database:** MySQL  

---

## Project Structure
ITOUR_UI/
│
├── app.py # Main Flask application
├── db_config.py # Database configuration
├── itourheritage.sql # MySQL database schema
│
├── templates/ # HTML pages
│ ├── index.html
│ ├── monuments.html
│ ├── guides.html
│ ├── bookings.html
│ ├── create_booking.html
│ └── visitors.html
│
└── static/
└── images/ # Monument and UI images

## How to Run
1. Import `itourheritage.sql` into MySQL
2. Update database credentials in `db_config.py`
3. Run the application:
```bash
python app.py
```
4. And then open the link