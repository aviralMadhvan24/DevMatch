# import pickle
# from sklearn.feature_extraction.text import TfidfVectorizer
# from sklearn.linear_model import LogisticRegression

# # Dummy training data (upgrade later)
# data = [
#     ("fix typo in README", "easy"),
#     ("update documentation", "easy"),
#     ("add login authentication", "medium"),
#     ("build REST API", "medium"),
#     ("optimize database queries", "hard"),
#     ("implement distributed system", "hard")
# ]

# texts = [x[0] for x in data]
# labels = [x[1] for x in data]

# vectorizer = TfidfVectorizer()
# X = vectorizer.fit_transform(texts)

# model = LogisticRegression()
# model.fit(X, labels)

# def predict_difficulty(text):
#     X_input = vectorizer.transform([text])
#     return model.predict(X_input)[0]

# # import pickle
# # from utils.preprocessing import preprocess_text

# # # load trained model
# # # with open("models/difficulty.pkl", "rb") as f:
# # #     model = pickle.load(f)

# # # def predict_difficulty(title, description):
# # #     text = title + " " + description
# # #     processed = preprocess_text(text)
# # #     prediction = model.predict([processed])[0]
# # #     return prediction

# # with open("models/vectorizer.pkl", "rb") as f:
# #     vectorizer = pickle.load(f)

# # with open("models/difficulty.pkl", "rb") as f:
# #     model = pickle.load(f)

# # def predict_difficulty(title, description):
# #     text = title + " " + description
# #     processed = [text]
# #     vectorized = vectorizer.transform(processed)
# #     prediction = model.predict(vectorized)[0]
# #     return prediction

# # # run commented code after running models/train_model.py

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression

from services.github_data import fetch_issues
from services.labeler import assign_difficulty

vectorizer = TfidfVectorizer(max_features=5000)
model = LogisticRegression()

def train_model():
    issues = fetch_issues()

    texts = []
    labels = []

    for issue in issues:
        difficulty = assign_difficulty(issue["labels"], issue["text"])
        
        texts.append(issue["text"])
        labels.append(difficulty)

    X = vectorizer.fit_transform(texts)
    model.fit(X, labels)

# Train at startup
train_model()

def predict_difficulty(text):
    X_input = vectorizer.transform([text])
    return model.predict(X_input)[0]