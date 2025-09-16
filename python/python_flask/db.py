import pymysql
from contextlib import contextmanager
from dotenv import load_dotenv
import os

load_dotenv()
def get_connection():
    return pymysql.connect(
        host=os.getenv('MYSQL_HOST', 'localhost'),
        user=os.getenv('MYSQL_USER', 'root'),
        password=os.getenv('MYSQL_PASSWORD', ''),
        database=os.getenv('MYSQL_DATABASE', 'agritech'),
        port=int(os.getenv('MYSQL_PORT', '3310')),
        cursorclass=pymysql.cursors.DictCursor
    )

def create_tables():
    connection = get_connection()
    try:
        with connection.cursor() as cursor:
            # Create users table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    user_id INT AUTO_INCREMENT PRIMARY KEY,
                    username VARCHAR(255) UNIQUE NOT NULL,
                    password_hash TEXT NOT NULL
                );
            """)

            # Create chats table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS chats (
                    chat_id INT AUTO_INCREMENT PRIMARY KEY,
                    user_id INT,
                    title VARCHAR(255),
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users(user_id)
                        ON DELETE CASCADE ON UPDATE CASCADE
                );
            """)

            # Create messages table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS messages (
                    message_id INT AUTO_INCREMENT PRIMARY KEY,
                    chat_id INT,
                    sender ENUM('user', 'assistant'),
                    message TEXT NOT NULL,
                    image_path TEXT NULL,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (chat_id) REFERENCES chats(chat_id)
                        ON DELETE CASCADE ON UPDATE CASCADE
                );
            """)

        connection.commit()
        print("Tables created successfully (if not already exist).")
    except Exception as e:
        print("Error creating tables:", e)
    finally:
        connection.close()

# --- NEW: Context manager for easier cursor handling ---
@contextmanager
def db_cursor():
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        yield cursor
        conn.commit()
    except Exception as e:
        if conn:
            conn.rollback()
        raise
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
