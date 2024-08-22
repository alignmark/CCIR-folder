using JuMP
using HiGHS
# Let there be N possible facility locations, numbered from 1 to N, on a plane described by Cartesian coordinates. Let these be:
S = [x_1 x_2 x_3 ... x_N;
     y_1 y_2 y_3 ... y_N]
# where (x_i, y_i) describes the location of the ith facility.
# Let there be K separate locations for amenities, numbered 1 to K, of which there are P types, numbered 1 to P. Let the set of all amenities be:
A = [t_1 t_2 t_3 ... t_P]
# where each t_i is the 2d array of the coordinates of all the amenities of the ith type:
t_i = [x_1 x_2 x_3 ... ;
       y_1 y_2 y_3 ... ]
P = length(A)
#(x_i, y_i) is the location of the ith amenity of the type.
# We wish to rank the facility locations from most suitable to least suitable given the preferences of a person, characterized by amenity weights:
# The weights for each amenity type are:
D = [w_1 w_2 ... w_p]



model = Model(HiGHS.Optimizer)
@variable(model, x[com in 1:length(S[1,:]), place in 1:length(S[1,:])],Bin) # array describing the ranking of each location.

@constraint(model, [com in 1:length(S[1,:])], sum(x[com,:])==1) # ensuring each location has 1 ranking
@constraint(model, [place in 1:length(S[1,:])], sum(x[:,place]==1)) # ensuring each ranking has one location.

@expression(model, c[house = 1:length(x), type = 1:P], minimum(abs(S[1,house]-A[type][1,ind ]) + abs(S[2,house]-A[type][2,ind]) for ind in 1:length(A[type][1]))) # this monster determines the shortest taxicab distance from a given location to the nearest amenity of a given type. 

for place in 1:(length(S[1,:])-1)
    for com1 in 1:length(S[1,:])
        if x[com1,place]==1
            for com2 in 1:length(S[1,:])
                if x[com2,place+1]==1
                    @constraint(model, sum(c[com1,t]*D[t] for t in 1:P)>=sum(c[com2,t]*D[t] for t in 1:P)) # searches for two locations whose rankings differ by 1 and verifies that the location of higher ranking has a better evaluation score than that of the lower ranking location. 
                end
            end
        end
    end
end

optimize!(model)

solution_summary(model)

num_variables(model)
