Optimizing Home Selection: Integrating Lifestyle Presets and Real-Life Commute Time into Spatial Decision Support Systems
A CCIR Research Project

Overview
--------------------------------------------------------------------------------------------------
This project aims to optimize the home selection process by integrating lifestyle presets and real-life commute time into Spatial Decision Support Systems (SDSS). By combining Multi-Criteria Decision Analysis (MCDA) with personalized user preferences, the system provides a more accurate and tailored experience for potential home buyers.

The coding component integrates Julia for optimization modeling using JuMP and Python for data retrieval, processing, and user input. The model is intended to identify optimal housing locations by evaluating proximity to various amenities according to user-defined preferences.

Considerations:
--------------------------------------------------------------------------------------------------
1. Focus on Proximity Spatial Criteria:

The model exclusively considers proximity spatial criteria, ignoring location and direction criteria. This decision simplifies the evaluation process, making it more straightforward to assess the desirability of housing locations based on proximity alone.

2. Use of Taxicab Distance:

Instead of Euclidean distances, the model uses taxicab distances to better reflect real-world accessibility, as this aligns with the grid-like patterns of streets and transit routes.

3. Introduction of Lifestyles to Simplify User Input:

To simplify the process of selecting and weighting multiple amenities, we introduced the concept of lifestyles. Lifestyles are predefined groups of amenities that reflect common preferences, such as Healthy Living or Family-Oriented. This approach allows users to quickly select a lifestyle that aligns with their preferences, and the model automatically assigns weights to relevant amenities. However, users still have the ability to adjust the weights of individual amenities, giving them control over fine-tuning their preferences.


Setup:
--------------------------------------------------------------------------------------------------
1. Clone the Repository
    git clone <your_own_repository_url>
    cd CCIR-folder

2. Set Up Python Environment
    python3 -m venv env
    source env/bin/activate
    pip install -r requirements.txt

3. Install Streamlit for interactive UI
    pip install streamlit

4. Set Up Julia Environment
    using Pkg
    Pkg.add(["JuMP", "HiGHS", "DataFrames", "CSV"])


Running:
--------------------------------------------------------------------------------------------------
1. Data Retrieval (Python)
    Open notebooks/data_retrieval.ipynb and notebooks/housing_retrieval.ipynb in Jupyter.
    These notebooks retrieve relevant data from Google Maps APIs and save it to data/processed/.
    
2. User Input (Streamlit)
    Run the Streamlit App
        streamlit run src/ui/app.py

    This app allows users to specify their lifestyle preferences, which are used to generate weights for each amenity. Preferences are saved in data/processed/user_weights.csv.

3. Optimization Model (Julia)
    Execute src/modeling/housingOrder.jl to identify the optimal housing locations. The model outputs a list of the top N housing locations based on the user’s preferences.


Further Improvements:
--------------------------------------------------------------------------------------------------
1. Real Distance and Commute Time
    We may improve the model by incorporating real distances and commute times from Google Maps API to replace taxicab distances with these more realistic measures.

2. Advanced Topological Modeling
    We will implement topological features such as streets, housing, and amenities using custom Google Maps. With modeling these features as lines, points, or areas, we can further enhance spatial analysis.

3. User Interface Enhancements
    We will expand the Streamlit app to include map visualizations and allow users to compare different scenarios with more detailed user interaction options.