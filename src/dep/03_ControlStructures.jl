#############################
# Control structures
#############################

# Conditionals

x = 1
y = 1

if x < y
    println("x is less than y")
elseif x > y
    println("x is greater than y")
else
    println("x is equal to y")
end

x < y ? println("x is less than y") : println("x is not less than y")

x < y && println("x is smaller than y")
x > y || println("x is not greater than y")

x < y && (z = x)

# Loops

for i in 1:5
        println(i)
end

for i in 1:0.1:5
        println(i)
end

a = [1, 2, 3]
for i in a
        println(i)
end

for i ∈ 1:5
        println(i)
end

for i = 1:5
        println(i)
end

for i = 1:2, j = 3:4
        println((i, j))
end

for i = 1:2, j = 3:4
        println((i, j))
        if condition break
end

for i = 1:2, j = 3:4
        if condition continue
        println((i, j))
end

function slow(n)
    A = Matrix{Float64}(undef, n, n)
    for i = 1:n, j = 1:n
        A[i, j] = rand()
    end
    return A
end
function fast(n)
    A = Matrix{Float64}(undef, n, n)
    for i = 1:n, j = 1:n
        A[j, i] = rand()
    end
    return A
end

function fast2(n)
    A = Matrix{Float64}(undef, n, n)
    for idx in CartesianIndices(A)
        (r, c) = Tuple(idx)
        println("r = ", r, "; c = ", c)
        A[r, c] = rand()
    end
    return A
end



# Comprenhensions
[n^2 for n in 1:5]      # basic comprehensions
Float64[n^2 for n in 1:5]   # comprehension fixing type
[x+y for x in 1:3, y = 1:4]

# Generators
sum(1/n^2 for n=1:1000)

i = 0
while i <= 5
        println(i)
    i += 1
end
