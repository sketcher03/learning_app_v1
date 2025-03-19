from flask import Flask, jsonify, request
#from flask_pymongo import PyMongo
import pandas as pd
import random

app = Flask(__name__)


# Load spelling words from CSV file
spelling_words = pd.read_csv('backend/data/vocabulary_age_levels.csv').to_dict('records')
print("CSV file loaded successfully!", spelling_words)


# @app.route('/api/random-spelling-word', methods=['GET'])
# def get_random_spelling_word():
#     if not spelling_words:
#         return jsonify({"error": "No spelling words available"}), 404
#     random_word = random.choice(spelling_words)
#     print('api found')
#     print(random_word)
#     return jsonify(random_word)


@app.route('/api/random-spelling-word', methods=['GET'])
def get_random_spelling_word():
    # Get query parameters
    age_group = request.args.get('age_group')
    difficulty = request.args.get('difficulty')
    print(f"age_group: {age_group}")

    # Validate query parameters
    if not age_group or not difficulty:
        return jsonify({"error": "Both age_group and difficulty parameters are required"}), 400
    
        # Debug: Print the received parameters
        print(f"Received request with age_group: {age_group}, difficulty: {difficulty}")

    # Filter words based on age_group and difficulty
    filtered_words = [
        word for word in spelling_words
        if word["Age Group"].lower() == age_group.lower() #and word["Difficulty Level"].lower() == difficulty.lower()
    ]

        # Debug: Print the filtered words
    print(f"Filtered words: {filtered_words}")

    # Check if any words match the criteria
    if not filtered_words:
        return jsonify({"error": "No words found for the specified criteria"}), 404

    # Select a random word from the filtered list
    random_word = random.choice(filtered_words)
    print('API found a matching word:', random_word)
    return jsonify(random_word)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

 