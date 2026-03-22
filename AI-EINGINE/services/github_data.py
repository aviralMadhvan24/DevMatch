import requests

GITHUB_API = "https://api.github.com"

def fetch_issues():
    url = f"{GITHUB_API}/search/issues"
    
    params = {
        "q": "is:issue is:open label:good-first-issue",
        "per_page": 50
    }

    response = requests.get(url, params=params)

    issues = []
    for item in response.json().get("items", []):
        title = item["title"]
        description = item.get("body", "")
        labels = [l["name"] for l in item.get("labels", [])]

        issues.append({
            "text": title + " " + description,
            "labels": labels
        })

    return issues