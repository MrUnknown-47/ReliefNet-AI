import math

def haversine_distance(lat1, lon1, lat2, lon2):
    R = 6371.0
    
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    
    a = math.sin(dlat / 2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    distance = R * c
    return distance

def match_volunteers(crisis, volunteers):
    crisis_lat = crisis.location.lat
    crisis_lon = crisis.location.lng
    crisis_category = crisis.category.lower() if crisis.category else ""
    
    ranked_volunteers = []
    
    for vol in volunteers:
        v_lat = vol.get('lat', 0.0)
        v_lon = vol.get('lng', 0.0)
        
        distance_km = haversine_distance(crisis_lat, crisis_lon, v_lat, v_lon)
        distance_score = 1 / (1 + max(distance_km, 0.001))
        
        v_skills = [s.lower() for s in vol.get('skills', [])]
        skill_score = 1 if crisis_category in v_skills else 0.5
        
        final_score = (0.7 * distance_score) + (0.3 * skill_score)
        
        vol_copy = dict(vol)
        vol_copy['match_score'] = final_score
        vol_copy['distance_km'] = distance_km
        ranked_volunteers.append(vol_copy)
        
    ranked_volunteers.sort(key=lambda x: x['match_score'], reverse=True)
    return ranked_volunteers[:5]
