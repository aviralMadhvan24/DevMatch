from transformers import pipeline

# Better model (instruction-following)
from transformers import pipeline

generator = pipeline(
    "text-generation",   # ✅ CHANGE THIS
    model="google/flan-t5-base"
)

def explain_issue(title, description):
    prompt = f"""
Explain the following GitHub issue for a beginner developer.

Title: {title}
Description: {description}

Give output in this format:

Explanation:
(simple explanation)

Steps:
1.
2.
3.

Skills Required:
- 
- 
"""

    result = generator(
        prompt,
        max_length=300,
        temperature=0.5
    )

    return result[0]['generated_text']

# from transformers import pipeline

# # Load model (use small first, upgrade later if needed)
# # generator = pipeline(
# #     "text2text-generation",
# #     model="google/flan-t5-small"
# # )
# generator = pipeline(
#     "text-generation",
#     model="gpt2"
# )

# def explain_issue(title, description):
#     prompt = f"""
# You are a senior developer helping a beginner.

# Explain this GitHub issue in a very simple and structured way.

# Title: {title}
# Description: {description}

# Respond in this format:

# Explanation:
# <simple explanation>

# Steps to Solve:
# 1.
# 2.
# 3.

# Skills Required:
# - 
# - 
# """

#     try:
#         result = generator(
#             prompt,
#             max_length=256,
#             do_sample=True,
#             temperature=0.7
#         )

#         return result[0]['generated_text']

#     except Exception as e:
#         print("AI ERROR:", e)
#         return "Failed to generate explanation"
        
