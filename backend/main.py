from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.routes import crisis_routes, volunteer_routes, prediction_routes

app = FastAPI(
    title="ReliefNet AI Backend",
    description="FastAPI backend for Disaster Response Platform",
    version="1.0.0"
)

app.include_router(crisis_routes.router, prefix="/api/crisis", tags=["Crisis"])
app.include_router(volunteer_routes.router, prefix="/api/volunteer", tags=["Volunteer"])
app.include_router(prediction_routes.router, prefix="/api/predict", tags=["Prediction"])

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "service": "ReliefNet AI Backend",
        "version": "1.0.0"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
