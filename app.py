from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import pandas as pd
import os
from openpyxl import load_workbook
import win32com.client as win32
import re


app = Flask(__name__)
CORS(app)

url=None

file_path = 'C:/Users/Navya/Downloads/test/example.xlsx'  
df = pd.read_excel(file_path)

@app.route("/mark_as_applied", methods=["GET","POST"])
def mark_as_applied():
    print("first request")
    if request.method == 'POST':
        print("second request")
        # Check if request content type is JSON
        if request.is_json:
            data = request.json
            print(data)
            url = data.get('uRL')

            print("Received URL:", url)
            return jsonify({"message": "Data received successfully"})
        else:
            return jsonify({"error": "Unsupported Media Type"}), 415
    elif request.method == 'GET':
        # Handle GET request if needed
        return "GET request received"
    else:
        return jsonify({"error": "Method Not Allowed"}), 405
    
@app.route("/",methods=["GET"])
def index():
    return "Hello, World!"

if __name__ == '__main__':
    app.run(debug=True)