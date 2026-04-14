from fastapi import APIRouter
from pydantic import BaseModel
from ai.crisis_prediction import predict_crisis_risk

router = APIRouter()

class PredictionRequest(BaseModel):
    region: str
    rainfall: float
    flood_alert: int
    population_density: float
    past_crises: int

@router.post("/")
def predict_risk(request: PredictionRequest):
    data = {
        "rainfall": request.rainfall,
        "flood_alert": request.flood_alert,
        "population_density": request.population_density,
        "past_crises": request.past_crises
    }
    
    prediction = predict_crisis_risk(data)
    
    return {
        "region": request.region,
        "prediction": prediction
    }
