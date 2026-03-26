'''from fastapi import FastAPI
from routes.ai_routes import router

app = FastAPI()

app.include_router(router, prefix="/ai")

@app.get("/")
def root():
    return {"message": "AI Service Running"}
'''
from fastapi import FastAPI
import requests
from datetime import datetime, timezone
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/v1/recommendations")
def get_recommendations(page: int = 1, per_page: int = 10):
    url = "https://api.github.com/search/issues?q=label:good-first-issue+state:open"

    response = requests.get(url)
    data = response.json()

    issues = []
    now = datetime.now(timezone.utc).isoformat()

    for item in data.get("items", [])[:per_page]:
        repo_url = item.get("repository_url", "")
        parts = repo_url.split("/")
        repo_owner = parts[-2] if len(parts) >= 2 else "unknown"
        repo_name = parts[-1] if len(parts) >= 1 else "unknown"

        issues.append({
            "id": str(item.get("id", "")),
            "title": item.get("title", "") or "",

            "repo_name": repo_name,
            "repo_owner": repo_owner,

            "ai_summary": item.get("title", "") or "",

            "difficulty": "medium",

            "required_skills": ["Git", "Debugging"],

            "match_score": 0.5,

            "issue_number": item.get("number", 0),

            "github_url": item.get("html_url", "") or "",

            "contribution_guide": None,

            "created_at": now,

            "comments_count": item.get("comments", 0),

            "labels": [l.get("name", "") for l in item.get("labels", [])],

            "repo_language": None,

            "repo_stars": 0
        })

    return {"issues": issues}