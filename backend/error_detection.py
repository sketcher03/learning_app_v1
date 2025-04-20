import pandas as pd
import nltk
from nltk.metrics import edit_distance
from nltk.corpus import cmudict
from metaphone import doublemetaphone
import string

# Load the suffixes from the CSV file
suffixes_df = pd.read_csv('backend\data\suffixes.csv')
suffixes = suffixes_df['suffixes'].tolist()  # Convert the suffix column to a list

# Load the prefixes from the CSV file
prefixes_df = pd.read_csv('backend\data\prefixes.csv')
prefixes = prefixes_df['prefixes'].tolist()  # Assuming the column name is 'prefix'

# Function to load datasets
def load_datasets():
    df1 = pd.read_csv('backend\data\Age 5-6 years.csv')
    df2 = pd.read_csv('backend\data\Age 7-8 years.csv')
    df3 = pd.read_csv('backend\data\Age 9-10 years.csv')
    df4 = pd.read_csv('backend\data\Age 11-12 years.csv')

    return df1, df2, df3, df4

# Load the datasets into variables
df1, df2, df3, df4 = load_datasets()

# Function to check if a word has any suffix from the list
def detect_all_suffixes(word, suffixes):
    matched_suffixes = []  # List to store all matched suffixes
    for suffix in suffixes:
        if word.endswith(suffix):
            matched_suffixes.append(suffix)
    
    if matched_suffixes:
        return matched_suffixes
    else:
        return "100"
    

# Function to check if a word has any prefix from the list
def detect_all_prefixes(word, prefixes):
    matched_prefixes = []  # List to store all matched prefixes
    for prefix in prefixes:
        if word.startswith(prefix):
            matched_prefixes.append(prefix)
    
    if matched_prefixes:
        return matched_prefixes
    else:
        return "100"


def check_transposition_error(correct_word, answer):
    # Initialize the list of transposition errors
    transposition_errors = []

    # Make sure both words are of the same length for comparison
    min_len = min(len(correct_word), len(answer))

    # Check for transpositions by comparing adjacent characters
    for i in range(min_len - 1):  # -1 to prevent index out of range
        # Check if current and next characters in misspelled word are swapped in correct word
        if (answer[i] == correct_word[i + 1] and
            answer[i + 1] == correct_word[i]):
            transposition_errors.append(i)  # Store indices of swapped characters

    return transposition_errors

def check_substitution_error(correct_word, answer):
    substitution_errors = []

    # Ensure both words are of the same length (pad with spaces if necessary)
    min_len = min(len(correct_word), len(answer))

    # Compare each character by its position
    for i in range(min_len):
        if correct_word[i] != answer[i]:
            substitution_errors.append(i)  # A substitution error occurs when characters are different at the same position

    return substitution_errors


def classify_cook_error(correct, answer):
    """
    Classifies spelling errors based on Cook’s (1999) classification.
    """

    if correct == answer:
        return "No Error"

    # Make sure both words are of the same length for comparison
    min_len = min(len(correct), len(answer))

    # If multiple changes occur
    if edit_distance(correct, answer) > 1:
        return "Multiple Errors"

    if len(correct) == len(answer):
        # Substitution Error: Same length but different letters
        differences = sum(1 for c, m in zip(correct, answer) if c != m)
        if differences == 1:
            return "Substitution Error"

        # Check for transpositions by comparing adjacent characters
        for i in range(min_len - 1):  # -1 to prevent index out of range
            # Check if current and next characters in answer word are swapped in correct word
            if (answer[i] == correct[i + 1] and
                answer[i + 1] == correct[i]):
                return "Transposition Error"

    # Omission Error: A letter is missing
    if len(correct) > len(answer):
        return "Omission Error"

    # Insertion Error: An extra letter is added
    if len(correct) < len(answer):
        return "Insertion Error"

    return "Unknown"


# Check for double letter mistakes (addition or omission)
def detect_double_letter_mistake(correct, answer):

    count1=0
    count2=0
    reset=0

    if correct == answer:
        return 0

    # Double Letter Omission
    for i in range(len(correct) - 1):
        if correct[i] == correct[i + 1]:  # If the correct word has a double letter
            count1+=1
            modified_misspelled = answer[:i] + correct[i] + answer[i:]  # Simulate missing double letter
            print(modified_misspelled)
            if modified_misspelled == correct:
                reset+=1
                return 1  # Double letter omitted


    for i in range(len(answer) - 1):
        if answer[i] == answer[i + 1]:  # If the misspelled word has a double letter
            count2+=1
            modified_misspelled = answer[:i] + answer[i+1:]  # Simulate extra double letter
            print(modified_misspelled)
            if modified_misspelled == correct:
                reset+=1
                return 2  # Double letter added

    if count1==1 and count2==1:
        return 3 # Double letter substitution
    elif count1>1 or count2>1:
        return 4 # Multiple double letter error
    else:
        return 0  # No double letter mistake detected
    

def common_prefix_length(correct_word, answer):
    # Initialize a variable to keep track of the length of the common prefix
    prefix_length = 0

    # Find the length of the shortest word to avoid index errors
    min_len = min(len(correct_word), len(answer))

    # Compare characters from the start (prefix)
    for i in range(min_len):
        if correct_word[i] == answer[i]:
            prefix_length += 1
        else:
            break  # Stop as soon as characters do not match

    return prefix_length


def common_suffix_length(correct_word, answer):
    # Initialize a variable to keep track of the length of the common suffix
    suffix_length = 0

    # Find the length of the shortest word to avoid index errors
    min_len = min(len(correct_word), len(answer))

    # Compare characters from the end (suffix)
    for i in range(1, min_len + 1):
        if correct_word[-i] == answer[-i]:
            suffix_length += 1
        else:
            break  # Stop as soon as characters do not match

    return suffix_length


def calculate_vowel_difference(correct_word, answer):
    vowels = 'aeiou'
    vowel_difference_count = 0

    # Ensure both words are of the same length (pad with spaces if necessary)
    length = max(len(correct_word), len(answer))

    if len(correct_word) != len(answer):
      return 100

    # Compare each character by its position
    for i in range(length):
        # If the index is out of bounds in one of the words, treat it as a mismatch
        correct_char = correct_word[i]
        user_char = answer[i]

        # Check if they are vowels
        correct_is_vowel = correct_char in vowels
        user_is_vowel = user_char in vowels

        if correct_is_vowel == user_is_vowel:
          if correct_char != user_char:
            vowel_difference_count += 1

    return vowel_difference_count


def calculate_consonant_difference(correct_word, answer):
    vowels = 'aeiou'
    consonant_difference_count = 0

    # Ensure both words are of the same length (pad with spaces if necessary)
    length = max(len(correct_word), len(answer))

    if len(correct_word) != len(answer):
      return 100

    # Compare each character by its position
    for i in range(length):
        # If the index is out of bounds in one of the words, treat it as a mismatch
        correct_char = correct_word[i]
        user_char = answer[i]

        # Check if they are consonants
        if correct_char.isalpha() and user_char.isalpha():
            correct_is_consonant = correct_char not in vowels
            user_is_consonant = user_char not in vowels

            if correct_is_consonant == user_is_consonant:
              if correct_char != user_char:
                consonant_difference_count += 1

    return consonant_difference_count


def extract_features(correct, misspelled, answer):
    features = {}

    #  Edit Distance (Levenshtein)
    features["edit_distance"] = edit_distance(correct, answer)

    #  Word Length Difference
    features["length_diff"] = abs(len(correct) - len(answer))

    #  Phonetic Similarity (Metaphone)
    correct_phonetic = doublemetaphone(correct)[0]
    misspelled_phonetic = doublemetaphone(answer)[0]
    features["phonetic_match"] = int(correct_phonetic == misspelled_phonetic)

    # Phonetic Edit Distance (Levenshtein)
    features["phonetic_edit_distance"] = edit_distance(correct_phonetic, misspelled_phonetic)

    #  Jaccard Similarity (Character Overlap)
    correct_set, misspelled_set = set(correct), set(answer)
    features["jaccard_similarity"] = len(correct_set & misspelled_set) / len(correct_set | misspelled_set)

    # Common Prefix/Suffix Length
    features["common_prefix_len"] = common_prefix_length(correct, answer)
    features["common_suffix_len"] = common_suffix_length(correct, answer)

    #  Vowel Difference Count
    vowels = "aeiou"
    features["vowel_diff_count"] = calculate_vowel_difference(correct, answer)

    #  Consonant Difference Count
    consonants = set(string.ascii_lowercase) - set(vowels)
    features["consonant_diff_count"] = calculate_consonant_difference(correct, answer)

    #  Number of Insertions
    features["num_insertions"] = max(0, len(answer) - len(correct))

    #  Number of Deletions
    features["num_deletions"] = max(0, len(correct) - len(answer))

    #  Updated Double Letter Mistake
    features["double_letter_error"] = detect_double_letter_mistake(correct, answer)

    #  Cook’s Classification Label
    features["cook_error_type"] = classify_cook_error(correct, answer)

    return features


def clean_dataset(df):
    # Convert to lowercase and trim whitespace
    df["correct_word"] = df["correct_word"].str.lower().str.strip()


    # Create a cleaned version of answers without special characters and convert to lowercase and trim whitespace
    df["answer_cleaned"] = df["user_answer"].str.replace(r"[-_'’]", "", regex=True).str.lower().str.strip()

    # Convert Correct_Word and Misspelled_Word to strings and fill missing values
    df["correct_word"] = df["correct_word"].astype(str).fillna("")
    df["answer_cleaned"] = df["answer_cleaned"].astype(str).fillna("")

    # Save the cleaned dataset
    df.to_csv("answers_cleaned_temp.csv", index=False)

    return df


def get_features(df):

    df_cleaned = clean_dataset(df)

    df_features = df_cleaned.apply(
        lambda row: extract_features(row["correct_word"], row["user_answer"], row["answer_cleaned"]),
        axis=1
    )

    # Convert extracted features into DataFrame
    df_features_list = pd.DataFrame(df_features.tolist())

    # Merge extracted features with original dataset
    df_features = pd.concat([df_cleaned, df_features_list], axis=1)

    # Save the cleaned dataset
    df_features.to_csv("answers_features_temp.csv", index=False)

    return df_features


# Function to provide additional word information (frequency, syllables, and length)
def get_word_info_description(word, filtered_df):
    # Get the word info from the filtered dataframe
    word_info = filtered_df[filtered_df['lemma'] == word].iloc[0]

    frequency_category = word_info['frequency_category']
    syllable_count = word_info['syllable_count']
    word_length = word_info['length']

    # Construct the descriptive comment
    word_info_desc = f"This word is of {frequency_category} frequency."

    # Provide additional feedback based on frequency and length
    if frequency_category == 'low':
        word_info_desc += " It’s a rare word, so don't worry if it's a bit tricky!"
    elif frequency_category == 'medium':
        word_info_desc += " Maybe you've heard this word more than you care to admit!"
    elif frequency_category == 'high':
        word_info_desc += " This is a common word – you're probably familiar with it!"

    word_info_desc += f" The word '{word}' is of length {word_length} characters and has {syllable_count} syllables. It’s relatively easy to pronounce – you’re on the right track!"

    return word_info_desc

# Main function to generate feature DataFrame
def generate_error_report(df, ageGroup, difficulty):
    data = []
    cook_error_desc = ''
    cook_error_message = ''
    edit_distance_desc = ''
    edit_distance_message = ''
    length_diff_desc = ''
    length_diff_message = ''
    jaccard_desc = ''
    jaccard_message = ''

    # Dictionary to map age group to dataframe
    age_group_map = {
        '5-6': df1,
        '7-8': df2,
        '9-10': df3,
        '11-12': df4
    }

    # Filter the corresponding dataframe based on difficulty
    df_map = age_group_map[ageGroup]
    filtered_df = df_map[df_map['difficulty'] == difficulty]

    df_features = get_features(df)

    for _, row in df_features.iterrows():
        correct_word = row['correct_word']
        answer_cleaned = row['answer_cleaned']

        # Cook's Classification Description
        if row['cook_error_type'] == 'No Error':
            cook_error_message = "Absolutely Correct Answer! Well Done! 🎉 You nailed it!"
            cook_error_desc = "A perfect spelling with no errors at all."
        elif row["cook_error_type"] == "Multiple Errors":
            cook_error_message = "Oops, looks like there were multiple errors! Let's work on those together. 🤔"
            cook_error_desc = "This means that you have made are more than one mistake in the word, making it difficult to attribute to just one type of error. It’s a collection of issues that need fixing."
        elif row["cook_error_type"] == "Substitution Error":
            substitution_errors = check_substitution_error(correct_word, answer_cleaned)
            print(substitution_errors)
            cook_error_message = "You swapped a letter with the wrong one! Close, but no worries. Try again! 🔄"
            cook_error_desc = f"You swapped {correct_word[substitution_errors[0]]} for {answer_cleaned[substitution_errors[0]]} which doesn't belong in {correct_word} It’s a common mistake, but you’re almost there!"
        elif row["cook_error_type"] == "Transposition Error":
            transposition_errors = check_transposition_error(correct_word, answer_cleaned)
            print(transposition_errors)
            cook_error_message = "It seems like you swapped two letters in the wrong order. A little dance of letters! 💃🕺"
            cook_error_desc = f"You swapped the positions of two adjacent letters. {correct_word[transposition_errors[0]]} and  {correct_word[transposition_errors[1]]} in the word {correct_word}. It’s a classic transposition error — the letters are in the correct word but in the wrong order."
        elif row["cook_error_type"] == "Insertion Error":
            num_insertions = row['num_insertions']
            cook_error_message = f"You added {num_insertions} extra letter(s)! Oops, those definitely snuck in there. ✨"
            cook_error_desc = f"You added {num_insertions} extra letter(s) to the word. Sometimes accidental letter(s) may get typed in, creating a small but noticeable error."
        elif row["cook_error_type"] == "Omission Error":
            num_deletions = row['num_deletions']
            cook_error_message = f"Looks like you missed {num_deletions} letter(s)! Don't worry, just add the missing piece(s). 🧩"
            cook_error_desc = f"You left out {num_deletions} letter in the correct word. It’s like {num_deletions} piece(s) of the puzzle is missing, but once added, everything fits perfectly!"
        elif row["cook_error_type"] == "Unknown":
            cook_error_message = "Something went wrong, but we couldn't quite figure it out. Let's try again! 🤷‍♂️"
            cook_error_desc = "The system couldn’t classify the error into one of the known categories. It’s a mystery for now, but we can try again!"

        # Levenshtein Distance Description
        edit_distance = row['edit_distance']
        if edit_distance == 0:
            edit_distance_message = "Absolutely Match! 🎉"
            edit_distance_desc = "The word is exactly correct. No mistake at all."
        elif edit_distance == 1:
            edit_distance_message = "Almost there! Just a small typo. Try again, you were really close! 🤔"
            edit_distance_desc = "This suggests a minor mistake, like a simple typographical error or autocorrection. The misspelled word is very close to the correct word."
        elif edit_distance in [2, 3]:
            edit_distance_message = "Not too far off! You're getting there. It's a small difference that’s easy to fix! 🚀"
            edit_distance_desc = "The word is somewhat close to the correct one. It's a borderline error, indicating possible confusion between similar-looking or similar-sounding words."
        else:
            edit_distance_message = "Whoa! That's quite a difference. Let's take a closer look at the spelling! 🧐"
            edit_distance_desc = "The misspelled word deviates significantly from the correct one. This is more than a typographical error and could indicate a larger mistake."


        # Length Difference Description
        length_diff = row['length_diff']
        if  length_diff <= 3 and edit_distance > 3:
            length_diff_message = "You got the length of the word right, but missed some details. You're close! 🧐"
            length_diff_desc = "You seem to have grasped the length of the word correctly but may have missed a key part of the word. This could suggest that you understood the word's structure but didn't recall the exact letters or spelling correctly."
        elif length_diff > 6 or length_diff > 7:
            length_diff_message = "The length is way off. Looks like there was an accidental submission with a big difference in length. No worries, let's fix it! ⏳"
            length_diff_desc = "A significant difference in length likely indicates that you accidentally submitted the word with major errors, such as typing extra characters or omitting too many."
        else:
            length_diff_message = "There’s a bit of a difference in length. Maybe just a little slip-up or a small distraction. Try again! 😅"
            length_diff_desc = "A moderate difference in length could indicate that you made a careless mistake or simply wasn’t paying full attention. The word structure is mostly retained, but the length mismatch points to an inconsistency in attention to detail."


        # Jaccard Similarity Description
        jaccard_similarity = row['jaccard_similarity']
        jaccard_percentage = round(jaccard_similarity * 100)  # Convert to percentage and round to nearest whole number

        jaccard_message = f"It seems your answer is {jaccard_percentage}% correct."

        if jaccard_percentage == 0:
            jaccard_desc = "No characters in common. Looks like we're starting from scratch! Let's try again! 🚫"
        elif jaccard_percentage <= 30:
            jaccard_desc = "We’ve got a long way to go! Keep going! 💪"
        elif jaccard_percentage <= 60:
            jaccard_desc = "You’re getting there, but there’s still room for improvement! 😊"
        elif jaccard_percentage <= 90:
            jaccard_desc = "Nice! You’re so close! 🎯"
        else:
            jaccard_desc = "Excellent! So close to perfection! 🌟"


        # Common Prefix and Suffix Length Description
        common_prefix_len = row['common_prefix_len']
        common_suffix_len = row['common_suffix_len']

        # Prefix description
        if common_prefix_len > 0:
            prefix_desc = f"You nailed the first {common_prefix_len} letters! That’s a great start! 🚀"
        else:
            prefix_desc = "It looks like you did not guess the word from the beginning! Let’s focus there. 🔍"

        # Suffix description
        if common_suffix_len > 0:
            suffix_desc = f"You got the last {common_suffix_len} letters correct! Finishing strong! 💪"
        else:
            suffix_desc = "No match at the end... It's like the last part of the word got away! Let’s wrap that up. 🎯"

        # Combine both prefix and suffix descriptions
        if common_prefix_len > 0 and common_suffix_len > 0:
            common_desc = f"{prefix_desc} And {suffix_desc} Nice job!"
        else:
            common_desc = f"{prefix_desc} {suffix_desc} We’re getting there!"

        
        # Phonetic Match and Distance Description
        phonetic_match = row['phonetic_match']
        phonetic_edit_distance = row['phonetic_edit_distance']

        if phonetic_match == 1:
            phonetic_message = "Sounds like you're on the right track! You might be confusing homophones though. Double-check the spelling! 🎧"
            phonetic_desc = "This means your answer sounds eerily same (a good homophone match) to the correct word. Your spelling is probably close to the correct word, but you might be confused by a homophone (words that sound the same but are spelled differently)."
        elif phonetic_match == 0:
            # If phonetic match is 0, use phonetic edit distance
            if phonetic_edit_distance <= 2:
                phonetic_message = f"The words sound similar, but there’s a slight difference in how they’re pronounced. Keep listening closely! 👂"
                phonetic_desc = "This indicates that the words are slightly phonetically similar but not the same. This could happen due to common mispronunciations or minor differences in pronunciation."
            else:
                phonetic_message = "Hmm, these words sound pretty different. Looks like the pronunciation might be way off. Let’s try again! 🔄"
                phonetic_desc = "This means that your spelling sounds quite different from the correct word. The phonetic structure of the word is significantly different."


        # Double Letter Error Description
        double_letter_error = row['double_letter_error']

        if double_letter_error == 0:
            double_letter_message = "You got it! No double letter issues here. Nice work! 🏅"
            double_letter_desc = "You correctly spelled the word, and there were no issues with double letters."
        elif double_letter_error == 1:
            double_letter_message = "Looks like you missed one of the double letters. Easy to do, just add that second letter! ✨"
            double_letter_desc = "You omitted one of the double letters, a common mistake in spelling words with double letters."
        elif double_letter_error == 2:
            double_letter_message = "Uh-oh, looks like you added an extra letter in a double letter spot! Oops! Let’s fix that! 🔄"
            double_letter_desc = "You added an extra letter where a double letter should be, creating an incorrect spelling."
        elif double_letter_error == 3:
            double_letter_message = "You swapped one of the double letters with a different letter. Close, but let’s get it right! 🔁"
            double_letter_desc = "You substituted one of the letters in a double letter sequence with a different letter. This is a common substitution mistake."
        elif double_letter_error == 4:
            double_letter_message = "Whoa, multiple double letter issues going on here! Let’s take a closer look and fix these together. 🧐"
            double_letter_desc = "You made multiple mistakes with double letters, making it harder to predict exactly what went wrong."

        word_info_desc = get_word_info_description(correct_word, filtered_df)

        error_report = {
            'Correct Word': correct_word,
            'Answer': answer_cleaned,
            'Cook Error Description': cook_error_desc,
            'Cook Error Message': cook_error_message,
            'Edit Distance Description': edit_distance_desc,
            'Edit Distance Message': edit_distance_message,
            'Length Diff Description': length_diff_desc,
            'Length Diff Message': length_diff_message,
            'Jaccard Message': jaccard_message,
            'Jaccard Description': jaccard_desc,
            'Common PreSuf Description': common_desc,
            'Phonetic Description': phonetic_desc,
            'Phonetic Message': phonetic_message,
            'Double Letter Description': double_letter_desc,
            'Double Letter Message': double_letter_message,
            'Word Information': word_info_desc,
        }

        data.append(error_report)

    # Convert the data into a DataFrame
    return data