from flask import Flask, jsonify, request, render_template
import Adafruit_BBIO.ADC as ADC
import json
import uuid
import time

app = Flask(__name__)

sensor_pin = 'P9_40'
ADC.setup()

# Function to load JSON data from file
def load_data():
    try:
        with open("data.json", "r") as file:
            return json.load(file)
    except FileNotFoundError:
        return {}

# Function to save JSON data to file
def save_data(data):
    with open("data.json", "w") as file:
        json.dump(data, file, indent=4)

def _get_reading():
    return str(ADC.read(sensor_pin) * 1.800)

# Route to render the homepage with JSON data in a table
@app.route('/')
def index():
    data = load_data()
    reading = _get_reading()
    return render_template('index.html', data=data, reading=reading)

# Route to retrieve JSON data
@app.route('/get_data', methods=['GET'])
def get_data():
    data = load_data()
    return jsonify(data)

# Route to update JSON data
@app.route('/update_data', methods=['POST'])
def update_data():
    data = request.json
    save_data(data)
    return jsonify({"message": "Data updated successfully"})

@app.route('/get_reading', methods=['GET'])
def get_reading():
    return _get_reading()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
