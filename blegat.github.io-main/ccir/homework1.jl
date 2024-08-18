
using CSV
using DataFrames

df = DataFrame(CSV.File("C:/Users/rlime/OneDrive/Documents/CCIR folder/archive/Life Expectancy Data.csv", normalizenames=true))


using Plots
using LinearAlgebra
using Statistics

new_df = dropmissing(df)
new_df = new_df[new_df.Year .== 2012, :]


features = names(df)

for feature in features
    if feature != "Country" && feature != "Year" && feature != "Status"   
        y = new_df.Life_expectancy
        A = new_df[:, feature]
        fig = plot()
        
        scatter!(A, y, label="Data")
        new_A = hcat(A, ones(length(A)))
        coefs = new_A\y
        
        y_hat = coefs[1].*A .+ coefs[2]
        pear = cor(y, y_hat)
        if pear>0.65
            x_plot = range(minimum(A), maximum(A), 100)
            y_plot = coefs[1]*x_plot .+ coefs[2]
            label = string(coefs[1], "*x + ", coefs[2])
            xlabel = feature
            ylabel = "Life expectancy"
        
            display("Regression line: $(label)")

        
            println(feature)
            display("R = $(cor(y, y_hat))")
            plot!(x_plot, y_plot, label=label, xlabel=xlabel, ylabel=ylabel)
            display(fig)
            println()
        end
    end
end

# Data
y = new_df.Life_expectancy

# A is the key to go from single to multiple linear regression !
A = hcat(new_df.Adult_Mortality, new_df.Schooling, ones(size(new_df, 1)))

# Solve the system Ax=y to find x, i.e., the coefficients of the linear regression model
coefs = A\y # Cannot handle missing values

println("Regression line: $(coefs[1])*x1 + $(coefs[2])*x2 + $(coefs[3])")

# Use the regression model to predict Life_expectancy from Adult_Mortality and Schooling
y_hat = coefs[1].*new_df.Adult_Mortality + coefs[2].*new_df.Schooling .+ coefs[3]

# Compute correlation coefficient
println("R = $(cor(y, y_hat))")