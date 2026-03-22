def assign_difficulty(labels, text):
    text = text.lower()

    if "good first issue" in labels:
        return "easy"

    if "documentation" in text or "typo" in text:
        return "easy"

    if "refactor" in text or "api" in text:
        return "medium"

    if "optimize" in text or "scalable" in text or "distributed" in text:
        return "hard"

    return "medium"