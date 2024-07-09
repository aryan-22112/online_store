drop database if exists ShopSmart;
CREATE DATABASE ShopSmart;
USE ShopSmart;
DROP TABLE IF EXISTS posts;

CREATE TABLE Admin_(
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    password VARCHAR(100) NOT NULL CHECK (LENGTH(password) >= 8),
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    mobile_num VARCHAR(10) UNIQUE CHECK (LENGTH(mobile_num) = 10),
    email_id VARCHAR(100) UNIQUE CHECK (email_id LIKE '%@%.%')
);

INSERT INTO Admin_ (admin_id, password, first_name, last_name, mobile_num, email_id) 
VALUES
(1, 'password1', 'John', 'Doe', 1234567899, 'john.doe@example.com'),
(2, 'password2', 'Jane', 'Smith', 2345678901, 'jane.smith@example.com'),
(3, 'password3', 'Michael', 'Johnson', 3456789012, 'michael.johnson@example.com'),
(4, 'password4', 'Karan', 'Goyal', 4567890123, 'KaranG@example.com'),
(5, 'password5', 'David', 'Martinez', 5678901234, 'david.martinez@example.com'),
(6, 'password6', 'Sarah', 'Wilson', 6789012345, 'sarah.wilson@example.com'),
(7, 'password7', 'Daniel', 'Taylor', 7890123456, 'daniel.taylor@example.com'),
(8, 'password8', 'Jessica', 'Anderson', 8901234567, 'jessica.anderson@example.com'),
(9, 'password9', 'Shivam', 'Jindal', 9012345678, 'Shivam.J@example.com'),
(10, 'password10', 'Amanda', 'Hernandez', 1234567890, 'amanda.hernandez@example.com');

CREATE TABLE Customer(
	customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,	
    password VARCHAR(50) NOT NULL CHECK(LENGTH(password) >= 8) ,
    contact VARCHAR(50) CHECK (LENGTH(contact) = 10),
    login_id VARCHAR(50) NOT NULL
);

INSERT INTO Customer (customer_id, first_name, last_name, password, contact, login_id) 
VALUES 
(101, 'Alice', 'Johnson', 'pass1293', '5551234567', 'alice.johnson@example.com'),
(102, 'Bob', 'Smith', 'secret321', '5559876543', 'bob.smith@example.com'),
(103, 'Charlie', 'Brown', 'p@ssw0rd', '5554567890', 'charlie.brown@example.com'),
(104, 'Diana', 'Miller', 'securepass', '5557891234', 'diana.miller@example.com'),
(105, 'Ethan', 'Davis', 'qwerty902', '5552345678', 'ethan.davis@example.com'),
(106, 'Fiona', 'Wilson', 'password123', '5555678901', 'fiona.wilson@example.com'),
(107, 'George', 'Martinez', 'letmein34', '5556789012', 'george.martinez@example.com'),
(108, 'Hannah', 'Anderson', 'hello123', '5553456789', 'hannah.anderson@example.com'),
(109, 'Ian', 'Thompson', 'p@ssw0rd', '5558901234', 'ian.thompson@example.com'),
(110, 'Jasmine', 'Garcia', 'welcome123', '5554567899', 'jasmine.garcia@example.com');

CREATE TABLE Order_Fulfillment_Centre (
    ofc_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    no_of_working_staff INT NOT NULL CHECK (no_of_working_staff >= 0),
    location VARCHAR(255) NOT NULL
);

INSERT INTO Order_Fulfillment_Centre (ofc_id, no_of_working_staff, location) 
VALUES 
(1, 20, 'Maharashtra'),
(2, 15, 'Uttar Pradesh'),
(3, 25, 'Bihar'),
(4, 18, 'West Bengal'),
(5, 22, 'Andhra Pradesh'),
(6, 17, 'Madhya Pradesh'),
(7, 30, 'Tamil Nadu'),
(8, 16, 'Rajasthan'),
(9, 23, 'Karnataka'),
(10, 19, 'Gujarat');


CREATE TABLE Worker (
    worker_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    salary DECIMAL(10, 2) NOT NULL CHECK (salary >= 0),
    email VARCHAR(255) UNIQUE CHECK (email LIKE '%@%.%'),
    mobile VARCHAR(15) UNIQUE CHECK (LENGTH(mobile) = 10),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    admin_id INT,
    ofc_id INT,
    FOREIGN KEY (admin_id) REFERENCES Admin_(admin_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ofc_id) REFERENCES Order_Fulfillment_Centre(ofc_id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TRIGGER update_worker_count
AFTER INSERT ON Worker
FOR EACH ROW
BEGIN
    -- Update the total number of workers in the Order Fulfillment Centre
    UPDATE Order_Fulfillment_Centre
    SET no_of_working_staff = no_of_working_staff + 1
    WHERE ofc_id = NEW.ofc_id;
END;


CREATE TRIGGER decrease_worker_count
AFTER DELETE ON Worker
FOR EACH ROW
BEGIN
    -- Update the total number of workers in the Order Fulfillment Centre
    UPDATE Order_Fulfillment_Centre
    SET no_of_working_staff = no_of_working_staff - 1
    WHERE ofc_id = OLD.ofc_id;
END;



INSERT INTO Worker (worker_id, salary, email, mobile, first_name, last_name, admin_id,ofc_id) 
VALUES 
(1, 48000.00, 'worker1@example.com', '1234567890', 'Moon', 'Chaewon', 1,1),
(2, 55000.00, 'worker2@example.com', '2345678901', 'Samantha', 'White', 2,2),
(3, 50000.00, 'worker3@example.com', '3456789012', 'Brandon', 'Lee', 3,3),
(4, 62000.00, 'worker4@example.com', '4567890123', 'Rachel', 'Garcia', 4,4),
(5, 58000.00, 'worker5@example.com', '5678901234', 'Eric', 'Rodriguez', 5,5),
(6, 45000.00, 'worker6@example.com', '6789012345', 'Natalie', 'King', 6,6),
(7, 53000.00, 'worker7@example.com', '7890123456', 'Justin', 'Martinez', 7,7),
(8, 67000.00, 'worker8@example.com', '8901234567', 'Olivia', 'Hernandez', 8,8),
(9, 51000.00, 'worker9@example.com', '9012345678', 'Aaron', 'Thomas', 9,9),
(10, 42000.00, 'worker10@example.com', '0123456789', 'Sophie', 'Nguyen', 10,10);

CREATE TABLE Seller (
    seller_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY ,
    password VARCHAR(255) NOT NULL CHECK (LENGTH(password) >= 8),
    email VARCHAR(255) UNIQUE CHECK (email LIKE '%@%.%'),
    phone_number VARCHAR(15) UNIQUE CHECK (LENGTH(phone_number) = 10),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    admin_id INT NOT NULL,
    FOREIGN KEY (admin_id) REFERENCES Admin_(admin_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

INSERT INTO Seller (seller_id, password, email, phone_number, first_name, last_name, admin_id) 
VALUES 
(1, 'sellerpass1', 'seller1@example.com', '1234567890', 'Mandeep', 'Singh', 1),
(2, 'sellerpass2', 'seller2@example.com', '2345678901', 'Park', 'Jihyo', 2),
(3, 'sellerpass3', 'seller3@example.com', '3456789012', 'Mandy', 'Rose', 3),
(4, 'sellerpass4', 'seller4@example.com', '4567890123', 'Im', 'Nayeon', 4),
(5, 'sellerpass5', 'seller5@example.com', '5678901234', 'Sendy', 'Wendy', 5),
(6, 'sellerpass6', 'seller6@example.com', '6789012345', 'Finn', 'Henny', 6),
(7, 'sellerpass7', 'seller7@example.com', '7890123456', 'Roman', 'Reigns', 7),
(8, 'sellerpass8', 'seller8@example.com', '8901234567', 'Bhaskar', 'Kashyap', 8),
(9, 'sellerpass9', 'seller9@example.com', '9012345678', 'Kim', 'Jongun', 9),
(10, 'sellerpass10', 'seller10@example.com', '0123456789', 'Aladdin', 'Singh', 10);

CREATE TABLE Category(
	category_id INT PRIMARY KEY,
    Name VARCHAR(200) UNIQUE NOT NULL
);

INSERT INTO Category (category_id, Name) 
VALUES 
(1, 'Electronics'),
(2, 'Clothing'),
(3, 'Home and Kitchen'),
(4, 'Books'),
(5, 'Sports and Outdoors'),
(6, 'Beauty and Personal Care'),
(7, 'Toys and Games'),
(8, 'Health and Household'),
(9, 'Automotive'),
(10, 'Tools and Home Improvement');


CREATE TABLE Product(
	product_id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(200) NOT NULL,
    brand VARCHAR(200),
    price FLOAT  NOT NULL CHECK (price >= 0),
    availaiblity_status BIT,
    category_id INT NOT NULL,
    seller_id INT NOT NULL,
    rating DECIMAL(3, 2) DEFAULT 0,
	FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT CHK_availability_status CHECK (availaiblity_status IN (0, 1))
);

INSERT INTO Product (product_id, name, brand, price,availaiblity_status,category_id, seller_id,rating) 
VALUES 
(1, 'Laptop', 'Dell', 999.99, 1, 1, 1,0),
(11, 'Laptop', 'Dell', 999.99, 1, 1, 1,0),
(12, 'Laptop', 'Dell', 999.99, 1, 1, 1,0),
(13, 'Laptop', 'Dell', 999.99, 1, 1, 1,0),
(14, 'Laptop', 'Dell', 999.99, 1, 1, 1,0),

(2, 'T-shirt', 'Nike', 29.99, 1, 2, 2,0),
(15, 'T-shirt', 'Nike', 29.99, 1, 2, 2,0),
(16, 'T-shirt', 'Nike', 29.99, 1, 2, 2,0),
(17, 'T-shirt', 'Nike', 29.99, 1, 2, 2,0),
(18, 'T-shirt', 'Nike', 29.99, 1, 2, 2,0),

(3, 'Cookware Set', 'Prestige', 49.99, 1, 3, 3,0),
(19, 'Cookware Set', 'Prestige', 49.99, 1, 3, 3,0),
(20, 'Cookware Set', 'Prestige', 49.99, 1, 3, 3,0),
(21, 'Cookware Set', 'Prestige', 49.99, 1, 3, 3,0),
(22, 'Cookware Set', 'Prestige', 49.99, 1, 3, 3,0),

(4, 'Novel', 'Penguin', 12.99, 1, 4, 4,0),
(23, 'Novel', 'Penguin', 12.99, 1, 4, 4,0),
(24, 'Novel', 'Penguin', 12.99, 1, 4, 4,0),
(25, 'Novel', 'Penguin', 12.99, 1, 4, 4,0),
(26, 'Novel', 'Penguin', 12.99, 1, 4, 4,0),


(5, 'Yoga Mat', 'Lululemon', 39.99, 1, 5, 5,0),
(27, 'Yoga Mat', 'Lululemon', 39.99, 1, 5, 5,0),
(28, 'Yoga Mat', 'Lululemon', 39.99, 1, 5, 5,0),
(29, 'Yoga Mat', 'Lululemon', 39.99, 1, 5, 5,0),
(30, 'Yoga Mat', 'Lululemon', 39.99, 1, 5, 5,0),

(6, 'Shampoo', 'Pantene', 9.99, 1, 6, 6,0),
(31, 'Shampoo', 'Pantene', 9.99, 1, 6, 6,0),
(32, 'Shampoo', 'Pantene', 9.99, 1, 6, 6,0),
(33, 'Shampoo', 'Pantene', 9.99, 1, 6, 6,0),
(34, 'Shampoo', 'Pantene', 9.99, 1, 6, 6,0),

(7, 'Board Game', 'Hasbro', 24.99, 1, 7, 7,0),
(35, 'Board Game', 'Hasbro', 24.99, 1, 7, 7,0),
(36, 'Board Game', 'Hasbro', 24.99, 1, 7, 7,0),
(37, 'Board Game', 'Hasbro', 24.99, 1, 7, 7,0),
(38, 'Board Game', 'Hasbro', 24.99, 1, 7, 7,0),

(8, 'Vitamin Supplements', 'Nature Made', 19.99, 1, 8, 8,0),
(39, 'Vitamin Supplements', 'Nature Made', 19.99, 1, 8, 8,0),
(40, 'Vitamin Supplements', 'Nature Made', 19.99, 1, 8, 8,0),
(41, 'Vitamin Supplements', 'Nature Made', 19.99, 1, 8, 8,0),
(42, 'Vitamin Supplements', 'Nature Made', 19.99, 1, 8, 8,0),

(9, 'Car Accessories Kit', 'Meguiars', 59.99, 1, 9, 9,0),
(43, 'Car Accessories Kit', 'Meguiars', 59.99, 1, 9, 9,0),
(44, 'Car Accessories Kit', 'Meguiars', 59.99, 1, 9, 9,0),
(45, 'Car Accessories Kit', 'Meguiars', 59.99, 1, 9, 9,0),
(46, 'Car Accessories Kit', 'Meguiars', 59.99, 1, 9, 9,0),

(10, 'Power Drill', 'Bosch', 79.99, 1, 10, 10,0),
(47, 'Power Drill', 'Bosch', 79.99, 1, 10, 10,0),
(48, 'Power Drill', 'Bosch', 79.99, 1, 10, 10,0),
(49, 'Power Drill', 'Bosch', 79.99, 1, 10, 10,0),
(50, 'Power Drill', 'Bosch', 79.99, 1, 10, 10,0);


CREATE TABLE IF NOT EXISTS Special_Offers (
    offer_id INT AUTO_INCREMENT NOT NULL,
    offer_code VARCHAR(100) NOT NULL,
    maximum_discount DECIMAL(10, 2) CHECK (maximum_discount >= 0), 
    percentage_discount DECIMAL(5, 2) CHECK (percentage_discount BETWEEN 0 AND 100),
    minimum_order_value DECIMAL(10, 2) CHECK (minimum_order_value >= 0),
    admin_id INT NOT NULL,
    PRIMARY KEY (offer_id),
    foreign key(admin_id) REFERENCES Admin_(admin_id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO Special_Offers (offer_id, offer_code, maximum_discount, percentage_discount, minimum_order_value, admin_id) 
VALUES 
(1, 'OFFER10', 50.00, 10.00, 100.00, 1),
(2, 'SALE20', 100.00, 20.00, 150.00, 2),
(3, 'DISCOUNT15', 75.00, 15.00, 80.00, 3),
(4, 'SAVEBIG', 200.00, 25.00, 200.00, 4),
(5, 'DEAL25', 150.00, 25.00, 120.00, 5),
(6, 'SUPER5', 30.00, 5.00, 50.00, 6),
(7, 'HOTDEAL', 80.00, 18.00, 90.00, 7),
(8, 'MEGASALE', 250.00, 30.00, 180.00, 8),
(9, 'BARGAIN50', 300.00, 40.00, 250.00, 9),
(10, 'FLASHSALE', 100.00, 20.00, 70.00, 10);

CREATE TABLE Cart(
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    final_amount FLOAT CHECK (final_amount >= 0),
    total_value FLOAT CHECK (total_value >= 0),
    product_count INT NOT NULL CHECK (product_count >= 0),
    customer_id INT NOT NULL,
    offer_id INT,
    FOREIGN KEY (offer_id) REFERENCES Special_Offers(offer_id) ON UPDATE CASCADE ,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO Cart (cart_id, final_amount, total_value, product_count, customer_id, offer_id) 
VALUES 
(1, 99.99, 120.00, 3, 101, 1),
(2, 57.00, 60.00, 1, 102, 6),
(3, 47.50, 50.00, 1, 103, 6),
(4, 90.00, 100, 2, 104, 1),  
(5, 149.99, 200.00, 3, 105, 5),   
(6, 85.50, 90.00, 3, 106, 6),   
(7, 123.00, 150.00, 3, 107, 7),   
(8, 196.00, 280.00, 4, 108, 8),
(9, 47.50, 50.00, 1, 109, 6),
(10, 899.99, 999.99, 1, 110, 10);




CREATE TABLE IF NOT EXISTS Delivery_Boy (
    delivery_boy_id INT AUTO_INCREMENT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(15) NOT NULL,
    email_id VARCHAR(100) NOT NULL UNIQUE CHECK (email_id LIKE '%@%.%'),
    rating INT CHECK (rating >= 0 AND rating <= 5),
    salary DECIMAL(10, 2) CHECK (salary >= 0),
    ofc_id INT NOT NULL,
    admin_id INT NOT NULL,
	orders_delivered INT, 
    PRIMARY KEY (delivery_boy_id),
    FOREIGN KEY (ofc_id) REFERENCES Order_Fulfillment_Centre(ofc_id) ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (admin_id) REFERENCES Admin_(admin_id) ON DELETE CASCADE ON UPDATE CASCADE
);


INSERT INTO Delivery_Boy (delivery_boy_id, first_name, last_name, mobile_number, email_id, rating, salary, ofc_id, admin_id,orders_delivered) 
VALUES 
(1, 'Mark', 'Johnson', '1234567890', 'mark.johnson@example.com', 4, 2500.00, 1, 2,1),
(2, 'Emma', 'Davis', '9876543210', 'emma.davis@example.com', 5, 2800.00, 2, 2,1),
(3, 'Daniel', 'Brown', '4567890123', 'daniel.brown@example.com', 3, 2200.00, 3, 2,1),
(4, 'Olivia', 'Wilson', '7890123456', 'olivia.wilson@example.com', 4, 2600.00, 4, 2,1),
(5, 'James', 'Martinez', '2345678901', 'james.martinez@example.com', 5, 3000.00, 5, 2,1),
(6, 'Sophia', 'Taylor', '8901234567', 'sophia.taylor@example.com', 4, 2700.00, 6, 2,1),
(7, 'William', 'Hernandez', '3456789012', 'william.hernandez@example.com', 3, 2300.00, 7, 2,1),
(8, 'Isabella', 'Garcia', '9012345678', 'isabella.garcia@example.com', 4, 2600.00, 8, 2,1),
(9, 'Alexander', 'Lopez', '5678901234', 'alexander.lopez@example.com', 5, 2900.00, 9, 2,1),
(10, 'Mia', 'Young', '0123456789', 'mia.young@example.com', 3, 2400.00, 10, 2,1);

CREATE TABLE Order_ (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_time VARCHAR(12) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    shipping_address VARCHAR(100) NOT NULL,
    payment_mode VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    amount INT NOT NULL CHECK (amount >= 0),
    cart_id INT NOT NULL,
    ofc_id INT NOT NULL,
    delivery_boy_id INT NOT NULL,
    FOREIGN KEY (cart_id) REFERENCES Cart(cart_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ofc_id) REFERENCES Order_Fulfillment_Centre(ofc_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (delivery_boy_id) REFERENCES Delivery_Boy(delivery_boy_id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO Order_ (order_id, order_time, quantity, shipping_address, payment_mode, order_date, amount, cart_id, ofc_id,delivery_boy_id) 
VALUES 
(1, '10:30 AM', 3, '123 Main St, City, State, 12345', 'Credit Card', '2024-02-12', 99, 1, 1,1),
(2, '11:45 AM', 2, '456 Elm St, City, State, 23456', 'PayPal', '2024-02-12', 49, 2, 2,2),
(3, '12:15 PM', 5, '789 Oak St, City, State, 34567', 'Debit Card', '2024-02-13', 199, 3, 3,3),
(4, '01:30 PM', 4, '321 Pine St, City, State, 45678', 'Cash on Delivery', '2024-02-13', 299, 4, 4,4),
(5, '02:45 PM', 3, '654 Maple St, City, State, 56789', 'Credit Card', '2024-02-14', 149, 5, 5,5),
(6, '03:30 PM', 2, '987 Birch St, City, State, 67890', 'PayPal', '2024-02-14', 74, 6, 6,6),
(7, '04:15 PM', 3, '234 Cedar St, City, State, 78901', 'Debit Card', '2024-02-15', 124, 7, 7,7),
(8, '05:00 PM', 6, '567 Walnut St, City, State, 89012', 'Cash on Delivery', '2024-02-15', 224, 8, 8,8),
(9, '05:45 PM', 1, '890 Pineapple St, City, State, 90123', 'Credit Card', '2024-02-16', 39, 9, 9,9),
(10, '06:30 PM', 2, '123 Orange St, City, State, 01234', 'PayPal', '2024-02-16', 89, 10, 10,10);


CREATE TABLE Contains_Products(
    cart_id INT,
    product_id INT,
    PRIMARY KEY (cart_id, product_id),
    FOREIGN KEY (cart_id) REFERENCES Cart(cart_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO Contains_Products (cart_id, product_id) VALUES
(1, 10),(1, 5),
(2, 9),
(3, 19),
(4,21),(4,22),
(5,50),(5,45),(5,46),
(6,35),(6,36),(6,27),
(7,2),(7,43),(7,44),
(8,47),(8,48),(8,49),(8,30),
(9,3),
(10, 1);


CREATE TABLE adds_seller(
    admin_id INT,
    seller_id INT NOT NULL,
    PRIMARY KEY (admin_id, seller_id),
    FOREIGN KEY (admin_id) REFERENCES Admin_(admin_id)  ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO adds_seller (admin_id, seller_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 4),
(2, 5),
(2, 6),
(3, 7),
(3, 8),
(3, 9),
(4,10);

CREATE TABLE views_orders (
    admin_id INT,
    order_id INT,
    total_orders INT NOT NULL DEFAULT 0,
    PRIMARY KEY (admin_id, order_id),
    FOREIGN KEY (admin_id) REFERENCES Admin_(admin_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (order_id) REFERENCES Order_(order_id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO views_orders (admin_id, order_id, total_orders) VALUES
(1, 1, 5),
(2, 2, 3),
(3, 3, 7);


CREATE TABLE Stores(
   ofc_id INT,
   product_id INT,
   PRIMARY KEY(ofc_id,product_id),
   FOREIGN KEY(ofc_id) REFERENCES Order_Fulfillment_Centre(ofc_id) ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY(product_id) REFERENCES Product(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO Stores (ofc_id, product_id) VALUES
(1, 2),(1, 3),(1, 4),(1, 5),(1, 6),(1, 7),(1, 8),(1, 9),(1, 10),
(2,11),(2,15),(2,19),(2,35),(2,39),(2,43),(2,47),
(3,12),(3,32),(3,36),(3,40),(3,44),(3,48),
(4,13),(4,17),(4,21),(4,25),(4,29),(4,33),(4,37),(4,41),(4,45),(4,49),
(5,14),(5,18),(5,22),(5,26),(5,30),(5,34),(5,38),
(6,42),(6,46),(6,50),
(7,16),(7,20),
(8,1),
(9,23),(9,27),(9,31),
(10,24),(10,28);

CREATE TABLE Product_Feedback(
	review_id INT AUTO_INCREMENT,
	body VARCHAR(200) NOT NULL,
    dt DATE NOT NULL,
    rating INT CHECK (rating >= 0 AND rating <= 5),
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (review_id,product_id,customer_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TRIGGER update_product_rating
AFTER INSERT ON Product_Feedback
FOR EACH ROW
BEGIN
    DECLARE total_rating DECIMAL(5, 2);
    DECLARE total_feedbacks INT;
    DECLARE avg_rating DECIMAL(3, 2);

    -- Calculate total rating for the product
    SELECT SUM(rating) INTO total_rating
    FROM Product_Feedback
    WHERE product_id = NEW.product_id;

    -- Count total feedbacks for the product
    SELECT COUNT(*) INTO total_feedbacks
    FROM Product_Feedback
    WHERE product_id = NEW.product_id;

    -- Calculate average rating
    IF total_feedbacks > 0 THEN
        SET avg_rating = total_rating / total_feedbacks;
    ELSE
        SET avg_rating = 0;
    END IF;

    -- Update product rating in the Product table
    UPDATE Product
    SET rating = avg_rating
    WHERE product_id = NEW.product_id;
END;


INSERT INTO Product_Feedback (review_id, body, dt, rating, customer_id, product_id) VALUES
(1, 'Great laptop, fast delivery!', '2024-02-10', 4, 101, 1),
(2, 'Excellent quality shirt, highly recommended!', '2024-02-11', 5, 102, 2),
(3, 'Average cookware set, could be better', '2024-02-12', 3, 103, 3),
(4, 'Enjoyed reading this novel, highly recommended!', '2024-02-13', 4, 104, 4),
(5, 'Great yoga mat, good quality!', '2024-02-14', 5, 105, 5);

CREATE TABLE selects(
    category_id INT,
    customer_id INT,
    PRIMARY KEY (category_id,customer_id),
    FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO selects(category_id, customer_id) VALUES
(1, 101),
(2, 101),
(3, 101),
(4, 102),
(5, 102),
(6, 102),
(7, 103),
(8, 103),
(9, 103),
(10, 110);

CREATE TABLE sells(
	seller_id INT,
    product_id INT,
    products_sold INT CHECK (products_sold >= 0),
    PRIMARY KEY (seller_id,product_id),
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO sells (seller_id, product_id, products_sold) VALUES
(1, 1, 100), 
(4, 2, 150), 
(1, 3, 80),  
(7, 4, 200), 
(2, 5, 120), 
(8, 6, 90),  
(3, 7, 300), 
(3, 8, 250), 
(6, 9, 180), 
(5, 10, 69),
(1, 11, 22),
(1, 12, 23),
(1, 13, 24),
(1, 14, 55),
(1, 15, 77),
(2, 16, 52),
(2, 17, 44),
(2, 18, 99),
(2, 19, 111),
(2, 20, 420),
(3, 21, 852),
(3, 22, 746),
(3, 23, 746),
(3, 24, 963),
(3, 25, 1),
(4, 26, 33),
(4, 27, 44),
(4, 28, 99),
(4, 29, 14),
(4, 30, 33),
(5, 31, 445),
(5, 32, 710),
(5, 33, 963),
(5, 34, 136),
(5, 35, 433),
(6, 36, 555),
(6, 37, 441),
(6, 38, 777),
(6, 39, 666),
(6, 40, 69),
(7, 41, 93),
(7, 42, 62),
(7, 43, 2),
(7, 44, 42),
(7, 45, 96),
(8, 46, 9),
(8, 47, 64),
(8, 48, 32),
(8, 49, 54),
(8, 50, 765);

CREATE TABLE IF NOT EXISTS Store_Feedback (
    SR_id INT NOT NULL,
    body VARCHAR(250) NOT NULL,
    rating INT NOT NULL CHECK (rating >= 0 AND rating <= 5),
    f_date DATE NOT NULL,
    customer_id INT NOT NULL,
    PRIMARY KEY (SR_id,customer_id),
    FOREIGN KEY(customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO Store_Feedback (SR_id, body, rating, f_date, customer_id) VALUES
(1, 'Great experience, excellent customer service!', 4, '2024-02-10', 101),
(2, 'Awesome store, quick delivery!', 5, '2024-02-11', 102),
(3, 'Average experience, could improve delivery time', 3, '2024-02-12', 103);