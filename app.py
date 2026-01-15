from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector

app = Flask(__name__)
app.secret_key = 'secret123'  


def get_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="root",
        database="itourheritage"
    )


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/monuments')
def monuments():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM monument")
    monuments_data = cursor.fetchall()
    cursor.close()
    db.close()
    return render_template('monuments.html', monuments=monuments_data)


@app.route('/guides')
def guides():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM guide")
    guides = cursor.fetchall()
    cursor.close()
    db.close()
    return render_template('guides.html', guides=guides)

@app.route('/visitors')
def visitors():
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT v.*,
        (SELECT COUNT(*) FROM booking b WHERE b.visitor_id = v.visitor_id) AS visit_count
        FROM visitor v
    """)
    
    visitors_data = cursor.fetchall()
    cursor.close()
    db.close()
    
    return render_template('visitors.html', visitors=visitors_data)


@app.route('/add_visitor', methods=['POST'])
def add_visitor():
    name = request.form['name']
    email = request.form['email']
    phone = request.form.get('phone')
    country = request.form.get('country')

    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute(
            "INSERT INTO visitor (name, email, phone, country) VALUES (%s, %s, %s, %s)",
            (name, email, phone, country)
        )
        db.commit()
        flash("Visitor added successfully!", "success")
    except mysql.connector.Error as err:
        db.rollback()
        flash(f"Error: {err}", "danger")
    finally:
        cursor.close()
        db.close()
    return redirect(url_for('visitors'))

@app.route('/bookings')
def bookings():
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            b.booking_id,
            v.name AS visitor_name,
            m.name AS monument_name,
            e.name AS experience_name,
            g.name AS guide_name,
            b.scheduled_date,
            b.status
        FROM booking b
        JOIN visitor v ON b.visitor_id = v.visitor_id
        LEFT JOIN monument m ON (b.booking_type='MONUMENT' AND b.target_id = m.monument_id)
        LEFT JOIN local_experience e ON (b.booking_type='EXPERIENCE' AND b.target_id = e.exp_id)
        LEFT JOIN guide g ON (b.booking_type='GUIDE' AND b.target_id = g.guide_id)
        ORDER BY b.scheduled_date DESC
    """)

    bookings_data = cursor.fetchall()
    cursor.close()
    db.close()
    return render_template('bookings.html', bookings=bookings_data)



@app.route('/create_booking')
def create_booking():
    db = get_db()
    cursor = db.cursor(dictionary=True)

    
    cursor.execute("SELECT visitor_id, name FROM visitor")
    visitors = cursor.fetchall()

  
    cursor.execute("SELECT monument_id AS id, name FROM monument")
    monuments = cursor.fetchall()
    cursor.execute("SELECT exp_id AS id, name FROM local_experience")
    experiences = cursor.fetchall()
    cursor.execute("SELECT guide_id AS id, name FROM guide")
    guides = cursor.fetchall()

    cursor.close()
    db.close()
    return render_template('create_booking.html', visitors=visitors, monuments=monuments, experiences=experiences, guides=guides)


@app.route('/confirm_booking', methods=['POST'])
def confirm_booking():
    visitor_id = request.form['visitor_id']
    booking_type = request.form['booking_type']
    target_id = request.form['target_id']
    scheduled_date = request.form['scheduled_date']
    amount = request.form['amount']
    payment_method = request.form['payment_method']

    if visitor_id == 'new':
        flash("Please add the visitor first!", "warning")
        return redirect(url_for('visitors'))

    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("""
            INSERT INTO booking (visitor_id, booking_type, target_id, scheduled_date, amount, payment_method, status)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (visitor_id, booking_type, target_id, scheduled_date, amount, payment_method, "Pending"))
        db.commit()
        flash("Booking confirmed!", "success")
    except mysql.connector.Error as err:
        db.rollback()
        flash(f"Error: {err}", "danger")
    finally:
        cursor.close()
        db.close()

    return redirect(url_for('bookings'))


if __name__ == '__main__':
    app.run(debug=True)
