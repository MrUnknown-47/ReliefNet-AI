from pydantic import BaseModel
from typing import Dict, Optional

class CrisisLocation(BaseModel):
    lat: float
    lng: float

class CrisisReportCreate(BaseModel):
    title: str
    description: str
    location: CrisisLocation
    people_affected: int
    category: str

class CrisisReportResponse(BaseModel):
    id: str
    title: str
    description: str
    location: CrisisLocation
    people_affected: int
    category: str
    ai_analysis: Optional[Dict] = None
