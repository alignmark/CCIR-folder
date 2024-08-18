using JuMP
using HiGHS

init_sol = [
    5 3 0 0 7 0 0 0 0
    6 0 0 1 9 5 0 0 0
    0 9 8 0 0 0 0 6 0
    8 0 0 0 6 0 0 0 3
    4 0 0 8 0 3 0 0 1
    7 0 0 0 2 0 0 0 6
    0 6 0 0 0 0 2 8 0
    0 0 0 4 1 9 0 0 5
    0 0 0 0 8 0 0 7 9
]



model = Model(HiGHS.Optimizer)
@variable(model, x[row in 1:9, col in 1:9, num in 1:9], Bin)

for row in 1:9
    for col in 1:9
        if init_sol[row,col] != 0
            for num in 1:9
                if num == init_sol[row,col]
                    fix(x[row,col,num], 1, force=true)
                else 
                    fix(x[row,col,num], 0, force=true)
                end
            end
        end
    end
end

@constraint(model, [row in 1:9, col in 1:9], sum(x[row,col,:])==1)
@constraint(model, [row in 1:9, num in 1:9], sum(x[row,:,num])==1)
@constraint(model, [col in 1:9, num in 1:9], sum(x[:,col,num])==1)

@constraint(model, [num in 1:9], sum(x[1:3,1:3,num])==1)
@constraint(model, [num in 1:9], sum(x[1:3,4:6,num])==1)
@constraint(model, [num in 1:9], sum(x[1:3,7:9,num])==1)

@constraint(model, [num in 1:9], sum(x[4:6,1:3,num])==1)
@constraint(model, [num in 1:9], sum(x[4:6,4:6,num])==1)
@constraint(model, [num in 1:9], sum(x[4:6,7:9,num])==1)

@constraint(model, [num in 1:9], sum(x[7:9,1:3,num])==1)
@constraint(model, [num in 1:9], sum(x[7:9,4:6,num])==1)
@constraint(model, [num in 1:9], sum(x[7:9,7:9,num])==1)


optimize!(model)

solution_summary(model)

num_variables(model)

function extract(x)
    nums = zeros(Int, 9, 9)
    for col in 1:9
        for row in 1:9
            for num in 1:9
                if x[row, col, num] > 0.5
                    if nums[row, col] != 0
                        error("Cell ($row, $col) cannot be both $(nums[row, col]) and $num")
                    end
                    nums[row, col] = num
                end
            end
        end
    end
    return nums
end

extract(value.(x))