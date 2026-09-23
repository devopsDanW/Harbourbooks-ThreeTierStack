from flask import Flask, jsonify, request
import mysql.connector
import os
import boto3
import json
import logging
from datetime import datetime, timezone

class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }
        return json.dumps(log_entry)

handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())
logging.basicConfig(level=logging.INFO, handlers=[handler])
logger = logging.getLogger(__name__)

app = Flask(__name__)

def fetch_db_secret():
    secret_arn = os.getenv("DB_SECRET_ARN")
    region = os.getenv("AWS_REGION", "ap-southeast-2")
    try:
        client = boto3.client("secretsmanager", region_name=region)
        response = client.get_secret_value(SecretId=secret_arn)
        return json.loads(response["SecretString"])
    except Exception as e:
        logger.error(f"Failed to fetch DB secret from Secrets Manager: {e}")
        return {}

_secret = fetch_db_secret()

db_config = {
    "host": _secret.get("host", os.getenv("DB_HOST", "placeholder")),
    "user": _secret.get("username", "orders_user"),
    "password": _secret.get("password", ""),
    "database": os.getenv("DB_NAME", "orders_db"),
    "port": _secret.get("port", 3306),
}


def get_connection():
    return mysql.connector.connect(**db_config)


def init_db():
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS orders (
            id INT AUTO_INCREMENT PRIMARY KEY,
            customer_name VARCHAR(100) NOT NULL,
            product_name VARCHAR(100) NOT NULL,
            quantity INT NOT NULL,
            status VARCHAR(50) NOT NULL
        )
    """)
    connection.commit()
    cursor.close()
    connection.close()


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy"}), 200


@app.route("/orders", methods=["POST"])
def create_order():
    data = request.get_json()
    required_fields = ["customer_name", "product_name", "quantity", "status"]
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing field: {field}"}), 400
    try:
        connection = get_connection()
        cursor = connection.cursor()
        cursor.execute("""
            INSERT INTO orders (customer_name, product_name, quantity, status)
            VALUES (%s, %s, %s, %s)
        """, (data["customer_name"], data["product_name"], data["quantity"], data["status"]))
        connection.commit()
        order_id = cursor.lastrowid
        cursor.close()
        connection.close()
        return jsonify({"message": "Order created successfully", "order_id": order_id}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/orders", methods=["GET"])
def get_orders():
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM orders")
        orders = cursor.fetchall()
        cursor.close()
        connection.close()
        return jsonify(orders), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    try:
        init_db()
    except Exception as e:
        logger.error(f"Database not reachable at startup, continuing without it: {e}")
    app.run(host="0.0.0.0", port=5000)