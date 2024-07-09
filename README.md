# ShopSmart - an ecommerce backend system

## Description
This project is an eCommerce backend system developed using Python, Flask, MySQL, HTML, and CSS. It provides functionalities such as user registration, product management, cart operations, special offers, and order fulfillment. The system is designed to be a robust backend solution for managing an online store.

## Features
- User registration and authentication
- Admin and Seller authentication
- Product management
- Cart operations
- Special offers management
- Order placement and fulfillment
- Admin functionalities for managing sellers,delivery personnel and workers working in order_fulfillment_centres

## Tech Stack Used
- Frontend - HTML,CSS
- Backend - Flask,Python,MySQL
- We have populated our database with real and good amount of data to test to the website properly. Data coherency has been taken utmost care of.
- Proper entities have been maintained in our ER Diagram and Relational Diagram

## Steps to deploy the website

1. Clone the repository:
    ```sh
    git clone https://github.com/aryan-22112/online_store.git
    ```

2. Create and activate a virtual environment:
    ```sh
    python3 -m venv env
    source env/bin/activate
    ```

3. Install the required packages:
    ```sh
    pip install -r requirements.txt
    ```

4. Set up the MySQL database:
    - Create a MySQL database.
    - Run the SQL scripts to create the required tables and populate initial data.

5. Configure the application:
    - Update the `db_config` in `app.py` with your MySQL database credentials.

## Running the Application
1. Run the Flask application:
    ```sh
    flask run
    ```

2. Open your web browser and navigate to `http://127.0.0.1:5000`.

## Assumptions In The Project
1. We assumed that all orders will go through the cart and every order will unique cart ID be associated with unique cart ID and only one single customer. Also every customer will have one cart at a time to place order.
2. There are multiple admins and every admin has the power to add products,category and sellers.
3. To view cart and add products to cart,you first need to login as a user.
4. Each product belongs to a particular category and is sold by a particular seller.


