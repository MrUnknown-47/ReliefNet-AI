from models.crisis_model import CrisisReportCreate

def analyze_crisis(report: CrisisReportCreate) -> dict:
    flood_keywords = ["flood", "water level", "overflow"]
    fire_keywords = ["fire", "burning", "smoke"]
    medical_keywords = ["injured", "medical", "hospital"]
    food_keywords = ["hunger", "food", "ration"]
    water_keywords = ["water", "drinking water"]

    # Combine title + description text
    text = f"{report.title} {report.description}".lower()

    # Detect crisis_types
    crisis_type = []
    if any(kw in text for kw in flood_keywords):
        crisis_type.append("flood")
    if any(kw in text for kw in fire_keywords):
        crisis_type.append("fire")
        
    if not crisis_type:
        crisis_type = ["general"]
        
    # Detect needs list based on keywords
    needs = []
    if any(kw in text for kw in medical_keywords):
        needs.append("medical")
    if any(kw in text for kw in food_keywords):
        needs.append("food")
    if any(kw in text for kw in water_keywords):
        needs.append("water")
        
    if not needs:
        needs.append("general")
        
    # Compute urgency_score based on people_affected
    urgency_score = min(1.0, report.people_affected / 1000.0)
    
    if urgency_score > 0.7:
        urgency_level = "high"
    elif urgency_score > 0.4:
        urgency_level = "medium"
    else:
        urgency_level = "low"

    return {
        "crisis_type": crisis_type,
        "urgency_score": float(urgency_score),
        "urgency_level": urgency_level,
        "needs": needs
    }
