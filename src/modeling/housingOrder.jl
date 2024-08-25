using JuMP
using HiGHS
using DataFrames
using CSV

# Load the user-defined weights from user_weights.csv
weights_df = DataFrame(CSV.File("data/processed/user_weights.csv"))

# Convert the weights to a dictionary for easier access
weights_dict = Dict(row.amenity => row.weight for row in eachrow(weights_df))

# Define the list of amenities in the correct order
amenity_names = [
    "grocery_stores", "retail_centers", "public_schools", "private_schools", 
    "public_libraries", "hospitals", "parks", "sports_facilities", 
    "community_centers", "public_transit", "major_roadways", "bike_lanes", 
    "restaurants_cafes", "cultural_institutions", "places_of_worship", 
    "police_stations", "fire_stations", "childcare_facilities", 
    "employment_centers", "senior_services"
]

# Extract the weights, skipping any missing amenities
D = [get(weights_dict, amenity, 0.0) for amenity in amenity_names]

# Print current directory and available files for debugging
println("Current directory: ", pwd())
println("Files in data/processed: ", readdir("data/processed/"))

# Load housing data from rental and sale CSV files
housing_rental_data = DataFrame(CSV.File("data/processed/housing_rental.csv"))
housing_sale_data = DataFrame(CSV.File("data/processed/housing_sale.csv"))

# Combine rental and sale data into one DataFrame
housing_data = vcat(housing_rental_data, housing_sale_data)

# Extract relevant housing information
S = [housing_data.latitude housing_data.longitude]
addresses = housing_data.address
prices = housing_data.price
sqft = housing_data.area
beds = housing_data.beds
baths = housing_data.baths  

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

# Load all amenities into a list of DataFrames, skipping empty files
amenities = []
for file in amenity_files
    df = DataFrame(CSV.File(file))
    if nrow(df) > 0 && (:latitude in names(df)) && (:longitude in names(df))
        push!(amenities, [df.latitude df.longitude])
    else
        push!(amenities, [zeros(0, 2)])  # Add an empty array if no amenities are found
    end
end

# Create the optimization model
model = Model(HiGHS.Optimizer)

# Define binary variables to select the top N locations
M = 10  # Number of locations to be selected
@variable(model, x[1:size(S, 1)], Bin)  # 1 if the location is selected, 0 otherwise

# Ensure exactly M locations are selected
@constraint(model, sum(x) == M)

# Expression to calculate the shortest Taxicab distance from each house to the nearest amenity of each type
@expression(model, c[house=1:size(S, 1), type=1:length(A)], 
    size(A[type], 1) > 0 ? minimum(
        abs(S[house, 1] - A[type][ind, 1]) + abs(S[house, 2] - A[type][ind, 2])  # Taxicab distance
        for ind in 1:size(A[type], 1)
    ) : 1e6  # Large value if no amenities of this type are present
)

# Objective: Maximize user satisfaction based on proximity to preferred amenities
@objective(model, Max, sum(D[t] * sum((1 / (c[k, t] + 1e-5)) * x[k] for k in 1:size(S, 1)) for t in 1:length(A)))

# Optimize the model
optimize!(model)

# Extract selected locations using the JuMP function `value.`
selected_locations = [k for k in 1:size(S, 1) if value(x[k]) > 0.5]

# Output selected locations
println("Selected Housing Locations:")
for k in selected_locations
    println("Address: ", addresses[k])
    println("Price: ", prices[k])
    println("Sq Ft: ", sqft[k])
    println("Beds: ", beds[k])
    println("Baths: ", baths[k])
    println("----------")
end

# Print the objective value
println("Objective Value: ", objective_value(model))
