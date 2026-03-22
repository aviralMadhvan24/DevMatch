import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
import pickle

# sample dataset (you can expand later)
data = {
    "text": [
        "fix typo in readme",
        "add login authentication system",
        "optimize database queries",
        "update documentation",
        "build full payment integration"
    ],
    "label": [
        "beginner",
        "intermediate",
        "advanced",
        "beginner",
        "advanced"
    ]
}

df = pd.DataFrame(data)

vectorizer = TfidfVectorizer()
X = vectorizer.fit_transform(df["text"])

model = LogisticRegression()
model.fit(X, df["label"])

# save both
with open("models/difficulty.pkl", "wb") as f:
    pickle.dump(model, f)

with open("models/vectorizer.pkl", "wb") as f:
    pickle.dump(vectorizer, f)