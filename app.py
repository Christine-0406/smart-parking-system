from flask import Flask, render_template, request, redirect, url_for, session
import mysql.connector
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)

# Secret key used for login sessions
app.secret_key = "smart-parking-secret-key"


# Connect to MySQL
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="project@2026",
    database="parking_system"
)
# ---------------- RECORD VIOLATION ----------------

def record_violation(user_id, vehicle_id, slot_id, violation_type, description):

    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT violation_id
        FROM violations
        WHERE user_id = %s
          AND vehicle_id = %s
          AND slot_id = %s
          AND violation_type = %s
          AND status = 'Unresolved'
        LIMIT 1
    """, (
        user_id,
        vehicle_id,
        slot_id,
        violation_type
    ))

    existing = cursor.fetchone()

    if not existing:

        cursor.execute("""
            INSERT INTO violations
            (user_id,
             vehicle_id,
             slot_id,
             violation_type,
             description,
             status)
            VALUES (%s, %s, %s, %s, %s, 'Unresolved')
        """, (
            user_id,
            vehicle_id,
            slot_id,
            violation_type,
            description
        ))

        db.commit()

    cursor.close()
# ---------------- CHECK PARKING VIOLATIONS ----------------

def check_parking_violations():

    db.ping(reconnect=True, attempts=3, delay=2)

    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            r.reservation_id,
            r.user_id,
            r.vehicle_id,
            r.slot_id,
            r.reservation_date,
            r.end_time,
            ps.session_id
        FROM reservations_working r
        JOIN parking_sessions ps
            ON r.vehicle_id = ps.vehicle_id
           AND r.slot_id = ps.slot_id
           AND r.user_id = ps.user_id
        WHERE r.status = 'Active'
          AND ps.status = 'Active'
          AND CONCAT(r.reservation_date, ' ', r.end_time) < NOW()
    """)

    overstayed = cursor.fetchall()

    cursor.close()

    for record in overstayed:

        record_violation(
            record["user_id"],
            record["vehicle_id"],
            record["slot_id"],
            "Overstaying",
            "Vehicle remained in the parking slot after the reservation end time."
        )      

# ---------------- HOME PAGE ----------------

@app.route("/")
def home():
    return render_template("index.html")


# ---------------- CLIENT REGISTRATION ----------------

@app.route("/register", methods=["GET", "POST"])
def register():

    if request.method == "POST":

        username = request.form["username"]
        email = request.form["email"]
        phone = request.form["phone"]
        password = request.form["password"]
        confirm_password = request.form["confirm_password"]

        # Check that the two passwords match
        if password != confirm_password:
            return "Error: Passwords do not match. Please go back and try again."

        # Hash the password before storing it
        hashed_password = generate_password_hash(password)

        # Every person registering through this public page is a CLIENT
        role = "client"

        cursor = db.cursor()

        sql = """
            INSERT INTO users_test
            (username, email, phone, password, role)
            VALUES (%s, %s, %s, %s, %s)
        """

        values = (
            username,
            email,
            phone,
            hashed_password,
            role
        )

        cursor.execute(sql, values)
        db.commit()

        cursor.close()

        return redirect(url_for("login"))

    return render_template("register.html")

# ---------------- LOGIN ----------------

@app.route("/login", methods=["GET", "POST"])
def login():

    if request.method == "POST":

        username = request.form["username"]
        password = request.form["password"]

        cursor = db.cursor(dictionary=True)

        sql = """
            SELECT user_id, username, password, role
            FROM users_test
            WHERE username = %s
        """

        cursor.execute(sql, (username,))

        user = cursor.fetchone()

        # Consume any remaining results before closing
        cursor.fetchall()

        cursor.close()

        if user is not None:

            if check_password_hash(user["password"], password):

                session["user_id"] = user["user_id"]
                session["username"] = user["username"]
                session["role"] = user["role"]

                return redirect(url_for("dashboard"))

        return "Invalid username or password."

    return render_template("login.html")
# ---------------- DASHBOARD----------------
@app.route("/dashboard")
def dashboard():

    if "user_id" not in session:
        return redirect(url_for("login"))

    user_id = session["user_id"]

    # ------------------------------------------------
    # CHECK PARKING VIOLATIONS FIRST
    # ------------------------------------------------
    check_parking_violations()

    cursor = db.cursor(dictionary=True)

    # ------------------------------------------------
    # GET ALL PARKING SLOTS
    # ------------------------------------------------
    cursor.execute("""
        SELECT
            slot_id,
            slot_number,
            slot_type,
            status
        FROM parking_slots
        ORDER BY slot_number
    """)

    parking_slots = cursor.fetchall()

    # ------------------------------------------------
    # GET THIS CLIENT'S RESERVATIONS
    # ------------------------------------------------
    cursor.execute("""
        SELECT
            r.reservation_id,
            r.reservation_date,
            r.start_time,
            r.end_time,
            r.status,
            r.payment_status,

            p.slot_number,
            p.slot_type,

            v.registration_number,
            v.vehicle_model,

            ps.session_id

        FROM reservations_working r

        JOIN parking_slots p
            ON r.slot_id = p.slot_id

        JOIN vehicles_test v
            ON r.vehicle_id = v.vehicle_id

        LEFT JOIN parking_sessions ps
            ON r.vehicle_id = ps.vehicle_id
           AND r.slot_id = ps.slot_id
           AND r.user_id = ps.user_id
           AND ps.status = 'Active'

        WHERE r.user_id = %s
          AND r.status IN ('Confirmed', 'Active')

        ORDER BY
            r.reservation_date,
            r.start_time
    """, (user_id,))

    reservations = cursor.fetchall()

    # ------------------------------------------------
    # GET THIS CLIENT'S UNRESOLVED VIOLATIONS
    # ------------------------------------------------
    cursor.execute("""
        SELECT
            violation_id,
            vehicle_id,
            slot_id,
            violation_type,
            description,
            violation_date,
            status
        FROM violations
        WHERE user_id = %s
          AND status = 'Unresolved'
        ORDER BY violation_date DESC
    """, (user_id,))

    violations = cursor.fetchall()

    cursor.close()

    # ------------------------------------------------
    # DISPLAY DASHBOARD
    # ------------------------------------------------
    return render_template(
        "dashboard.html",
        parking_slots=parking_slots,
        reservations=reservations,
        violations=violations
    )
# ---------------- START SESSIONS ----------------
@app.route("/start_session/<int:reservation_id>")
def start_session(reservation_id):

    if "user_id" not in session:
        return redirect(url_for("login"))

    user_id = session["user_id"]

    cursor = db.cursor(dictionary=True)

    # 1. Get the client's confirmed reservation
    cursor.execute("""
        SELECT
            reservation_id,
            user_id,
            vehicle_id,
            slot_id,
            reservation_date,
            start_time,
            end_time,
            status
        FROM reservations_working
        WHERE reservation_id = %s
          AND user_id = %s
          AND status = 'Confirmed'
    """, (reservation_id, user_id))

    reservation = cursor.fetchone()

    if not reservation:
        cursor.close()
        return "Confirmed reservation not found."

    # 2. Check whether this vehicle already has an active parking session
    cursor.execute("""
        SELECT session_id
        FROM parking_sessions
        WHERE user_id = %s
          AND vehicle_id = %s
          AND status = 'Active'
        LIMIT 1
    """, (user_id, reservation["vehicle_id"]))

    existing_session = cursor.fetchone()

    if existing_session:
        cursor.close()
        return "This vehicle already has an active parking session."

    # 3. Check the reserved parking slot
    cursor.execute("""
        SELECT
            slot_id,
            slot_number,
            slot_type,
            status
        FROM parking_slots
        WHERE slot_id = %s
    """, (reservation["slot_id"],))

    slot = cursor.fetchone()

    if not slot:
        cursor.close()
        return "Reserved parking slot not found."

    if slot["status"] != "Reserved":
        cursor.close()
        return "This parking slot is not currently reserved."

    # 4. Get the vehicle type
    cursor.execute("""
        SELECT vehicle_type
        FROM vehicles_test
        WHERE vehicle_id = %s
          AND user_id = %s
    """, (reservation["vehicle_id"], user_id))

    vehicle = cursor.fetchone()

    if not vehicle:
        cursor.close()
        return "Vehicle not found."

    # 5. Get the parking rate
    cursor.execute("""
        SELECT rate_per_hour
        FROM parking_rates
        WHERE vehicle_type = %s
    """, (vehicle["vehicle_type"],))

    rate = cursor.fetchone()

    if not rate:
        cursor.close()
        return "Parking rate not found for this vehicle type."

    hourly_rate = rate["rate_per_hour"]

    # 6. Create the parking session
    cursor.execute("""
        INSERT INTO parking_sessions
        (
            user_id,
            vehicle_id,
            slot_id,
            entry_time,
            hourly_rate,
            total_amount,
            amount_before_vat,
            vat_amount,
            status
        )
        VALUES
        (
            %s,
            %s,
            %s,
            NOW(),
            %s,
            %s,
            %s,
            %s,
            %s
        )
    """, (
        user_id,
        reservation["vehicle_id"],
        reservation["slot_id"],
        hourly_rate,
        0,
        0,
        0,
        "Active"
    ))

    # 7. Change the slot from Reserved to Occupied
    cursor.execute("""
        UPDATE parking_slots
        SET status = 'Occupied'
        WHERE slot_id = %s
    """, (reservation["slot_id"],))

    # 8. Update reservation status
    cursor.execute("""
        UPDATE reservations_working
        SET status = 'Active'
        WHERE reservation_id = %s
          AND user_id = %s
    """, (reservation_id, user_id))

    # 9. Save changes
    db.commit()

    cursor.close()

    # 10. Return to dashboard
    return redirect(url_for("dashboard"))
@app.route("/end_session/<int:session_id>")
def end_session(session_id):

    if "user_id" not in session:
        return redirect(url_for("login"))

    user_id = session["user_id"]

    cursor = db.cursor(dictionary=True)

    # 1. Find the active parking session
    cursor.execute("""
        SELECT
            session_id,
            slot_id,
            entry_time,
            hourly_rate
        FROM parking_sessions
        WHERE session_id = %s
          AND user_id = %s
          AND status = 'Active'
    """, (session_id, user_id))

    parking_session = cursor.fetchone()

    if not parking_session:
        cursor.close()
        return "Parking session not found or already completed."

    # 2. Record exit time
    cursor.execute("""
        UPDATE parking_sessions
        SET exit_time = NOW()
        WHERE session_id = %s
          AND user_id = %s
    """, (session_id, user_id))

    # 3. Calculate parking duration
    cursor.execute("""
        SELECT
            TIMESTAMPDIFF(
                MINUTE,
                entry_time,
                exit_time
            ) AS duration_minutes
        FROM parking_sessions
        WHERE session_id = %s
    """, (session_id,))

    duration = cursor.fetchone()

    duration_minutes = duration["duration_minutes"]

    # 4. Calculate chargeable hours
    if duration_minutes <= 60:
        chargeable_hours = 1
    else:
        chargeable_hours = (duration_minutes + 59) // 60

    # 5. Calculate total amount
    total_amount = (
        chargeable_hours * float(parking_session["hourly_rate"])
    )

    # 6. Calculate VAT included in the total
    amount_before_vat = total_amount / 1.16
    vat_amount = total_amount - amount_before_vat

    amount_before_vat = round(amount_before_vat, 2)
    vat_amount = round(vat_amount, 2)
    total_amount = round(total_amount, 2)

    # 7. Complete the parking session
    cursor.execute("""
        UPDATE parking_sessions
        SET
            total_amount = %s,
            amount_before_vat = %s,
            vat_amount = %s,
            status = 'Completed'
        WHERE session_id = %s
          AND user_id = %s
    """, (
        total_amount,
        amount_before_vat,
        vat_amount,
        session_id,
        user_id
    ))

    # 8. Make the parking slot available again
    cursor.execute("""
        UPDATE parking_slots
        SET status = 'Available'
        WHERE slot_id = %s
    """, (parking_session["slot_id"],))

   # 9. Complete the reservation
    cursor.execute("""
        UPDATE reservations_working
        SET status = 'Completed'
        WHERE user_id = %s
          AND vehicle_id = (
              SELECT vehicle_id
              FROM parking_sessions
              WHERE session_id = %s
          )
          AND slot_id = %s
          AND status IN ('Confirmed', 'Active')
    """, (
        user_id,
        session_id,
        parking_session["slot_id"]
    ))

    # 10. Save all changes
    db.commit()

    cursor.close()

    # 11. Go to payment
    return redirect(
        url_for("make_payment", session_id=session_id)
    )
    
# ---------------- VIEW SESSION ----------------
@app.route("/parking_sessions")
def parking_sessions():
    if "user_id" not in session:
        return redirect(url_for("login"))

    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            ps.session_id,
            ps.entry_time,
            ps.exit_time,
            ps.hourly_rate,
            ps.total_amount,
            ps.status,
            v.registration_number,
            v.vehicle_model,
            p.slot_number
        FROM parking_sessions ps
        JOIN vehicles_test v
            ON ps.vehicle_id = v.vehicle_id
        JOIN parking_slots p
            ON ps.slot_id = p.slot_id
        WHERE ps.user_id = %s
        ORDER BY ps.entry_time DESC
    """, (session["user_id"],))

    parking_sessions = cursor.fetchall()
    cursor.close()

    return render_template(
        "parking_sessions.html",
        parking_sessions=parking_sessions
    )
# ---------------- MAKE PAYMENTS ----------------
@app.route("/make_payment/<int:session_id>", methods=["GET", "POST"])
def make_payment(session_id):

    if "user_id" not in session:
        return redirect(url_for("login"))

    user_id = session["user_id"]

    cursor = db.cursor(dictionary=True)

    # 1. Get the completed parking session
    cursor.execute("""
        SELECT
            session_id,
            user_id,
            total_amount,
            status
        FROM parking_sessions
        WHERE session_id = %s
          AND user_id = %s
          AND status = 'Completed'
    """, (session_id, user_id))

    parking_session = cursor.fetchone()

    if not parking_session:
        cursor.close()
        return "Completed parking session not found."

    # 2. Check if this parking session has already been paid
    cursor.execute("""
        SELECT
            payment_id,
            status
        FROM payments
        WHERE session_id = %s
          AND user_id = %s
          AND status = 'Paid'
        LIMIT 1
    """, (session_id, user_id))

    existing_payment = cursor.fetchone()

    if existing_payment:
        cursor.close()
        return "This parking session has already been paid for."

    # 3. Process payment
    if request.method == "POST":

        payment_method = request.form.get("payment_method")
        payment_reference = request.form.get("payment_reference")

        # Make sure a payment method was selected
        if not payment_method:
            cursor.close()
            return "Please select a payment method."

        amount = parking_session["total_amount"]

        # 4. Insert payment record
        cursor.execute("""
            INSERT INTO payments
            (
                user_id,
                session_id,
                amount,
                payment_method,
                payment_reference,
                payment_date,
                status
            )
            VALUES
            (%s, %s, %s, %s, %s, NOW(), 'Paid')
        """, (
            user_id,
            session_id,
            amount,
            payment_method,
            payment_reference
        ))

        # 5. Save changes
        db.commit()

        cursor.close()

        # 6. Payment successful
    return 
    redirect(url_for("payment_success"))

        # 7. Display payment page
    cursor.close()
    return render_template(
            "make_payment.html",
            parking_session=parking_session
        )
@app.route("/payment_success")
def payment_success():
    if "user_id" not in session:
        return redirect(url_for("login"))

    return render_template("payment_success.html")
# ---------------- VEHICLE REGISTRATION ----------------

@app.route("/register_vehicle", methods=["GET", "POST"])
def register_vehicle():

    # Make sure the user is logged in
    if "user_id" not in session:
        return redirect(url_for("login"))

    user_id = session["user_id"]

    if request.method == "POST":

        registration_number = request.form["registration_number"]
        vehicle_type = request.form["vehicle_type"]
        vehicle_model = request.form["vehicle_model"]
        vehicle_color = request.form["vehicle_color"]

        cursor = db.cursor(dictionary=True)

        # Check whether this registration number already exists
        cursor.execute("""
            SELECT vehicle_id
            FROM vehicles_test
            WHERE registration_number = %s
        """, (registration_number,))

        existing_vehicle = cursor.fetchone()

        if existing_vehicle:
            cursor.close()
            return "This vehicle registration number is already registered."

        # Register the new vehicle
        cursor.execute("""
            INSERT INTO vehicles_test
            (registration_number, user_id, vehicle_type,
             vehicle_model, vehicle_color)
            VALUES (%s, %s, %s, %s, %s)
        """, (
            registration_number,
            user_id,
            vehicle_type,
            vehicle_model,
            vehicle_color
        ))

        db.commit()
        cursor.close()

        return redirect(url_for("my_vehicles"))

    return render_template("vehicle_registration.html")
@app.route("/my_vehicles")
def my_vehicles():

    if "user_id" not in session:
        return redirect(url_for("login"))

    user_id = session["user_id"]

    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            vehicle_id,
            registration_number,
            vehicle_type,
            vehicle_model,
            vehicle_color
        FROM vehicles_test
        WHERE user_id = %s
        ORDER BY vehicle_id DESC
    """, (user_id,))

    vehicles = cursor.fetchall()

    cursor.close()

    return render_template(
        "my_vehicles.html",
        vehicles=vehicles
    )
# ---------------- VIOLATIONS ----------------
@app.route("/violations")
def violations():

    if "user_id" not in session:
        return redirect(url_for("login"))

    user_id = session["user_id"]

    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            v.violation_id,
            v.violation_type,
            v.description,
            v.violation_date,
            v.status,
            ve.registration_number,
            p.slot_number
        FROM violations v
        JOIN vehicles_test ve
            ON v.vehicle_id = ve.vehicle_id
        LEFT JOIN parking_slots p
            ON v.slot_id = p.slot_id
        WHERE v.user_id = %s
        ORDER BY v.violation_date DESC
    """, (user_id,))

    violations = cursor.fetchall()

    cursor.close()

    return render_template(
        "violations.html",
        violations=violations
    )

# ---------------- LOGOUT ----------------

@app.route("/logout")
def logout():

    # Clear the user's login session
    session.clear()

    return redirect(url_for("login"))
# ---------------- MAKE RESERVATION----------------
@app.route("/make_reservation", methods=["GET", "POST"])
def make_reservation():

    if "user_id" not in session:
        return redirect(url_for("login"))

    user_id = session["user_id"]

    cursor = db.cursor(dictionary=True)

    if request.method == "POST":

        vehicle_id = request.form["vehicle_id"]
        slot_id = request.form["slot_id"]
        reservation_date = request.form["reservation_date"]
        start_time = request.form["start_time"]
        end_time = request.form["end_time"]

        # ------------------------------------------------
        # CHECK 1: Existing active reservation
        # ------------------------------------------------
        cursor.execute("""
            SELECT reservation_id, vehicle_id, slot_id
            FROM reservations_working
            WHERE user_id = %s
              AND status IN ('Pending', 'Confirmed', 'Active')
            LIMIT 1
        """, (user_id,))

        existing_reservation = cursor.fetchone()

        if existing_reservation:
            cursor.close()

            return """
                <h3>Reservation Not Allowed</h3>
                <p>
                    You already have an active reservation.
                    Only one vehicle can be reserved at a time.
                </p>
                <a href="/dashboard">Back to Dashboard</a>
            """

        # ------------------------------------------------
        # CHECK 2: Vehicle belongs to logged-in client
        # ------------------------------------------------
        cursor.execute("""
            SELECT vehicle_id
            FROM vehicles_test
            WHERE vehicle_id = %s
              AND user_id = %s
        """, (vehicle_id, user_id))

        vehicle = cursor.fetchone()

        if not vehicle:
            cursor.close()

            return """
                <h3>Invalid Vehicle</h3>
                <p>
                    The selected vehicle does not belong to your account.
                </p>
                <a href="/make_reservation">Try Again</a>
            """

        # ------------------------------------------------
        # CHECK 3: Parking slot is available
        # ------------------------------------------------
        cursor.execute("""
            SELECT status
            FROM parking_slots
            WHERE slot_id = %s
        """, (slot_id,))

        slot = cursor.fetchone()

        if not slot or slot["status"] != "Available":
            cursor.close()

            return """
                <h3>Slot Not Available</h3>
                <p>
                    Sorry, this parking slot is no longer available.
                </p>
                <a href="/make_reservation">Choose Another Slot</a>
            """

        # ------------------------------------------------
        # CHECK 4: Start time must be before end time
        # ------------------------------------------------
        if start_time >= end_time:
            cursor.close()

            return """
                <h3>Invalid Reservation Time</h3>
                <p>
                    The start time must be earlier than the end time.
                </p>
                <a href="/make_reservation">Try Again</a>
            """

        # ------------------------------------------------
        # CHECK 5: Prevent overlapping reservations
        # ------------------------------------------------
        cursor.execute("""
            SELECT reservation_id
            FROM reservations_working
            WHERE slot_id = %s
              AND reservation_date = %s
              AND status IN ('Pending', 'Confirmed', 'Active')
              AND start_time < %s
              AND end_time > %s
            LIMIT 1
        """, (
            slot_id,
            reservation_date,
            end_time,
            start_time
        ))

        overlapping_reservation = cursor.fetchone()

        if overlapping_reservation:
            cursor.close()

            return """
                <h3>Slot Already Reserved</h3>
                <p>
                   This parking slot is already reserved during
                    the selected time.
                </p>
                <a href="/make_reservation">Choose Another Slot</a>
            """

        # ------------------------------------------------
        # SAVE THE FREE CONFIRMED RESERVATION
        # ------------------------------------------------
        cursor.execute("""
            INSERT INTO reservations_working
            (
                user_id,
                vehicle_id,
                slot_id,
                reservation_date,
                start_time,
                end_time,
                status,
                payment_method,
                payment_status
            )
            VALUES
            (
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                'Confirmed',
                NULL,
                'Not Required'
            )
        """, (
            user_id,
            vehicle_id,
            slot_id,
            reservation_date,
            start_time,
            end_time
        ))

        # ------------------------------------------------
        # MARK SLOT AS RESERVED
        # ------------------------------------------------
        cursor.execute("""
            UPDATE parking_slots
            SET status = 'Reserved'
            WHERE slot_id = %s
        """, (slot_id,))

        db.commit()

        cursor.close()

        return redirect(url_for("dashboard"))

    # ------------------------------------------------
    # GET THE LOGGED-IN CLIENT'S VEHICLES
    # ------------------------------------------------
    cursor.execute("""
        SELECT
            vehicle_id,
            registration_number,
            vehicle_type,
            vehicle_model
        FROM vehicles_test
        WHERE user_id = %s
        ORDER BY vehicle_id DESC
    """, (user_id,))

    vehicles = cursor.fetchall()

    # ------------------------------------------------
    # GET ALL PARKING SLOTS
    # ------------------------------------------------
    cursor.execute("""
        SELECT
            slot_id,
            slot_number,
            slot_type,
            status
        FROM parking_slots
        ORDER BY slot_number
    """)

    parking_slots = cursor.fetchall()

    cursor.close()

    return render_template(
        "reservation.html",
        vehicles=vehicles,
        parking_slots=parking_slots
    )
#------#SAVE THE FREE CONFIRMED RESERVATION#---------------

    cursor.execute("""
        SELECT
            payment_id,
            session_id,
            amount,
            payment_method,
            payment_reference,
            payment_date,
            status
        FROM payments
        WHERE user_id = %s
        ORDER BY payment_date DESC
    """, (session["user_id"],))

    payment_records = cursor.fetchall()

    cursor.close()

    return render_template(
        "payments.html",
        payments=payment_records
    )

    # ------------------------------------------------
    # GET THE PARKING SESSION
    # ------------------------------------------------
    cursor.execute("""
        SELECT
            session_id,
            user_id,
            vehicle_id,
            slot_id,
            entry_time,
            exit_time,
            hourly_rate,
            total_amount,
            status
        FROM parking_sessions
        WHERE session_id = %s
          AND user_id = %s
    """, (session_id, user_id))

    parking_session = cursor.fetchone()

    if not parking_session:
        cursor.close()

        return """
            <h3>Parking Session Not Found</h3>
            <p>
                We could not find this parking session.
            </p>
            <a href="/dashboard">Back to Dashboard</a>
        """

    # ------------------------------------------------
    # CHECK IF THIS SESSION IS ALREADY PAID
    # ------------------------------------------------
    cursor.execute("""
        SELECT payment_id
        FROM payments
        WHERE session_id = %s
          AND user_id = %s
          AND status = 'Paid'
        LIMIT 1
    """, (session_id, user_id))

    existing_payment = cursor.fetchone()

    if existing_payment:
        cursor.close()

        return """
            <h3>Payment Already Completed</h3>
            <p>
                This parking session has already been paid for.
            </p>
            <a href="/dashboard">Back to Dashboard</a>
        """

    # ------------------------------------------------
    # COMPLETE PAYMENT
    # ------------------------------------------------
    if request.method == "POST":

        payment_method = request.form["payment_method"]
        payment_reference = request.form["payment_reference"]

        amount = parking_session["total_amount"]

        cursor.execute("""
            INSERT INTO payments
            (
                user_id,
                session_id,
                amount,
                payment_method,
                payment_reference,
                payment_date,
                status
            )
            VALUES (%s, %s, %s, %s, %s, NOW(), %s)
        """, (
            user_id,
            session_id,
            amount,
            payment_method,
            payment_reference,
            "Paid"
        ))

        # Mark the parking session as completed/paid
        cursor.execute("""
            UPDATE parking_sessions
            SET status = 'Completed'
            WHERE session_id = %s
              AND user_id = %s
        """, (session_id, user_id))

        db.commit()
        cursor.close()

        return redirect(url_for("dashboard"))

    cursor.close()

    return render_template(
        "payment.html",
        parking_session=parking_session
    )

if __name__ == "__main__":
    app.run(debug=True)