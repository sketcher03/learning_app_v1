from flask import Flask, jsonify, request
#from flask_pymongo import PyMongo
import pandas as pd
import random

app = Flask(__name__)


# Load spelling words from CSV file
spelling_words = pd.read_csv('backend/data/vocabulary_age_levels.csv').to_dict('records')
print("CSV file loaded successfully!")

# API to get a random spelling word
# @app.route('/api/random-spelling-word', methods=['GET'])
# def get_random_spelling_word():
#     random_word = random.choice(spelling_words)
#     return jsonify(random_word)

@app.route('/api/random-spelling-word', methods=['GET'])
def get_random_spelling_word():
    if not spelling_words:
        return jsonify({"error": "No spelling words available"}), 404
    random_word = random.choice(spelling_words)
    print('api found')
    print(random_word)
    return jsonify(random_word)

# if __name__ == '__main__':
#     app.run(debug=True)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

