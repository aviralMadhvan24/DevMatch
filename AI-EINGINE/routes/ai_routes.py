from fastapi import APIRouter
from pydantic import BaseModel

from services.llm_service import explain_issue
from services.difficulty_model import predict_difficulty

router = APIRouter()

class IssueRequest(BaseModel):
    title: str
    description: str

@router.post("/explain")
def explain(req: IssueRequest):
    explanation = explain_issue(req.title, req.description)
    difficulty = predict_difficulty(req.title + " " + req.description)

    return {
        "explanation": explanation,
        "difficulty": difficulty
    }
# from fastapi import APIRouter
# from pydantic import BaseModel
# from services.llm_service import explain_issue
# from services.difficulty_model import predict_difficulty

# router = APIRouter()

# class IssueRequest(BaseModel):
#     title: str
#     description: str

# @router.post("/explain")
# def explain(req: IssueRequest):
#     explanation = explain_issue(req.title, req.description)
#     return {"explanation": explanation}

# @router.post("/difficulty")
# def difficulty(req: IssueRequest):
#     level = predict_difficulty(req.title, req.description)
#     return {"difficulty": level}