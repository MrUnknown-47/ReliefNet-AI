from pydantic import BaseModel
from typing import List

class VolunteerRegister(BaseModel):
    name: str
    skills: List[str]
    lat: float
    lng: float

class VolunteerResponse(BaseModel):
    id: str
    name: str
    skills: List[str]
    lat: float
    lng: float
