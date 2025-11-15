#!/bin/bash

# Log
set -xeo pipefail

USERDATA_LOG_FILE=/var/log/user_data.log
exec > >(tee $USERDATA_LOG_FILE | logger -t user-data -s 2>/dev/console) 2>&1
echo "FASTAPI_USERDATA_LOG_FILE=$USERDATA_LOG_FILE" >> /etc/environment

# Check internet
while true; do
  if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
    break
  else 
    sleep 3
  fi
done

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Python, pip and MySQL client
sudo apt-get install -y python3 python3-pip python3-venv mysql-client

# Create application directory
sudo mkdir -p /opt/fastapi-app
cd /opt/fastapi-app

# Wait for RDS to be ready
echo "Waiting for RDS to be ready..."
sleep 30

# Initialize database
mysql -h ${db_address} -P ${db_port} -u ${db_username} -p${db_password} ${db_name} <<DBINIT
CREATE TABLE IF NOT EXISTS table1 (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT IGNORE INTO table1 (id, name) VALUES
(1, 'A'),
(2, 'B'),
(3, 'C');
DBINIT

# Create FastAPI application
sudo tee /opt/fastapi-app/main.py > /dev/null <<'FASTAPIEOF'
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import mysql.connector
from mysql.connector import Error

app = FastAPI()

DB_CONFIG = {
    'host': '${db_address}',
    'port': ${db_port},
    'database': '${db_name}',
    'user': '${db_username}',
    'password': '${db_password}'
}

def get_db_connection():
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

@app.get("/", response_class=HTMLResponse)
async def read_root():
    connection = get_db_connection()
    if connection:
        try:
            cursor = connection.cursor(dictionary=True)
            cursor.execute("SELECT id, name FROM table1 ORDER BY id")
            rows = cursor.fetchall()
            cursor.close()
            connection.close()
            
            # Build HTML table
            table_rows = ""
            for row in rows:
                table_rows += f"<tr><td>{row['id']}</td><td>{row['name']}</td></tr>"
            
            html = f"""
            <!DOCTYPE html>
            <html>
            <head>
                <title>Database Data</title>
                <style>
                    body {{
                        font-family: Arial, sans-serif;
                        display: flex;
                        flex-direction: column;
                        justify-content: center;
                        align-items: center;
                        height: 100vh;
                        margin: 0;
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    }}
                    h1 {{
                        color: white;
                        font-size: 3em;
                        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
                        margin-bottom: 30px;
                    }}
                    table {{
                        border-collapse: collapse;
                        background: white;
                        border-radius: 10px;
                        overflow: hidden;
                        box-shadow: 0 4px 6px rgba(0,0,0,0.3);
                    }}
                    th, td {{
                        padding: 15px 30px;
                        text-align: left;
                        border-bottom: 1px solid #ddd;
                    }}
                    th {{
                        background-color: #667eea;
                        color: white;
                        font-weight: bold;
                    }}
                    tr:hover {{
                        background-color: #f5f5f5;
                    }}
                </style>
            </head>
            <body>
                <h1>Database Data from table1</h1>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                        </tr>
                    </thead>
                    <tbody>
                        {table_rows}
                    </tbody>
                </table>
            </body>
            </html>
            """
            return html
        except Error as e:
            return f"<html><body><h1>Error: {e}</h1></body></html>"
    else:
        return "<html><body><h1>Error: Could not connect to database</h1></body></html>"
FASTAPIEOF

# Create requirements.txt
sudo tee /opt/fastapi-app/requirements.txt > /dev/null <<'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
mysql-connector-python==8.2.0
EOF

# Create virtual environment
sudo python3 -m venv /opt/fastapi-app/venv

# Install dependencies in virtual environment (ignore system packages)
sudo /opt/fastapi-app/venv/bin/pip install --ignore-installed -r /opt/fastapi-app/requirements.txt

# Create systemd service
sudo tee /etc/systemd/system/fastapi.service > /dev/null <<'EOF'
[Unit]
Description=FastAPI Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/fastapi-app
Environment="PATH=/opt/fastapi-app/venv/bin:/usr/bin:/usr/local/bin"
ExecStart=/opt/fastapi-app/venv/bin/python -m uvicorn main:app --host 0.0.0.0 --port 80
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable fastapi
sudo systemctl start fastapi

echo "=== FASTAPI APPLICATION INSTALLED AND STARTED ==="

