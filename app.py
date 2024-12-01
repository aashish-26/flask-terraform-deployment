from flask import Flask, jsonify
import random

app = Flask(__name__)

# List of motivational quotes
quotes = [
    "The best way to predict the future is to create it.",
    "Believe you can and you're halfway there.",
    "Dream big and dare to fail.",
    "Act as if what you do makes a difference. It does.",
    "Success is not final, failure is not fatal: It is the courage to continue that counts."
]

@app.route('/')
def welcome():
    return "Welcome to the Motivational Quote API!"

@app.route('/quote', methods=['GET'])
def get_quote():
    quote = random.choice(quotes)
    return jsonify({"quote": quote})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
