#Flutter Route


import os
import logging
from contextlib import contextmanager
from flask import Flask, request, jsonify, session
import base64
from datetime import datetime
from PIL import Image
import io
from dotenv import load_dotenv

# --- Local Imports ---
from chat import *
from db import create_tables, get_connection
from werkzeug.security import generate_password_hash, check_password_hash

load_dotenv()
# --- App Initialization & Configuration ---
app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

# Secret Key for session handling
secret_key = os.getenv('FLASK_SECRET_KEY')
if secret_key:
    app.config['SECRET_KEY'] = secret_key
else:
    logging.warning("FLASK_SECRET_KEY environment variable not set. Using a temporary key for development.")
    app.config['SECRET_KEY'] = os.urandom(24)

# Run table creation once at app startup
create_tables()

# ====================================================================
# Database helpers
# ====================================================================
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
        logging.error(f"Database Error: {e}")
        if conn:
            conn.rollback()
        raise
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

def db_get_chat_titles(user_id: int) -> list:
    with db_cursor() as cursor:
        cursor.execute("SELECT chat_id, title FROM chats WHERE user_id=%s ORDER BY created_at DESC", (user_id,))
        return cursor.fetchall()

def db_get_chat_messages(chat_id: int) -> list:
    with db_cursor() as cursor:
        cursor.execute("SELECT sender, message, image_path, timestamp FROM messages WHERE chat_id=%s ORDER BY timestamp ASC", (chat_id,))
        return cursor.fetchall()

def db_save_message(chat_id, sender, message, image_path=None):
    with db_cursor() as cursor:
        cursor.execute("INSERT INTO messages (chat_id, sender, message, image_path) VALUES (%s, %s, %s, %s)", (chat_id, sender, message, image_path))

def db_create_new_chat(user_id: int, first_message: str) -> dict:
    title = (first_message[:40] + '...') if len(first_message) > 40 else first_message
    with db_cursor() as cursor:
        cursor.execute("INSERT INTO chats (user_id, title) VALUES (%s, %s)", (user_id, title))
        new_chat_id = cursor.lastrowid
        return {'chat_id': new_chat_id, 'title': title}

def db_rename_chat(user_id: int, chat_id: int, new_title: str):
    with db_cursor() as cursor:
        cursor.execute("UPDATE chats SET title = %s WHERE chat_id = %s AND user_id = %s", (new_title, chat_id, user_id))

# ====================================================================
# Authentication Endpoints
# ====================================================================
@app.route("/api/signup", methods=["POST"])
def api_signup():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"error": "Username and password required"}), 400

    password_hash = generate_password_hash(password)

    try:
        with db_cursor() as cursor:
            cursor.execute("INSERT INTO users (username, password_hash) VALUES (%s, %s)", (username, password_hash))
            user_id = cursor.lastrowid
        return jsonify({"success": True, "user_id": user_id})
    except Exception as e:
        logging.error(f"Signup error: {e}")
        return jsonify({"error": "User already exists or database error"}), 400

@app.route("/api/login", methods=["POST"])
def api_login():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"error": "Username and password required"}), 400

    try:
        with db_cursor() as cursor:
            cursor.execute("SELECT user_id, password_hash FROM users WHERE username=%s", (username,))
            user = cursor.fetchone()
        if user and check_password_hash(user['password_hash'], password):
            session['user_id'] = user['user_id']
            return jsonify({"success": True, "user_id": user['user_id']})
        else:
            return jsonify({"error": "Invalid credentials"}), 401
    except Exception as e:
        logging.error(f"Login error: {e}")
        return jsonify({"error": "Database error"}), 500

@app.route("/api/logout", methods=["POST"])
def api_logout():
    session.pop('user_id', None)
    session.pop('active_chat_id', None)
    return jsonify({"success": True})

# ====================================================================
# Chat Endpoints
# ====================================================================
UPLOAD_FOLDER = 'static/uploads'

@app.route("/api/chats/<int:user_id>", methods=["GET"])
def api_get_chats(user_id):
    """Return all chats for a given user (Flutter passes user_id)."""
    # user_id = request.args.get("user_id", type=int)
    if not user_id:
        return jsonify({"error": "Missing user_id"}), 400

    try:
        chat_titles = db_get_chat_titles(user_id)
        # return jsonify([{"chat_id": c[0], "title": c[1]} for c in chat_titles])
        return jsonify(chat_titles)
    except Exception as e:
        logging.error(f"Error fetching chat titles: {e}")
        return jsonify({"error": "Database error"}), 500
    


@app.route("/api/load-chat/<int:chat_id>", methods=["GET"])
def api_load_chat(chat_id):
    """Load all messages for a chat (Flutter request)."""
    try:
        rows = db_get_chat_messages(chat_id)  # returns list of dicts
        messages = [
            {
                "sender": row["sender"],
                "message": row["message"],
                "image_path": row["image_path"],
                "timestamp": row["timestamp"].isoformat() if row["timestamp"] else None
            }
            for row in rows
        ]
        return jsonify({"messages": messages})
    except Exception as e:
        logging.error(f"Error loading chat {chat_id}: {e}")
        return jsonify({"error": "Database error"}), 500



# @chat_bp.route('/api/load-chat/<int:chat_id>', methods=['GET'])
# def api_load_chat(chat_id):
#     """Load all messages for a chat."""
#     # user_id = session.get('user_id')
#     try:
#         rows = db_get_chat_messages(chat_id)
#         messages = [
#             {
#                 "sender": row[0],
#                 "message": row[1],
#                 "image_path": row[2],
#                 "timestamp": row[3].isoformat() if row[3] else None
#             }
#             for row in rows
#         ]
#         return jsonify({"messages": messages})
#     except Exception as e:
#         logging.error(f"Error loading chat {chat_id}: {e}")
#         return jsonify({"error": "Database error"}), 500


@app.route("/api/chats/<int:chat_id>", methods=["GET"])
def api_get_chat_history(chat_id):
    """Return full chat history for a given chat_id (Flutter passes user_id)."""
    user_id = request.args.get("user_id", type=int)
    if not user_id:
        return jsonify({"error": "Missing user_id"}), 400

    try:
        # Check that the chat belongs to this user
        chat_titles = db_get_chat_titles(user_id)
        if not any(c[0] == chat_id for c in chat_titles):
            return jsonify({"error": "Chat not found"}), 404

        messages = db_get_chat_messages(chat_id)
        return jsonify([
            {
                "sender": m[0],
                "message": m[1],
                "image_path": m[2],
                "created_at": m[3].isoformat() if m[3] else None
            } for m in messages
        ])
    except Exception as e:
        logging.error(f"Error fetching messages for chat {chat_id}: {e}")
        return jsonify({"error": "Database error"}), 500

@app.route("/api/send-message", methods=["POST"])
def api_send_message():
    user_input = request.json.get('message')
    image_base_64 = request.json.get("image")

    if not user_input and not image_base_64:
        return jsonify({'error': 'Please enter a message.'}), 400

    # user_id = session.get('user_id')
    user_id = request.json.get('user_id')
    if not user_id:
        return jsonify({'error': 'Unauthorized'}), 401

    active_chat_id = request.json.get('chat_id')
    new_chat_info = {}
    image_path = None
    image_data = None

    try:
        if not active_chat_id:
            new_chat_info = db_create_new_chat(user_id, user_input or "[Image]")
            active_chat_id = new_chat_info['chat_id']
            session['active_chat_id'] = active_chat_id

        if image_base_64:
            if image_base_64.startswith("data:image/"):
                image_base_64 = image_base_64.split(",")[1]
            image_bytes = base64.b64decode(image_base_64)
            image_data = Image.open(io.BytesIO(image_bytes))
            filename = f"image_{datetime.utcnow().strftime('%Y%m%d%H%M%S%f')}.png"
            image_path = os.path.join(UPLOAD_FOLDER, filename)
            os.makedirs(UPLOAD_FOLDER, exist_ok=True)
            image_data.save(image_path)

        # Generate bot reply
        if image_base_64 and not user_input:
            reply = query_image(image_data)
        elif image_base_64 and user_input:
            reply = query_text_with_image(user_input, image_data)
        else:
            reply = query_chatbot(user_input)

        db_save_message(active_chat_id, "user", user_input or "[Image]", image_path)
        db_save_message(active_chat_id, "assistant", reply)

        response_data = {'chat_id': active_chat_id, 'response': reply}
        if new_chat_info:
            response_data['new_chat'] = new_chat_info
        return jsonify(response_data)
    except Exception as e:
        logging.error(f"Error in /api/send-message: {e}")
        return jsonify({'error': 'Internal Server Error'}), 500

@app.route("/api/rename-chat", methods=["POST"])
def api_rename_chat():
    data = request.get_json()
    chat_id = data.get('chat_id')
    new_title = data.get('new_title')
    user_id = session.get('user_id')

    if not all([chat_id, new_title, user_id]):
        return jsonify({'error': 'Missing data'}), 400

    try:
        db_rename_chat(user_id, chat_id, new_title)
        return jsonify({'success': True, 'message': 'Chat renamed successfully.'})
    except Exception as e:
        logging.error(f"Error renaming chat: {e}")
        return jsonify({'error': 'Database error'}), 500

# ====================================================================
# Run App
# ====================================================================
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
    # print(db_get_chat_messages(27))

