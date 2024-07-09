from flask import Flask, request, render_template, redirect, url_for, flash, session
import mysql.connector

app = Flask(__name__)
app.secret_key = 'secret'

# Database configuration
db_config = { 
    'user': 'root',
    'password': 'EcamIiot12#',
    'host': 'localhost',
    'database': 'ShopSmart'
}


# Initialize database
def init_db():
    with open('init_db.sql', 'r') as f:
        sql_script = f.read()

    connection = mysql.connector.connect(user=db_config['user'],
                                         password=db_config['password'],
                                         host=db_config['host'])
    cursor = connection.cursor()
    for result in cursor.execute(sql_script, multi=True):
        pass
    connection.commit()
    cursor.close()
    connection.close()
    print("Database initialized successfully!")

# Landing page
@app.route('/')
def index():
    session['user_id'] = -1
    session['seller_id'] = -1
    return render_template('index.html')

# User options
@app.route('/user_options')
def user_options():
    return render_template('user_options.html')

# Seller options
@app.route('/seller_options')
def seller_options():
    return render_template('seller_options.html')

# Admin options
@app.route('/admin_options')
def admin_options():
    return render_template('admin_options.html')

# Register customer (user) with cart creation
def register_customer(conn, first_name, last_name, password, contact, login_id):
    try:
        cursor = conn.cursor()
        # Insert customer data into the Customer table
        sql_query = """
        INSERT INTO Customer (first_name, last_name, password, contact, login_id) 
        VALUES (%s, %s, %s, %s, %s)
        """
        cursor.execute(sql_query, (first_name, last_name, password, contact, login_id))
        customer_id = cursor.lastrowid

        # Insert into Cart table
        cursor.execute("""
            INSERT INTO Cart (final_amount, total_value, product_count, customer_id, offer_id)
            VALUES (0, 0, 0, %s, 1)
        """, (customer_id,))

        # Commit the transaction
        conn.commit()
        print("Customer and Cart added successfully.")
        return True

    except mysql.connector.Error as e:
        # Rollback if any error occurs
        conn.rollback()
        print("Error adding customer:", e)
        return False

# User registration
@app.route('/user_register', methods=['GET', 'POST'])
def user_register():
    if request.method == 'POST':
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        password = request.form['password']
        contact = request.form['contact']
        login_id = request.form['login_id']

        connection = mysql.connector.connect(**db_config)
        if register_customer(connection, first_name, last_name, password, contact, login_id):
            flash('User registered successfully!', 'success')
            return redirect(url_for('user_login'))
        else:
            flash('Error registering user.', 'danger')
        connection.close()

    return render_template('user_register.html')

# User login
@app.route('/user_login', methods=['GET', 'POST'])
def user_login():
    if request.method == 'POST':
        login_id = request.form['login_id']
        password = request.form['password']
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor()
        cursor.execute("SELECT customer_id FROM Customer WHERE login_id = %s AND password = %s", (login_id, password))
        user = cursor.fetchone()
        if user:
            session['user_id'] = user[0]
            return redirect(url_for('user_menu'))
        else:
            flash('Invalid credentials, please try again.', 'danger')
        connection.close()
    return render_template('user_login.html')

# Seller login
@app.route('/seller_login', methods=['GET', 'POST'])
def seller_login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor()
        cursor.execute("SELECT seller_id FROM Seller WHERE email = %s AND password = %s", (email, password))
        seller = cursor.fetchone()
        if seller:
            session['seller_id'] = seller[0]
            return redirect(url_for('seller_menu'))
        else:
            flash('Invalid credentials, please try again.', 'danger')
        connection.close()
    return render_template('seller_login.html')



# Admin login
@app.route('/admin_login', methods=['GET', 'POST'])
def admin_login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor()
        cursor.execute("SELECT admin_id FROM Admin_ WHERE email_id = %s AND password = %s", (email, password))
        admin = cursor.fetchone()
        if admin:
            session['admin_id'] = admin[0]
            return redirect(url_for('admin_menu'))
        else:
            flash('Invalid credentials, please try again.', 'danger')
        connection.close()
    return render_template('admin_login.html')

# Admin menu
@app.route('/admin_menu')
def admin_menu():
    return render_template('admin_menu.html')

# User menu
@app.route('/user_menu')
def user_menu():
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    cursor.execute("SELECT category_id, name FROM Category")
    categories = cursor.fetchall()

    connection.close()

    return render_template('user_menu.html', categories=categories)

# Seller menu
@app.route('/seller_menu')
def seller_menu():
    seller_id = session.get('seller_id')
    if not seller_id:
        return redirect(url_for('seller_login'))

    return render_template('seller_menu.html')

@app.route('/sell_product', methods=['GET', 'POST'])
def sell_product():
    seller_id = session.get('seller_id')
    if seller_id == -1:
        return redirect(url_for('seller_login'))

    # Fetching categories from the database
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor(dictionary=True)  # Use dictionary cursor for easier data access

    try:
        # Fetch all categories
        cursor.execute("SELECT category_id, name FROM Category")
        categories = cursor.fetchall()

        if request.method == 'POST':
            name = request.form['name']
            brand = request.form['brand']
            price = float(request.form['price'])
            quantity = int(request.form['quantity'])
            category = request.form['category']

            # Insert product into Product table
            for _ in range(quantity):
                cursor.execute("""
                    INSERT INTO Product (name, brand, price, availaiblity_status, category_id, seller_id, rating)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                """, (name, brand, price, 1, category, seller_id, 0))

            product_id_end = cursor.lastrowid

            # Record sale in Sells table
            cursor.execute("""
                INSERT INTO Sells (seller_id, product_id, products_sold)
                VALUES (%s, %s, %s)
            """, (seller_id, product_id_end, quantity))

            connection.commit()
            flash('Product successfully added for sale!', 'success')

    except mysql.connector.Error as e:
        connection.rollback()
        flash(f'Error adding product: {e}', 'danger')

    finally:
        cursor.close()
        connection.close()

    return render_template('sell_product.html', categories=categories)


# Route to change product cost
@app.route('/change_product_cost', methods=['GET', 'POST'])
def change_product_cost():
    seller_id = session.get('seller_id')
    if not seller_id:
        return redirect(url_for('seller_login'))

    if request.method == 'POST':
        product_id = int(request.form['product_id'])
        new_price = float(request.form['new_price'])

        connection = mysql.connector.connect(**db_config)
        try:
            cursor = connection.cursor()

            # Check if the product belongs to the seller
            cursor.execute("SELECT seller_id FROM Product WHERE product_id = %s", (product_id,))
            result = cursor.fetchone()

            if result and result[0] == seller_id:
                # Update the price of the product
                cursor.execute("UPDATE Product SET price = %s WHERE product_id = %s", (new_price, product_id))
                connection.commit()
                flash('Product price updated successfully!', 'success')
            else:
                flash('Product does not belong to you.', 'danger')
        except mysql.connector.Error as e:
            connection.rollback()
            flash(f'Error updating product price: {e}', 'danger')
        finally:
            cursor.close()
            connection.close()

    return render_template('change_product_cost.html')

# Route to discontinue selling a product
@app.route('/discontinue_product', methods=['GET', 'POST'])
def discontinue_product():
    seller_id = session.get('seller_id')
    if not seller_id:
        return redirect(url_for('seller_login'))

    if request.method == 'POST':
        product_id = int(request.form['product_id'])

        connection = mysql.connector.connect(**db_config)
        try:
            cursor = connection.cursor()

            # Check if the product belongs to the seller
            cursor.execute("SELECT seller_id FROM Product WHERE product_id = %s", (product_id,))
            result = cursor.fetchone()

            if result and result[0] == seller_id:
                # Delete the product from the database
                cursor.execute("DELETE FROM Product WHERE product_id = %s", (product_id,))
                connection.commit()
                flash('Product discontinued successfully.', 'success')
            else:
                flash('Product does not belong to the seller.', 'danger')
        except mysql.connector.Error as e:
            connection.rollback()
            flash(f'Error discontinuing product: {e}', 'danger')
        finally:
            cursor.close()
            connection.close()

    return render_template('discontinue_product.html')


# Function to add a delivery boy
@app.route('/add_delivery_boy', methods=['GET', 'POST'])
def add_delivery_boy():
    if request.method == 'POST':
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        mobile_number = request.form['mobile_number']
        email_id = request.form['email_id']
        rating = float(request.form['rating'])
        salary = float(request.form['salary'])
        ofc_id = int(request.form['ofc_id'])
        admin_id = session.get('admin_id')

        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        try:
            # Insert delivery boy data into Delivery_Boy table
            cursor.execute("""
                INSERT INTO Delivery_Boy (first_name, last_name, mobile_number, email_id, rating, salary, ofc_id, admin_id, orders_delivered)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (first_name, last_name, mobile_number, email_id, rating, salary, ofc_id, admin_id, 0))

            conn.commit()
            flash('Delivery boy added successfully!', 'success')
        except mysql.connector.Error as e:
            conn.rollback()
            flash(f'Error adding delivery boy: {e}', 'danger')
        finally:
            cursor.close()
            conn.close()

    # Fetching office locations from the database
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT ofc_id, location FROM Order_Fulfillment_Centre")
        offices = cursor.fetchall()
    except mysql.connector.Error as e:
        flash(f'Error fetching office locations: {e}', 'danger')
        offices = []

    finally:
        cursor.close()
        conn.close()

    return render_template('add_delivery_boy.html', offices=offices)


# Function to add a worker
@app.route('/add_worker', methods=['GET', 'POST'])
def add_worker():
    if request.method == 'POST':
        salary = float(request.form['salary'])
        email = request.form['email']
        mobile = request.form['mobile']
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        admin_id = session.get('admin_id')
        ofc_assign = request.form['ofc_assign']

        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        try:
            # Insert worker data into Worker table
            cursor.execute("""
                INSERT INTO Worker (salary, email, mobile, first_name, last_name, admin_id, ofc_id)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (salary, email, mobile, first_name, last_name, admin_id, ofc_assign))

            conn.commit()
            flash('Worker added successfully!', 'success')
        except mysql.connector.Error as e:
            conn.rollback()
            flash(f'Error adding worker: {e}', 'danger')
        finally:
            cursor.close()
            conn.close()

    return render_template('add_worker.html')

# Function to add a special offer
@app.route('/add_special_offer', methods=['GET', 'POST'])
def add_special_offer():
    if request.method == 'POST':
        offer_code = request.form['offer_code']
        maximum_discount = float(request.form['maximum_discount'])
        percentage_discount = float(request.form['percentage_discount'])
        minimum_order_value = float(request.form['minimum_order_value'])
        admin_id = session.get('admin_id')

        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        try:
            # Insert special offer data into Special_Offers table
            cursor.execute("""
                INSERT INTO Special_Offers (offer_code, maximum_discount, percentage_discount, minimum_order_value, admin_id)
                VALUES (%s, %s, %s, %s, %s)
            """, (offer_code, maximum_discount, percentage_discount, minimum_order_value, admin_id))

            conn.commit()
            flash('Special offer added successfully!', 'success')
        except mysql.connector.Error as e:
            conn.rollback()
            flash(f'Error adding special offer: {e}', 'danger')
        finally:
            cursor.close()
            conn.close()

    return render_template('add_special_offer.html')

@app.route('/remove_special_offer', methods=['GET', 'POST'])
def remove_special_offer():
    if request.method == 'POST':
        offer_id = int(request.form['offer_id'])

        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        try:
            # Delete special offer from Special_Offers table
            cursor.execute("DELETE FROM Special_Offers WHERE offer_id = %s", (offer_id,))

            conn.commit()
            flash('Special offer removed successfully!', 'success')
        except mysql.connector.Error as e:
            conn.rollback()
            flash(f'Error removing special offer: {e}', 'danger')
        finally:
            cursor.close()
            conn.close()

    # Fetching all offer codes from the database
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT offer_id, offer_code FROM Special_Offers")
        offers = cursor.fetchall()
    except mysql.connector.Error as e:
        flash(f'Error fetching special offers: {e}', 'danger')
        offers = []
    finally:
        cursor.close()
        conn.close()

    return render_template('remove_special_offer.html', offers=offers)


# Function to add a seller
@app.route('/add_seller', methods=['GET', 'POST'])
def add_seller():
    if request.method == 'POST':
        password = request.form['password']
        email = request.form['email']
        phone_number = request.form['phone_number']
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        admin_id = session.get('admin_id')  # Retrieve admin ID from session

        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        
        try:
            # Insert seller data into Seller table
            cursor.execute("""
                INSERT INTO Seller (password, email, phone_number, first_name, last_name, admin_id)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (password, email, phone_number, first_name, last_name, admin_id))
            
            conn.commit()
            flash('Seller added successfully!', 'success')
        except mysql.connector.Error as e:
            conn.rollback()
            flash(f'Error adding seller: {e}', 'danger')
        finally:
            cursor.close()
            conn.close()

    return render_template('add_seller.html')


@app.route('/remove_seller', methods=['GET', 'POST'])
def remove_seller():
    if request.method == 'POST':
        seller_id = request.form['seller_id']
        admin_id = session.get('admin_id')  # Retrieve admin ID from session

        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        try:
            # Delete seller from Seller table
            cursor.execute("""
                DELETE FROM Seller
                WHERE seller_id = %s AND admin_id = %s
            """, (seller_id, admin_id))
            
            if cursor.rowcount > 0:
                conn.commit()
                flash('Seller removed successfully!', 'success')
            else:
                flash('Seller not found or unauthorized to delete.', 'danger')
        except mysql.connector.Error as e:
            conn.rollback()
            flash(f'Error removing seller: {e}', 'danger')
        finally:
            cursor.close()
            conn.close()

    # Fetching all sellers from the database
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT seller_id, first_name FROM Seller")
        sellers = cursor.fetchall()
    except mysql.connector.Error as e:
        flash(f'Error fetching sellers: {e}', 'danger')
        sellers = []
    finally:
        cursor.close()
        conn.close()

    return render_template('remove_seller.html', sellers=sellers)


@app.route('/view_all_orders')
def view_all_orders():
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("""
        SELECT *
        FROM Order_
    """)
    
    orders = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return render_template('view_all_orders.html', orders=orders)

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))

@app.route('/category/<int:category_id>')
def view_products_by_category(category_id):
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()

    cursor.execute("""
        SELECT product_id, name, brand, price
        FROM Product
        WHERE category_id = %s AND availaiblity_status = 1
    """, (category_id,))
    products = cursor.fetchall()

    connection.close()

    return render_template('view_products_by_category.html', products=products)

@app.route('/view_cart')
def view_cart():
    try:
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor()
        user_id = session.get('user_id')

        if user_id == -1:
            flash('You need to log in first', 'danger')
            return redirect(url_for('user_login'))

        cursor.execute("""
            SELECT Cart.cart_id, Cart.final_amount, Cart.total_value FROM Cart
            JOIN Customer ON Cart.customer_id = Customer.customer_id
            WHERE Customer.customer_id = %s
        """, (user_id,))
        cart = cursor.fetchone()
        cart_id = cart[0]
        final_amount = cart[1]
        total_value = cart[2]
        # Retrieve products in the user's cart
        cursor.execute("""
            SELECT P.product_id, P.name, P.brand, P.price
            FROM Product P
            JOIN Contains_Products CP ON P.product_id = CP.product_id
            WHERE CP.cart_id = %s
        """, (cart_id,))
        products = cursor.fetchall()

        connection.close()

        return render_template('view_cart.html', products=products, total_amount=total_value, final_amount=final_amount)

    except mysql.connector.Error as err:
        connection.rollback()
        flash(f'Error: {err}', 'danger')
        return redirect(url_for('index'))

    finally:
        cursor.close()
        connection.close()





@app.route('/add_to_cart', methods=['GET', 'POST'])
def add_to_cart():
    if request.method == 'POST':
        product_id = request.form['product_id']
        user_id = session.get('user_id')
        if(user_id == -1):
            flash('You need to log in first', 'danger')
            return redirect(url_for('user_login'))
        
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor()

        try:
            # Check if the product is available
            cursor.execute("""
                SELECT availaiblity_status FROM Product WHERE product_id = %s
            """, (product_id,))
            product = cursor.fetchone()

            if not product or product[0] != 1:
                flash('Product is not available', 'danger')
                return redirect(url_for('add_to_cart'))

            # Retrieve cart information
            cursor.execute("""
                SELECT Cart.cart_id FROM Cart
                JOIN Customer ON Cart.customer_id = Customer.customer_id
                WHERE Customer.customer_id = %s
            """, (user_id,))
            cart = cursor.fetchone()

            if not cart:
                flash('Cart not found', 'danger')
                return redirect(url_for('user_menu'))  # Adjust category_id as needed

            cart_id = cart[0]
                # Insert the product into the Contains table
            cursor.execute("""
                INSERT INTO Contains_Products (cart_id, product_id)
                VALUES (%s, %s)
                """, (cart_id, product_id))

            # Update the cart's final_amount and total_value
            cursor.execute("""
                SELECT price FROM Product WHERE product_id = %s
            """, (product_id,))
            price = cursor.fetchone()[0]

            cursor.execute("""
                UPDATE Cart SET final_amount = final_amount + %s, total_value = total_value + %s, product_count = product_count + 1
                WHERE cart_id = %s
            """, (price, price, cart_id))

            connection.commit()
            flash('Product added to cart successfully', 'success')
        except mysql.connector.Error as err:
            connection.rollback()
            flash(f'Error: {err}', 'danger')
        finally:
            cursor.close()
            connection.close()

        return redirect(url_for('add_to_cart'))

    return render_template('add_to_cart.html')

@app.route('/remove_from_cart', methods=['GET', 'POST'])
def remove_from_cart():
    if request.method == 'POST':
        product_id = request.form['product_id']
        user_id = session.get('user_id')
        if user_id == -1:
            flash('You need to log in first', 'danger')
            return redirect(url_for('user_login'))
        
        connection = mysql.connector.connect(**db_config)
        cursor = connection.cursor()

        try:
            # Retrieve cart information
            cursor.execute("""
                SELECT Cart.cart_id FROM Cart
                JOIN Customer ON Cart.customer_id = Customer.customer_id
                WHERE Customer.customer_id = %s
            """, (user_id,))
            cart = cursor.fetchone()

            if not cart:
                flash('Cart not found', 'danger')
                return redirect(url_for('user_menu'))  # Adjust category_id as needed

            cart_id = cart[0]

            # Remove the product from the Contains table
            cursor.execute("""
                DELETE FROM Contains_Products
                WHERE cart_id = %s AND product_id = %s
            """, (cart_id, product_id))

            # Update the cart's final_amount and total_value
            cursor.execute("""
                SELECT price FROM Product WHERE product_id = %s
            """, (product_id,))
            price = cursor.fetchone()[0]

            cursor.execute("""
                UPDATE Cart SET final_amount = final_amount - %s, total_value = total_value - %s, product_count = product_count - 1
                WHERE cart_id = %s
            """, (price, price, cart_id))

            connection.commit()
            flash('Product removed from cart successfully', 'success')
        except mysql.connector.Error as err:
            connection.rollback()
            flash(f'Error: {err}', 'danger')
        finally:
            cursor.close()
            connection.close()

        return redirect(url_for('view_cart'))

    return render_template('remove_from_cart.html')

@app.route('/place_order', methods=['GET', 'POST'])
def place_order():
    if request.method == 'POST':
        try:
            connection = mysql.connector.connect(**db_config)
            cursor = connection.cursor()
            user_id = session.get('user_id')

            if user_id == -1:
                flash('You need to log in first', 'danger')
                return redirect(url_for('user_login'))
            shipping_address = 1
            payment_mode = 1

            cursor.execute("""
                SELECT Cart.cart_id, Cart.final_amount, Cart.total_value, Cart.product_count FROM Cart
                JOIN Customer ON Cart.customer_id = Customer.customer_id
                WHERE Customer.customer_id = %s
            """, (user_id,))
            cart = cursor.fetchone()
            cart_id, final_amount, total_value, product_count = cart

            # Get a random ofc_id
            cursor.execute("SELECT ofc_id FROM Order_Fulfillment_Centre ORDER BY RAND() LIMIT 1")
            ofc_id = cursor.fetchone()[0]

            # Get a delivery boy from that ofc
            cursor.execute("""
                SELECT delivery_boy_id FROM Delivery_Boy WHERE ofc_id = %s ORDER BY RAND() LIMIT 1
            """, (ofc_id,))
            delivery_boy_id = cursor.fetchone()[0]

            # Insert a new order
            cursor.execute("""
                INSERT INTO Order_ (order_time, quantity, shipping_address, payment_mode, order_date, amount, cart_id, ofc_id, delivery_boy_id)
                VALUES (TIME(NOW()), %s, %s, %s, CURDATE(), %s, %s, %s, %s)
            """, (product_count, shipping_address, payment_mode, final_amount, cart_id, ofc_id, delivery_boy_id))

            order_id = cursor.lastrowid

            # Delete the ordered products from the Product table
            cursor.execute("""
                DELETE FROM Product 
                WHERE product_id IN (SELECT product_id FROM Contains_Products WHERE cart_id = %s)
            """, (cart_id,))

            # Clear the cart
            cursor.execute("""
                DELETE FROM Contains_Products WHERE cart_id = %s
            """, (cart_id,))

            cursor.execute("""
                UPDATE Cart SET final_amount = 0, total_value = 0, product_count = 0 WHERE cart_id = %s
            """, (cart_id,))

            connection.commit()

            return render_template('place_order.html', order_id=order_id, total_amount=total_value, final_amount=final_amount)

        except mysql.connector.Error as err:
            connection.rollback()
            flash(f'Error: {err}', 'danger')
            return redirect(url_for('view_cart'))

        finally:
            cursor.close()
            connection.close()

    return render_template('place_order.html')




if __name__ == '__main__':
    init_db()
    app.run(debug=True)


