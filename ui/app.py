import streamlit as st
import pandas as pd
import os

# Define lifestyle categories and corresponding weights for amenities
lifestyle_categories = {
    "Healthy Living": {
        "parks": 2.0, 
        "sports_facilities": 2.0, 
        "bike_lanes": 1.5,
    },
    "Convenience": {
        "grocery_stores": 2.0,
        "retail_centers": 1.8,
        "public_transit": 2.0,
    },
    "Family-Oriented": {
        "public_schools": 2.5,
        "private_schools": 2.0,
        "parks": 1.5,
        "childcare_facilities": 2.0,
    },
    "Cultural Engagement": {
        "cultural_institutions": 2.5,
        "community_centers": 2.0,
        "restaurants_cafes": 1.8,
    },
    "Safety and Security": {
        "police_stations": 3.0,
        "fire_stations": 2.5,
    },
    "Quiet and Peaceful": {
        "parks": 2.0,
        "fire_stations": -2.0,  # Negative weight to avoid noise
        "major_roadways": -2.5,  # Negative weight to avoid busy roads
    },
    "Work-Life Balance": {
        "employment_centers": 2.0,
        "public_transit": 2.5,
        "senior_services": 1.2,
    }
}

# Initialize a dictionary to hold user-selected weights
user_weights = {amenity: 0 for amenities in lifestyle_categories.values() for amenity in amenities}

# UI: Ask users about their lifestyle preferences
st.title("Housing Location Optimizer")
st.header("Tell us about your lifestyle preferences")

for category, amenities in lifestyle_categories.items():
    st.subheader(category)
    preference = st.slider(f"How important is {category} to you?", 0, 10, 5)
    
    for amenity, base_weight in amenities.items():
        user_weights[amenity] += base_weight * preference / 10

# Allow users to fine-tune the weights for each amenity
st.header("Fine-tune the Amenity Weights")
for amenity, weight in user_weights.items():
    user_weights[amenity] = st.slider(f"{amenity.replace('_', ' ').capitalize()} Weight", -10.0, 10.0, float(weight))

# Output the final weights for each amenity
st.write("Based on your preferences, here are the final weights for each amenity:")
st.write(user_weights)

# Save the user weights to a CSV file
user_weights_df = pd.DataFrame(list(user_weights.items()), columns=["amenity", "weight"])

# Define the path where the CSV file will be saved
csv_path = "data/processed/user_weights.csv"

# Ensure the directory exists
os.makedirs(os.path.dirname(csv_path), exist_ok=True)

# Save the DataFrame to the CSV file
user_weights_df.to_csv(csv_path, index=False)

st.write(f"Preferences have been saved to {csv_path}.")