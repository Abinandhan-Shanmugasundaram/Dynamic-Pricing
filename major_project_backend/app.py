import firebase_admin
from firebase_admin import credentials, firestore
from flask import Flask, request, jsonify
import pickle
import numpy as np

# Initialize Flask App
app = Flask(__name__)

# Initialize Firebase Admin SDK
cred = credentials.Certificate("firebase_credentials.json")  # Ensure this file is correct
firebase_admin.initialize_app(cred)
db = firestore.client()

# Load Pretrained Model
with open("dynamic_pricing_model.pkl", "rb") as model_file:
    model = pickle.load(model_file)
def store_pricing_data(city_id, base_fare, dynamic_fare, demand, supply, weather, traffic):
    doc_ref = db.collection("ride_pricing").document(city_id)
    doc_ref.set({
        "base_fare": base_fare,
        "dynamic_fare": dynamic_fare,
        "demand": demand,
        "supply": supply,
        "weather": weather,
        "traffic": traffic
    })
    return "Data stored successfully!"

def get_pricing_data(city_id):
    doc_ref = db.collection("ride_pricing").document(city_id)
    doc = doc_ref.get()
    if doc.exists:
        return doc.to_dict()
    else:
        return None
@app.route("/predict", methods=["POST"])
def predict():
    data = request.json
    city_id = data["city_id"]
    demand = data["demand"]
    supply = data["supply"]
    weather = data["weather"]
    traffic = data["traffic"]
    
    # Prepare data for model
    input_features = np.array([[demand, supply, weather, traffic]])
    
    # Predict Dynamic Fare
    dynamic_fare = model.predict(input_features)[0]
    base_fare = 50  # Example base fare

    # Store result in Firestore
    store_pricing_data(city_id, base_fare, dynamic_fare, demand, supply, weather, traffic)

    return jsonify({"city_id": city_id, "base_fare": base_fare, "dynamic_fare": dynamic_fare})

@app.route("/pricing/<city_id>", methods=["GET"])
def get_pricing(city_id):
    pricing_data = get_pricing_data(city_id)
    if pricing_data:
        return jsonify(pricing_data)
    else:
        return jsonify({"error": "No data found"}), 404
