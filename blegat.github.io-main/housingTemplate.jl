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
# where t_i denotes the type of the ith amenity, and (x_i, y_i) the location.
# We wish to select M of the N facility locations to become housing locations, in such a way that each housing location has optimized access to at least one amenity of each type. 
selected = M
# The weights for each amenity type are:
D = [w_1 w_2 ... w_p]


model = Model(HiGHS.Optimizer)
@variable(model, x[a in 1:length(S[1,:])],Bin) # array describing which locations have been chosen, 1 for chosen and 0 for unselected

@constraint(model, sum(x)==selected) # ensuring M locations are selected

@expression(model, c[house = 1:length(x), type = 1:P], minimum(abs(S[1,house]-A[type][1,ind ]) + abs(S[2,house]-A[type][2,ind]) for ind in 1:length(A[type][1]))) # this monster determines the shortest taxicab distance from a given house location to the nearest amenity of a given type. 

@objective(model, Min, sum(D[t]*sum(c[k,t]*x[k] for k in 1:length(x)) for t in 1:P)) # we use the SAW method to combine all the distances with given preference weightings to form an objective function. The inner sum is equal to the sum of the distances from each selected location to its nearest amenity of a given type t. The outer sum iterates the inner sum over all amenity types, and multiplies each inner sum by the appropriate weight w_t.

optimize!(model)

solution_summary(model)

num_variables(model)


