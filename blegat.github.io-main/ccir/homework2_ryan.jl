
using JuMP
using HiGHS

table = [0.18 107 72 10
         0.23 500 121 10
         0.05 0 65 10]
C1 = [2000,2250]
C2 = [5000,50000]

println(table)

model = Model(HiGHS.Optimizer)

@variable(model, a>=0)
@variable(model, b>=0)
@variable(model, c>=0)

@objective(model, Min, a*table[1] + b*table[2] + c*table[3])

@constraint(model, a<=table[10])
@constraint(model, b<=table[11])
@constraint(model, c<=table[12])

@constraint(model, c1min, a*table[4] + b*table[5] + c*table[6]>=C1[1])
@constraint(model, c1max, a*table[4] + b*table[5] + c*table[6]<=C1[2])
@constraint(model, c2min, a*table[7] + b*table[8] + c*table[9]>=C2[1])
@constraint(model, c2max, a*table[7] + b*table[8] + c*table[9]<=C2[2])



optimize!(model)

@show value(a)
@show value(b);
