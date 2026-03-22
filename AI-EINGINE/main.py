from fastapi import FastAPI
from routes.ai_routes import router

app = FastAPI()

app.include_router(router, prefix="/ai")

@app.get("/")
def root():
    return {"message": "AI Service Running"}