from fastapi import APIRouter
from typing import List
from uuid import uuid4
from models.crisis_model import CrisisReportCreate, CrisisReportResponse
from services.firestore_service import save_crisis, get_all_crises, get_all_volunteers
from ai.volunteer_matching import match_volunteers
from ai.crisis_analyzer import analyze_crisis

router = APIRouter(tags=["Crisis"])

@router.post("/report", status_code=201)
def create_crisis_report(report: CrisisReportCreate):
    analysis = analyze_crisis(report)
    new_report = CrisisReportResponse(
        id=str(uuid4()),
        title=report.title,
        description=report.description,
        location=report.location,
        people_affected=report.people_affected,
        category=report.category,
        ai_analysis=analysis
    )
    
    # Save to Firestore as dictionary
    save_crisis(new_report.dict())
    
    volunteers = get_all_volunteers()
    matched = match_volunteers(new_report, volunteers)
    
    return {
        "message": "Crisis report created", 
        "report_id": new_report.id,
        "ai_analysis": analysis,
        "matched_volunteers": matched
    }

@router.get("/", response_model=List[CrisisReportResponse])
def get_all_crisis_reports():
    # Convert Firestore documents to dictionaries before returning
    return get_all_crises()

