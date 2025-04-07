from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_mysqldb import MySQL
import MySQLdb.cursors
import re
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.secret_key = 'SQL@@@@1234'  

# MySQL Configuration
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '1234'
app.config['MYSQL_DB'] = 'StockMarketDB'
app.config['MYSQL_PORT'] = 3306  

mysql = MySQL(app)

def get_db_connection():
    return mysql.connection.cursor(MySQLdb.cursors.DictCursor)

# ---------- Routes ----------

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        password = request.form['password']

        if len(password) < 8 or not re.search(r"[!@#$%^&*(),.?\":{}|<>]", password):
            flash("Password must be at least 8 characters and contain a special character!", "danger")
            return redirect(url_for('register'))

        hashed_password = generate_password_hash(password)

        cursor = get_db_connection()
        try:
            cursor.execute("INSERT INTO Users (username, email, password_hash) VALUES (%s, %s, %s)",
                        (username, email, hashed_password))
            mysql.connection.commit()
            flash("Account created successfully! You can now log in.", "success")
            return redirect(url_for('login'))
        except MySQLdb.IntegrityError:
            flash("Username or Email already exists!", "danger")
        finally:
            cursor.close()

    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        cursor = get_db_connection()
        cursor.execute("SELECT * FROM Users WHERE username = %s", (username,))
        user = cursor.fetchone()
        cursor.close()

        if user and check_password_hash(user['password_hash'], password):
            session['loggedin'] = True
            session['user_id'] = user['user_id']
            session['username'] = user['username']
            flash(f"Welcome {username}!", "success")
            return redirect(url_for('portfolio'))
        else:
            flash("Invalid Username or Password", "danger")

    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    flash("Logged out successfully!", "info")
    return redirect(url_for('login'))

@app.route('/portfolio')
def portfolio():
    if 'loggedin' not in session:
        flash("Please login first!", "warning")
        return redirect(url_for('login'))

    user_id = session['user_id']
    cursor = get_db_connection()

    try:
        # Get all transactions including transaction_id
        cursor.execute("""
            SELECT 
                pt.transaction_id,
                s.stock_name, 
                pt.transaction_type,
                pt.quantity, 
                pt.price_per_unit, 
                sp.current_price,
                (sp.current_price - pt.price_per_unit) * pt.quantity AS profit_loss,
                pt.transaction_date
            FROM Portfolio_Transactions pt
            JOIN Stocks s ON pt.stock_id = s.stock_id
            JOIN Stock_Prices sp ON s.stock_id = sp.stock_id
            JOIN Portfolios p ON pt.portfolio_id = p.portfolio_id
            WHERE p.user_id = %s
            ORDER BY pt.transaction_date DESC
        """, (user_id,))
        transactions = cursor.fetchall()

        # Calculate total profit/loss
        total_profit_loss = sum(t['profit_loss'] for t in transactions) if transactions else 0

        return render_template('portfolio.html', 
                        transactions=transactions, 
                        profit_loss=total_profit_loss)
        
    except MySQLdb.Error as e:
        flash(f"Database error: {e}", "danger")
        return render_template('portfolio.html', transactions=[], profit_loss=0)
    finally:
        cursor.close()

@app.route('/add_stock', methods=['POST'])
def add_stock():
    if 'loggedin' not in session:
        flash("Please login first!", "warning")
        return redirect(url_for('login'))

    try:
        stock_name = request.form['stock_name']
        quantity = float(request.form['quantity'])
        price_per_unit = float(request.form['price'])
        user_id = session['user_id']

        if quantity <= 0 or price_per_unit <= 0:
            flash("Quantity and price must be positive numbers!", "danger")
            return redirect(url_for('portfolio'))

        cursor = get_db_connection()

        # Get or create portfolio
        cursor.execute("SELECT portfolio_id FROM Portfolios WHERE user_id = %s", (user_id,))
        portfolio = cursor.fetchone()
        
        if not portfolio:
            cursor.execute("INSERT INTO Portfolios (user_id) VALUES (%s)", (user_id,))
            mysql.connection.commit()
            cursor.execute("SELECT portfolio_id FROM Portfolios WHERE user_id = %s", (user_id,))
            portfolio = cursor.fetchone()

        # Get stock
        cursor.execute("SELECT stock_id FROM Stocks WHERE stock_name = %s", (stock_name,))
        stock = cursor.fetchone()
        
        if not stock:
            flash("Stock not found!", "danger")
            return redirect(url_for('portfolio'))

        # Add transaction
        cursor.execute("""
            INSERT INTO Portfolio_Transactions 
            (portfolio_id, stock_id, transaction_type, transaction_date, quantity, price_per_unit, total_cost)
            VALUES (%s, %s, 'Buy', CURDATE(), %s, %s, %s)
        """, (portfolio['portfolio_id'], stock['stock_id'], quantity, price_per_unit, quantity * price_per_unit))

        mysql.connection.commit()
        flash("Stock added successfully!", "success")

    except ValueError:
        flash("Invalid quantity or price format!", "danger")
    except MySQLdb.Error as e:
        mysql.connection.rollback()
        flash(f"Database error: {str(e)}", "danger")
    finally:
        cursor.close()

    return redirect(url_for('portfolio'))

@app.route('/delete_stock', methods=['POST'])
def delete_stock():
    if 'loggedin' not in session:
        flash("Please login first!", "warning")
        return redirect(url_for('login'))

    transaction_id = request.form.get('transaction_id')
    if not transaction_id:
        flash("Transaction ID is missing!", "danger")
        return redirect(url_for('portfolio'))

    cursor = None
    try:
        cursor = get_db_connection()
        
        # Verify transaction belongs to user
        cursor.execute("""
            SELECT pt.transaction_id 
            FROM Portfolio_Transactions pt
            JOIN Portfolios p ON pt.portfolio_id = p.portfolio_id
            WHERE pt.transaction_id = %s AND p.user_id = %s
        """, (transaction_id, session['user_id']))
        
        if not cursor.fetchone():
            flash("Transaction not found or doesn't belong to you!", "danger")
            return redirect(url_for('portfolio'))

        # Delete transaction
        cursor.execute("DELETE FROM Portfolio_Transactions WHERE transaction_id = %s", (transaction_id,))
        mysql.connection.commit()
        flash("Transaction deleted successfully!", "success")
        
    except MySQLdb.Error as e:
        mysql.connection.rollback()
        flash(f"Database error: {str(e)}", "danger")
    finally:
        if cursor:
            cursor.close()

    return redirect(url_for('portfolio'))

@app.route('/update_stock', methods=['POST'])
def update_stock():
    if 'loggedin' not in session:
        flash("Please login first!", "warning")
        return redirect(url_for('login'))

    try:
        transaction_id = request.form['transaction_id']
        new_quantity = float(request.form['new_quantity'])
        new_price = float(request.form['new_price'])
        user_id = session['user_id']

        if new_quantity <= 0 or new_price <= 0:
            flash("Quantity and price must be positive numbers!", "danger")
            return redirect(url_for('portfolio'))

        cursor = get_db_connection()

        # Verify transaction belongs to user
        cursor.execute("""
            SELECT pt.transaction_id 
            FROM Portfolio_Transactions pt
            JOIN Portfolios p ON pt.portfolio_id = p.portfolio_id
            WHERE pt.transaction_id = %s AND p.user_id = %s
        """, (transaction_id, user_id))
        
        if not cursor.fetchone():
            flash("Transaction not found or doesn't belong to you!", "danger")
            return redirect(url_for('portfolio'))

        # Update transaction
        cursor.execute("""
            UPDATE Portfolio_Transactions 
            SET quantity = %s, 
                price_per_unit = %s,
                total_cost = %s * %s
            WHERE transaction_id = %s
        """, (new_quantity, new_price, new_quantity, new_price, transaction_id))
        
        mysql.connection.commit()
        flash("Transaction updated successfully!", "success")
        
    except ValueError:
        flash("Invalid quantity or price format!", "danger")
    except MySQLdb.Error as e:
        mysql.connection.rollback()
        flash(f"Database error: {str(e)}", "danger")
    finally:
        cursor.close()

    return redirect(url_for('portfolio'))

@app.route('/all-stocks')
def all_stocks():
    page = request.args.get('page', 1, type=int)
    per_page = 10  

    cursor = get_db_connection()
    cursor.execute("SELECT COUNT(*) AS count FROM Stocks")
    total_stocks = cursor.fetchone()["count"]
    total_pages = (total_stocks + per_page - 1) // per_page  

    start_idx = (page - 1) * per_page
    cursor.execute("""
        SELECT s.stock_name, sp.current_price, sp.market_cap, s.NSE_code, s.BSE_code, 
            s.ISIN, s.industry_name, s.sector_name 
        FROM Stocks s
        LEFT JOIN Stock_Prices sp ON s.stock_id = sp.stock_id
        LIMIT %s OFFSET %s
    """, (per_page, start_idx))
    
    stocks_data = cursor.fetchall()
    cursor.close()

    return render_template("all_stock.html", stocks=stocks_data, page=page, total_pages=total_pages)

if __name__ == '__main__':
    app.run(debug=True)