CREATE DATABASE itourheritage;
USE itourheritage;

CREATE TABLE visitor (
  visitor_id INT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(150),
  phone VARCHAR(30),
  country VARCHAR(100),
  created_at DATETIME DEFAULT NOW()
);

CREATE TABLE preferences (
  vid INT NOT NULL,
  preference VARCHAR(150) NOT NULL,
  PRIMARY KEY (vid, preference),
  FOREIGN KEY (vid) REFERENCES visitor(visitor_id) ON DELETE CASCADE
);

CREATE TABLE monument (
  monument_id INT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(100),
  location_city VARCHAR(100),
  location_state VARCHAR(100),
  country VARCHAR(100),
  latitude DECIMAL(9,6),
  longitude DECIMAL(9,6),
  cultural_significance VARCHAR(255),
  visitor_capacity INT DEFAULT 100,
  current_occupancy INT DEFAULT 0,
  entry_fee DECIMAL(10,2) DEFAULT 0.00,
  current_status ENUM('OPEN','CLOSED','UNDER_RESTORATION') DEFAULT 'OPEN',
  rating DECIMAL(3,2) DEFAULT NULL
);

CREATE TABLE local_experience (
  exp_id INT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description varchar(100),
  location VARCHAR(255),
  capacity INT DEFAULT 30,
  fee DECIMAL(10,2) DEFAULT 0.00,
  provider_contact VARCHAR(255),
  rating DECIMAL(3,2) DEFAULT NULL
);

CREATE TABLE guide (
  guide_id INT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  languages VARCHAR(255),
  expertise VARCHAR(255),
  hourly_rate DECIMAL(10,2),
  phone VARCHAR(30),
  availability VARCHAR(255),
  rating DECIMAL(3,2) DEFAULT NULL
);

CREATE TABLE itinerary (
  itinerary_id INT PRIMARY KEY,
  visitor_id INT NOT NULL,
  start_date DATE,
  end_date DATE,
  created_date DATETIME DEFAULT NOW(),
  FOREIGN KEY (visitor_id) REFERENCES visitor(visitor_id) ON DELETE CASCADE
);

CREATE TABLE itinerary_item (
  item_id INT PRIMARY KEY,
  itinerary_id INT NOT NULL,
  item_type ENUM('MONUMENT','EXPERIENCE') NOT NULL,
  reference_id INT NOT NULL,
  scheduled_start DATETIME,
  scheduled_end DATETIME,
  guide_id INT,
  transport_details VARCHAR(255),
  estimated_travel_minutes INT,
  FOREIGN KEY (itinerary_id) REFERENCES itinerary(itinerary_id) ON DELETE CASCADE,
  FOREIGN KEY (guide_id) REFERENCES guide(guide_id)
);



CREATE TABLE booking (
  booking_id INT PRIMARY KEY,
  visitor_id INT NOT NULL,
  booking_type ENUM('MONUMENT','EXPERIENCE','GUIDE') NOT NULL,
  booking_date DATETIME DEFAULT NOW(),
  scheduled_date DATETIME,
  status ENUM('CONFIRMED','PENDING','CANCELLED') DEFAULT 'PENDING',
  amount DECIMAL(10,2) DEFAULT 0.00,
  payment_method VARCHAR(50),
  payment_status ENUM('PAID','UNPAID','REFUNDED') DEFAULT 'UNPAID',
  target_id INT NOT NULL, 
  checkin_time DATETIME DEFAULT NULL,
  checkout_time DATETIME DEFAULT NULL,
  occupancy_snapshot INT DEFAULT NULL,
  created_by INT DEFAULT NULL,
  FOREIGN KEY (visitor_id) REFERENCES visitor(visitor_id) ON DELETE CASCADE
);

CREATE TABLE payment (
  payment_id INT PRIMARY KEY,
  booking_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_date DATETIME DEFAULT NOW(),
  payment_method VARCHAR(50),
  transaction_ref VARCHAR(255),
  FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE CASCADE
);

CREATE TABLE alert_log (
  alert_id INT PRIMARY KEY,
  monument_id INT,
  alert_type VARCHAR(100),
  message varchar(100),
  severity ENUM('INFO','WARNING','CRITICAL') DEFAULT 'INFO',
  created_at DATETIME DEFAULT NOW()
);

CREATE TABLE invoice (
  invoice_id INT PRIMARY KEY,
  booking_id INT NOT NULL,
  invoice_date DATETIME DEFAULT NOW(),
  subtotal DECIMAL(12,2),
  tax_amount DECIMAL(12,2),
  total_amount DECIMAL(12,2),
  FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE CASCADE
);


DELIMITER $$


CREATE TRIGGER trg_visitor_bi BEFORE INSERT ON visitor
FOR EACH ROW
BEGIN
  DECLARE cnt INT DEFAULT 0;
  SELECT COUNT(*) INTO cnt FROM visitor;
  IF cnt = 0 THEN
    SET NEW.visitor_id = 101;
  ELSE
    SET NEW.visitor_id = (SELECT MAX(visitor_id) + 1 FROM visitor);
  END IF;
END$$


CREATE TRIGGER trg_preferences_bi BEFORE INSERT ON preferences
FOR EACH ROW
BEGIN
  DECLARE cnt INT DEFAULT 0;
  SELECT COUNT(*) INTO cnt FROM visitor WHERE visitor_id = NEW.vid;
  IF cnt = 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'preferences insert failed: visitor id does not exist';
  END IF;
END$$


CREATE TRIGGER trg_monument_bi BEFORE INSERT ON monument
FOR EACH ROW
BEGIN
  DECLARE cnt INT DEFAULT 0;
  SELECT COUNT(*) INTO cnt FROM monument;
  IF cnt = 0 THEN
    SET NEW.monument_id = 101;
  ELSE
    SET NEW.monument_id = (SELECT MAX(monument_id) + 1 FROM monument);
  END IF;
END$$


CREATE TRIGGER trg_experience_bi BEFORE INSERT ON local_experience
FOR EACH ROW
BEGIN
  DECLARE cnt INT DEFAULT 0;
  SELECT COUNT(*) INTO cnt FROM local_experience;
  IF cnt = 0 THEN
    SET NEW.exp_id = 101;
  ELSE
    SET NEW.exp_id = (SELECT MAX(exp_id) + 1 FROM local_experience);
  END IF;
END$$


CREATE TRIGGER trg_guide_bi BEFORE INSERT ON guide
FOR EACH ROW
BEGIN
  DECLARE cnt INT DEFAULT 0;
  SELECT COUNT(*) INTO cnt FROM guide;
  IF cnt = 0 THEN
    SET NEW.guide_id = 101;
  ELSE
    SET NEW.guide_id = (SELECT MAX(guide_id) + 1 FROM guide);
  END IF;
END$$


CREATE TRIGGER trg_itinerary_bi BEFORE INSERT ON itinerary
FOR EACH ROW
BEGIN
  DECLARE cnt INT DEFAULT 0;
  SELECT COUNT(*) INTO cnt FROM itinerary;
  IF cnt = 0 THEN
    SET NEW.itinerary_id = 101;
  ELSE
    SET NEW.itinerary_id = (SELECT MAX(itinerary_id) + 1 FROM itinerary);
  END IF;
END$$


CREATE TRIGGER trg_itinerary_item_bi BEFORE INSERT ON itinerary_item
FOR EACH ROW
BEGIN
  DECLARE cnt INT DEFAULT 0;
  SELECT COUNT(*) INTO cnt FROM itinerary_item;
  IF cnt = 0 THEN
    SET NEW.item_id = 101;
  ELSE
    SET NEW.item_id = (SELECT MAX(item_id) + 1 FROM itinerary_item);
  END IF;
END$$


CREATE TRIGGER trg_booking_bi BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
  DECLARE cnt INT DEFAULT 0;
  SELECT COUNT(*) INTO cnt FROM booking;
  IF cnt = 0 THEN
    SET NEW.booking_id = 101;
  ELSE
    SET NEW.booking_id = (SELECT MAX(booking_id) + 1 FROM booking);
  END IF;
END$$


CREATE TRIGGER trg_payment_bi BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
  DECLARE cnt INT DEFAULT 0;
  SELECT COUNT(*) INTO cnt FROM payment;
  IF cnt = 0 THEN
    SET NEW.payment_id = 101;
  ELSE
    SET NEW.payment_id = (SELECT MAX(payment_id) + 1 FROM payment);
  END IF;
END$$


CREATE TRIGGER trg_alert_bi BEFORE INSERT ON alert_log
FOR EACH ROW
BEGIN
  DECLARE cnt INT DEFAULT 0;
  SELECT COUNT(*) INTO cnt FROM alert_log;
  IF cnt = 0 THEN
    SET NEW.alert_id = 101;
  ELSE
    SET NEW.alert_id = (SELECT MAX(alert_id) + 1 FROM alert_log);
  END IF;
END$$


CREATE TRIGGER trg_invoice_bi BEFORE INSERT ON invoice
FOR EACH ROW
BEGIN
  DECLARE cnt INT DEFAULT 0;
  SELECT COUNT(*) INTO cnt FROM invoice;
  IF cnt = 0 THEN
    SET NEW.invoice_id = 101;
  ELSE
    SET NEW.invoice_id = (SELECT MAX(invoice_id) + 1 FROM invoice);
  END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE FUNCTION fn_distance_km(lat1 DECIMAL(9,6), lon1 DECIMAL(9,6), lat2 DECIMAL(9,6), lon2 DECIMAL(9,6))
RETURNS DECIMAL(9,4)
DETERMINISTIC
BEGIN
  DECLARE R DOUBLE DEFAULT 6371;
  DECLARE dLat DOUBLE; DECLARE dLon DOUBLE; DECLARE a DOUBLE; DECLARE c DOUBLE;
  SET dLat = RADIANS(lat2 - lat1);
  SET dLon = RADIANS(lon2 - lon1);
  SET a = SIN(dLat/2) * SIN(dLat/2) + COS(RADIANS(lat1)) * COS(RADIANS(lat2)) * SIN(dLon/2) * SIN(dLon/2);
  SET c = 2 * ATAN2(SQRT(a), SQRT(1-a));
  RETURN ROUND(R * c,4);
END$$

CREATE FUNCTION fn_avg_rating(p_target_type VARCHAR(20), p_target_id INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
BEGIN
  DECLARE avg_r DECIMAL(4,2) DEFAULT 0.00;
  IF p_target_type = 'MONUMENT' THEN
    SELECT IFNULL(ROUND(AVG(rating),2),0.00) INTO avg_r FROM monument WHERE monument_id = p_target_id;
  ELSEIF p_target_type = 'EXPERIENCE' THEN
    SELECT IFNULL(ROUND(AVG(rating),2),0.00) INTO avg_r FROM local_experience WHERE exp_id = p_target_id;
  ELSEIF p_target_type = 'GUIDE' THEN
    SELECT IFNULL(ROUND(AVG(rating),2),0.00) INTO avg_r FROM guide WHERE guide_id = p_target_id;
  END IF;
  RETURN avg_r;
END$$

DELIMITER ;


DELIMITER $$


CREATE PROCEDURE create_booking(
  IN p_visitor_id INT,
  IN p_booking_type VARCHAR(20),
  IN p_target_id INT,
  IN p_scheduled_date DATETIME,
  IN p_amount DECIMAL(10,2),
  OUT p_status VARCHAR(30)
)
BEGIN
  DECLARE conflict_count INT DEFAULT 0;
  DECLARE cur_occ INT DEFAULT 0;
  DECLARE cap INT DEFAULT 0;

  SET p_status = 'ERROR';


  IF p_booking_type = 'GUIDE' THEN
    SELECT COUNT(*) INTO conflict_count FROM booking
      WHERE booking_type='GUIDE' AND target_id = p_target_id AND status='CONFIRMED'
        AND ABS(TIMESTAMPDIFF(MINUTE, scheduled_date, p_scheduled_date)) < 60;
    IF conflict_count > 0 THEN
      SET p_status = 'CONFLICT_GUIDE';
    END IF;
  END IF;

  
  IF p_booking_type = 'MONUMENT' THEN
    SELECT current_occupancy, visitor_capacity INTO cur_occ, cap FROM monument WHERE monument_id = p_target_id;
    IF cur_occ >= cap THEN
      SET p_status = 'FULL';
    END IF;
  END IF;


  IF p_booking_type = 'EXPERIENCE' THEN
    SELECT COUNT(*) INTO conflict_count FROM booking WHERE booking_type='EXPERIENCE' AND target_id = p_target_id AND DATE(scheduled_date) = DATE(p_scheduled_date) AND status='CONFIRMED';
    SELECT capacity INTO cap FROM local_experience WHERE exp_id = p_target_id;
    IF conflict_count >= cap THEN
      SET p_status = 'FULL';
    END IF;
  END IF;

 IF p_status != 'FULL' AND p_status != 'CONFLICT_GUIDE' THEN
  INSERT INTO booking (visitor_id, booking_type, booking_date, scheduled_date, status, amount, target_id)
    VALUES (p_visitor_id, p_booking_type, NOW(), p_scheduled_date, 'CONFIRMED', p_amount, p_target_id);
END IF;
  SET p_status = 'CONFIRMED';
END$$


CREATE PROCEDURE get_revenue_by_year(IN p_year INT)
BEGIN
  SELECT MONTH(payment_date) AS month, IFNULL(SUM(amount),0) AS revenue
  FROM payment
  WHERE YEAR(payment_date) = p_year
  GROUP BY MONTH(payment_date)
  ORDER BY month;
END$$



CREATE PROCEDURE get_itinerary(IN p_visitor_id INT)
BEGIN
  SELECT i.itinerary_id, i.start_date, i.end_date, it.item_type,
    CASE WHEN it.item_type='MONUMENT' THEN (SELECT name FROM monument WHERE monument_id = it.reference_id)
         WHEN it.item_type='EXPERIENCE' THEN (SELECT name FROM local_experience WHERE exp_id = it.reference_id)
    END AS item_name,
    it.scheduled_start, it.scheduled_end, it.guide_id
  FROM itinerary i
  JOIN itinerary_item it ON it.itinerary_id = i.itinerary_id
  WHERE i.visitor_id = p_visitor_id
  ORDER BY it.scheduled_start;
END$$


CREATE PROCEDURE assign_guide(
  IN p_language VARCHAR(50),
  IN p_expertise VARCHAR(50),
  IN p_scheduled_date DATETIME,
  OUT p_guide_id INT
)
BEGIN
  SELECT g.guide_id INTO p_guide_id
  FROM guide g
  WHERE FIND_IN_SET(p_language, g.languages) AND FIND_IN_SET(p_expertise, g.expertise)
    AND NOT EXISTS (
      SELECT 1 FROM booking b WHERE b.booking_type='GUIDE' AND b.target_id = g.guide_id AND b.status='CONFIRMED'
        AND ABS(TIMESTAMPDIFF(MINUTE, b.scheduled_date, p_scheduled_date)) < 60
    )
  ORDER BY g.hourly_rate ASC
  LIMIT 1;
END$$


CREATE PROCEDURE generate_monument_monthly_report(IN p_month INT, IN p_year INT)
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE m_id INT;
  DECLARE m_name VARCHAR(255);
  DECLARE bcount INT DEFAULT 0;

  DECLARE cur CURSOR FOR SELECT monument_id, name FROM monument;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  CREATE TEMPORARY TABLE IF NOT EXISTS temp_report (monument_id INT, monument_name VARCHAR(255), bookings INT);
  TRUNCATE temp_report;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO m_id, m_name;
    IF done THEN LEAVE read_loop; END IF;

    SELECT COUNT(*) INTO bcount FROM booking WHERE booking_type='MONUMENT' AND target_id = m_id AND MONTH(scheduled_date)=p_month AND YEAR(scheduled_date)=p_year;
    INSERT INTO temp_report VALUES (m_id, m_name, bcount);
  END LOOP;
  CLOSE cur;

  SELECT * FROM temp_report ORDER BY bookings DESC;
END$$


CREATE PROCEDURE generate_itinerary(IN p_visitor_id INT, IN p_start_date DATE, IN p_end_date DATE)
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE m_id INT;

  DECLARE cur CURSOR FOR SELECT monument_id FROM monument WHERE current_status='OPEN' ORDER BY visitor_capacity DESC LIMIT 20;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  INSERT INTO itinerary (visitor_id, start_date, end_date) VALUES (p_visitor_id, p_start_date, p_end_date);

  SET @new_itin = (SELECT MAX(itinerary_id) FROM itinerary);

  OPEN cur;
  loop_it: LOOP
    FETCH cur INTO m_id;
    IF done THEN LEAVE loop_it; END IF;
    INSERT INTO itinerary_item (itinerary_id, item_type, reference_id, scheduled_start, scheduled_end, transport_details, estimated_travel_minutes)
      VALUES (@new_itin, 'MONUMENT', m_id, CONCAT(p_start_date,' 09:00:00'), CONCAT(p_start_date,' 11:00:00'), 'Taxi', 30);
  END LOOP;
  CLOSE cur;

  SELECT @new_itin AS itinerary_id;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER trg_booking_checkin_bu 
BEFORE UPDATE ON booking
FOR EACH ROW
BEGIN
  
  IF OLD.checkin_time IS NULL AND NEW.checkin_time IS NOT NULL THEN
    IF NEW.booking_type = 'MONUMENT' THEN
    
      SET NEW.occupancy_snapshot = (
        SELECT current_occupancy 
        FROM monument 
        WHERE monument_id = NEW.target_id
      );

    END IF;
  END IF;
END$$



CREATE TRIGGER trg_booking_checkin_ai 
AFTER UPDATE ON booking
FOR EACH ROW
BEGIN
  IF OLD.checkin_time IS NULL AND NEW.checkin_time IS NOT NULL THEN
    IF NEW.booking_type = 'MONUMENT' THEN
      
      
      UPDATE monument 
      SET current_occupancy = current_occupancy + 1 
      WHERE monument_id = NEW.target_id;

      
      IF (
        SELECT current_occupancy 
        FROM monument 
        WHERE monument_id = NEW.target_id
      ) >
      (
        SELECT visitor_capacity 
        FROM monument 
        WHERE monument_id = NEW.target_id
      ) THEN

        INSERT INTO alert_log (monument_id, alert_type, message, severity)
        VALUES (
          NEW.target_id,
          'CAPACITY_EXCEEDED',
          'Occupancy exceeded capacity',
          'CRITICAL'
        );

      END IF;

    END IF;
  END IF;
END$$


CREATE TRIGGER trg_booking_checkout_au 
AFTER UPDATE ON booking
FOR EACH ROW
BEGIN
  IF OLD.checkout_time IS NULL AND NEW.checkout_time IS NOT NULL THEN
    IF NEW.booking_type = 'MONUMENT' THEN
      
      UPDATE monument
      SET current_occupancy = GREATEST(0, current_occupancy - 1)
      WHERE monument_id = NEW.target_id;

    END IF;
  END IF;
END$$

DELIMITER ;



CREATE OR REPLACE VIEW v_top_monuments AS
SELECT m.monument_id, m.name, COUNT(b.booking_id) AS bookings_count, IFNULL(ROUND(m.rating,2),0) AS avg_rating
FROM monument m
LEFT JOIN booking b ON b.booking_type='MONUMENT' AND b.target_id = m.monument_id
GROUP BY m.monument_id
ORDER BY bookings_count DESC;

CREATE OR REPLACE VIEW v_current_occupancy AS
SELECT monument_id, name, visitor_capacity, current_occupancy, ROUND((current_occupancy/ GREATEST(visitor_capacity,1))*100,2) AS fill_percent
FROM monument;


DELIMITER $$

CREATE PROCEDURE display_menu()
BEGIN
    SELECT 'MENU'
    UNION SELECT '1 - Show All Monuments'
    UNION SELECT '2 - Show All Guides'
    UNION SELECT '3 - Show All Visitors'
    UNION SELECT '4 - Show All Bookings'
    UNION SELECT '5 - Get Revenue By Year (p1=year)'
    UNION SELECT '6 - Monthly Monument Report (p1=month, p2=year)'
    UNION SELECT '7 - Get Itinerary (p1=visitor_id)'
    UNION SELECT '8 - Exit';
END$$

CREATE PROCEDURE main_menu(IN choice INT, IN p1 INT, IN p2 INT)
BEGIN
  CASE choice
    WHEN 1 THEN SELECT monument_id, name, location_city, location_state, visitor_capacity, current_occupancy, entry_fee, current_status, rating FROM monument;
    WHEN 2 THEN SELECT guide_id, name, languages, expertise, hourly_rate, phone, availability, rating FROM guide;
    WHEN 3 THEN SELECT visitor_id, name, email, phone, country, created_at FROM visitor;
    WHEN 4 THEN SELECT booking_id, visitor_id, booking_type, target_id, scheduled_date, checkin_time, checkout_time, status, amount, payment_status FROM booking ORDER BY booking_date DESC LIMIT 200;
    WHEN 5 THEN CALL get_revenue_by_year(p1);
    WHEN 6 THEN CALL generate_monument_monthly_report(p1, p2);
    WHEN 7 THEN CALL get_itinerary(p1);
    WHEN 8 THEN SELECT 'Exit' AS msg;
    ELSE SELECT 'Invalid option' AS msg;
  END CASE;
END$$

DELIMITER ;
