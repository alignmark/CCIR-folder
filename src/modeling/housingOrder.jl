using JuMP
using HiGHS
using DataFrames
using CSV

# Assume data is already processed and loaded as DataFrames

# Load processed data (replace with actual paths)
housing_data = DataFrame(CSV.File("data/processed/housing.csv"))

# List of amenities CSV files
amenity_files = [
    "data/processed/grocery_stores.csv",
    "data/processed/retail_centers.csv",
    "data/processed/public_schools.csv",
    "data/processed/private_schools.csv",
    "data/processed/public_libraries.csv",
    "data/processed/hospitals.csv",
    "data/processed/parks.csv",
    "data/processed/sports_facilities.csv",
    "data/processed/community_centers.csv",
    "data/processed/public_transit.csv",
    "data/processed/major_roadways.csv",
    "data/processed/bike_lanes.csv",
    "data/processed/restaurants_cafes.csv",
    "data/processed/cultural_institutions.csv",
    "data/processed/places_of_worship.csv",
    "data/processed/police_stations.csv",
    "data/processed/fire_stations.csv",
    "data/processed/childcare_facilities.csv",
    "data/processed/employment_centers.csv",
    "data/processed/senior_services.csv"
]

# Load all amenities into a list of DataFrames
amenities = [DataFrame(CSV.File(file)) for file in amenity_files]

# Extract housing coordinates
S = [housing_data[:latitude] housing_data[:longitude]]

# Convert amenities into the correct format for the model
A = [[amenity[:latitude] amenity[:longitude]] for amenity in amenities]

# User-defined weights for each amenity type
# Adjust these weights according to user preferences (example values)
D = [
    2.0,  # Grocery Stores
    1.5,  # Retail Centers
    2.5,  # Public Schools
    2.0,  # Private Schools
    1.8,  # Public Libraries
    3.0,  # Hospitals
    2.2,  # Parks
    1.5,  # Sports Facilities
    1.3,  # Community Centers
    2.0,  # Public Transit
    0.5,  # Major Roadways (might be a negative factor if too close)
    1.2,  # Bike Lanes and Walking Paths
    1.8,  # Restaurants and Cafes
    1.6,  # Cultural Institutions
    1.4,  # Places of Worship
    1.0,  # Police Stations
   -2.0,  # Fire Stations (negative weight as user prefers to avoid)
    1.9,  # Childcare Facilities
    2.3,  # Employment Centers
    2.1   # Senior Services
]

# Create the optimization model
model = Model(HiGHS.Optimizer)

# Define binary variables to select the top N locations
M = 10  # Number of locations to be selected
@variable(model, x[1:size(S, 1)], Bin)  # 1 if the location is selected, 0 otherwise

# Ensure exactly M locations are selected
@constraint(model, sum(x) == M)

# Expression to calculate the shortest distance from each house to the nearest amenity of each type
@expression(model, c[house=1:size(S, 1), type=1:length(A)], minimum(
    abs(S[house, 1] - A[type][ind, 1]) + abs(S[house, 2] - A[type][ind, 2])
    for ind in 1:size(A[type], 1)
))

# Objective: Maximize user satisfaction based on proximity to preferred amenities
@objective(model, Max, sum(D[t] * sum((1 / (c[k, t] + 1e-5)) * x[k] for k in 1:size(S, 1)) for t in 1:length(A)))

# Optimize the model
optimize!(model)

# Output selected locations
selected_locations = findall(x .> 0.5)
println("Selected Housing Locations:")
for k in selected_locations
    println("Location $k: (latitude = ", S[k, 1], ", longitude = ", S[k, 2], ")")
end

# Print the objective value
println("Objective Value: ", objective_value(model))
