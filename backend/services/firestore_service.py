import os
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

# Load credentials from environment variable
cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH")

# Initialize Firebase Admin SDK
if cred_path and not firebase_admin._apps:
    try:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
    except Exception as e:
        print(f"Error initializing Firebase with credentials: {e}")
elif not firebase_admin._apps:
    try:
        # Fallback to default application credentials if cred_path is not set
        firebase_admin.initialize_app()
    except Exception as e:
        print(f"Error initializing Firebase with default credentials: {e}")

try:
    db = firestore.client()
except Exception as e:
    print(f"Error creating Firestore client: {e}")
    db = None

def save_crisis(report_data: dict):
    if db:
        doc_id = report_data["id"]
        report_data["created_at"] = datetime.utcnow()
        db.collection("crisis_reports").document(doc_id).set(report_data)

def get_all_crises():
    if not db:
        return []
    docs = db.collection("crisis_reports").stream()
    return [{"id": doc.id, **doc.to_dict()} for doc in docs]

def save_volunteer(volunteer_data: dict):
    if db:
        doc_id = volunteer_data["id"]
        db.collection("volunteers").document(doc_id).set(volunteer_data)

def get_all_volunteers():
    if not db:
        return []
    docs = db.collection("volunteers").stream()
    return [{"id": doc.id, **doc.to_dict()} for doc in docs]
