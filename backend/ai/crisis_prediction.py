def predict_crisis_risk(region_data: dict) -> dict:
    rainfall = min(max(region_data.get("rainfall", 0), 0), 100)
    flood_alert = region_data.get("flood_alert", 0)
    population_density = min(max(region_data.get("population_density", 0), 0), 2000)
    past_crises = min(max(region_data.get("past_crises", 0), 0), 50)

    # 1) Normalize values
    rainfall_score = rainfall / 100.0
    population_score = population_density / 1000.0
    history_score = past_crises / 20.0

    # 2) Compute risk score
    risk_score = (
        0.4 * rainfall_score +
        0.3 * population_score +
        0.3 * history_score
    )

    # 3) Add flood_alert bonus
    if flood_alert == 1:
        risk_score += 0.2

    # 4) Cap at 1.0
    risk_score = min(1.0, risk_score)

    # 5) Assign risk level
    if risk_score > 0.7:
        risk_level = "high"
    elif risk_score > 0.4:
        risk_level = "medium"
    else:
        risk_level = "low"
        
    # 6) Generate explanation
    factors = []
    if rainfall_score > 0.6:
        factors.append("heavy rainfall")
    if flood_alert == 1:
        factors.append("active flood alert")
    if population_score > 0.7:
        factors.append("high population density")
    if history_score > 0.5:
        factors.append("frequent past crises")

    return {
        "risk_score": float(risk_score),
        "risk_level": risk_level,
        "explanation": factors
    }
