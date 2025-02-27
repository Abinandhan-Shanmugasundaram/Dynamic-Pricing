import firebase_admin  # type: ignore
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate("firebase_credentials.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Reference the "ride_pricing" collection
collection_ref = db.collection("ride_pricing")

# Fetch and print all documents in the "ride_pricing" collection
docs = collection_ref.stream()

data_found = False
for doc in docs:
    print(f"{doc.id} => {doc.to_dict()}")
    data_found = True

if not data_found:
    print("No Data Found!")

# List all collections in the Firestore database
collections = db.collections()
print("\nAvailable Collections in Firestore:")
for collection in collections:
    print(f"- {collection.id}")

