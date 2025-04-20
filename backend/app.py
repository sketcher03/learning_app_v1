from flask import Flask, jsonify, request
#from flask_pymongo import PyMongo
import pandas as pd
import random
from error_detection import generate_error_report

app = Flask(__name__)

# Function to load datasets
def load_datasets():
    df1 = pd.read_csv('backend\data\Age 5-6 years.csv')
    df2 = pd.read_csv('backend\data\Age 7-8 years.csv')
    df3 = pd.read_csv('backend\data\Age 9-10 years.csv')
    df4 = pd.read_csv('backend\data\Age 11-12 years.csv')

    return df1, df2, df3, df4

# Load the datasets into variables
df1, df2, df3, df4 = load_datasets()

def clean_input(value):
    # Trim spaces, convert to lowercase, and remove the word "years"
    cleaned_value = value.replace(' years', '')
    cleaned_value = cleaned_value.strip().lower()
    return cleaned_value

@app.route('/api/random-spelling-word', methods=['GET'])
def get_random_spelling_word():
    
    # Get query parameters
    age_group = request.args.get('age_group', type=str)
    difficulty = request.args.get('difficulty', type=str)

    # Clean the input values (remove extra spaces, convert to lowercase)
    age_group = clean_input(age_group)
    difficulty = clean_input(difficulty)

    print("Age Group: ", age_group)
    print("Difficulty: ", difficulty)

    # Dictionary to map age group to dataframe
    age_group_map = {
        '5-6': df1,
        '7-8': df2,
        '9-10': df3,
        '11-12': df4
    }

    # Check if the provided age group and difficulty are valid
    if age_group not in age_group_map:
        return jsonify({"error": "Invalid age group"}), 400

    # Filter the corresponding dataframe based on difficulty
    df = age_group_map[age_group]
    filtered_df = df[df['difficulty'] == difficulty]

    if filtered_df.empty:
        return jsonify({"error": "No words found for the given difficulty"}), 400

    # Debug: Print the filtered words
    print(f"Filtered words: {filtered_df}")

    # Pick 20 unique random words from the filtered dataframe (no repetition)
    words = filtered_df.sample(n=10, replace=False)['lemma'].tolist()

    print(f"Selected words: {words}")

    # Return the list of random words
    return jsonify({"words": words, "Age Group": age_group + " years", "Difficulty Level": difficulty})

@app.route('/api/submit_answers', methods=['POST'])
def submit_answers():
    # Get the data from the frontend
    data = request.get_json()
    user_answers = data['user_answers']
    correct_words = data['correct_words']
    score = data['score']
    ageGroup = clean_input(data['age_group'])
    difficulty = clean_input(data['difficulty'])

    # Assuming you're saving this data into a database or table:
    # Create a dataframe for correct words and user answers
    answers_df = pd.DataFrame({
        'correct_word': correct_words,
        'user_answer': user_answers
    })

    errors = generate_error_report(answers_df, ageGroup, difficulty)

    # You can print the answers dataframe to debug or store it in a database
    print(answers_df)
    print(errors)

    # Return the errors (if any) along with their descriptions
    return jsonify({'errors': errors, 'score': score})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

 