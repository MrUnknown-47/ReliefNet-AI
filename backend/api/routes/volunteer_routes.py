from fastapi import APIRouter
from typing import List
from uuid import uuid4
from models.volunteer_model import VolunteerRegister, VolunteerResponse
from services.firestore_service import save_volunteer, get_all_volunteers

router = APIRouter(tags=["Volunteer"])

@router.post("/register", status_code=201)
def register_volunteer(volunteer: VolunteerRegister):
    new_volunteer = VolunteerResponse(
        id=str(uuid4()),
        name=volunteer.name,
        skills=volunteer.skills,
        lat=volunteer.lat,
        lng=volunteer.lng
    )
    
    # Save to Firestore as dictionary
    save_volunteer(new_volunteer.dict())
    
    return {"message": "Volunteer registered", "volunteer_id": new_volunteer.id}

@router.get("/", response_model=List[VolunteerResponse])
def get_volunteers_list():
    # Convert Firestore documents to dictionaries before returning
    return get_all_volunteers()
