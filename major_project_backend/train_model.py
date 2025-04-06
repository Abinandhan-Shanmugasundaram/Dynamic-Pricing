import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
import joblib

# Load the dataset
df = pd.read_csv("ride_pricing_data.csv")

# Convert categorical values to numerical
df['weather'] = df['weather'].astype('category').cat.codes
df['traffic'] = df['traffic'].astype('category').cat.codes

# Features and Target
X = df[['demand', 'supply', 'weather', 'traffic', 'base_fare']]
y = df['dynamic_fare']

# Split dataset
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train model
model = LinearRegression()
model.fit(X_train, y_train)

# Save trained model
joblib.dump(model, "dynamic_pricing_model.pkl")

print("Model trained and saved as dynamic_pricing_model.pkl")
