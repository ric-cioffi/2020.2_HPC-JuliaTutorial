#############################
# Types (basics)
#############################

# Define a new type
struct NewType end

# Define a new concrete subtype of number
struct NewNumber <: Number end

# Define a composite type
struct Dual
    value::Float64
    deriv::Float64
end

x = Dual(3, 4) # uses automatic conversion (promotion)
y = Dual(5, 6)

x + y # error
add(x::Dual, y::Dual) = Dual(x.value + y.value, x.deriv + y.deriv)
add(x, y)

import Base: +, *

+(x::Dual, y::Dual) = add(x, y)
*(x::Dual, y::Dual) = Dual(x.value*y.value, x.value*y.deriv + x.deriv*y.value)

# We now have enough to be able to differentiate simple Julia functions involving only + and *

a = 3.0
xx = Dual(a, 1.0) # the identity function x -> x, with derivative 1

xx + xx
xx * xx
xx * xx + xx # the function x -> x^2 + x, with derivative 2x + 1

ff(x) = x*x*x + x*x + x*x # x^3 + 2x^2
ff(xx)
ff(a)
dff(x) = 3x^2 + 4x
dff(a)

#############################
# Type stability and parametric types

# Type stable (but non-generic)
struct StrictAffine
    a::Float64
    b::Float64
end

(l::StrictAffine)(x::Float64) = l.a*x + l.b # type restriction on the function is non-necessary
iden = StrictAffine(1.0, 0.0)
iden(3.0) # returns 3.0
@code_warntype iden(3.0)

# Generic (but type-instable)
struct GenericAffine
    a::Real
    b::Real
end

(l::GenericAffine)(x) = l.a*x + l.b
gen_iden = GenericAffine(1, 0)
gen_iden(3)
@code_warntype gen_iden(3)

# Generic and type stable
struct ParametricAffine{T1, T2}
    a::T1
    b::T2
end

(l::ParametricAffine)(x) = l.a*x + l.b
par_iden = ParametricAffine(1, 0)
par_iden(3)
@code_warntype par_iden(3)

using BenchmarkTools
@btime iden(3.0)
@btime gen_iden(3)
@btime par_iden(3)


# However, you might want to restrict the parameters
par_wrong = ParametricAffine("hello", 0)
par_wrong(3)

# Can also restrict type parameters (even better)
struct RealAffine{T1 <: Real, T2 <: Real}
    a::T1
    b::T2
end

(l::RealAffine)(x) = l.a*x + l.b
real_iden = RealAffine(1//1, 0)
RealAffine("a", 0) # gives error
real_iden(3)
@code_warntype real_iden(3)

#############################
# Type hierarchy and function compositions

#=
Note: One particularly distinctive feature of Julia’s type system is that concrete types may not subtype each other: 
all concrete types are final and may only have abstract types as their supertypes.
=#

abstract type Equation end
abstract type Polynomial <: Equation end
struct NewOne <: Equation end

struct Order0{T <: Real} <: Polynomial
    a0::T   # We parameterize Order0 by the type of a0
end
(eq::Order0)(x) = eq.a0     # Make every instance of type Order0 callable

# Parametric types:
a = Order0(1)               # an instance of type Order0{Int64}
typeof(a)
b = Order0(1.0)
typeof(b)                   # an instance of type Order0{Float64}
typeof(a) != typeof(b)      # a and b are both of type Order0 but they are not of the same type
typeof(a) <: Order0         # Order0{Int64} is both of type Order0 and a subtype of Order0
supertype(typeof(a))        # Order0{Int64} is a direct subtype of Polynomial

c = Order0(4 + 3im)         # Error: cannot create a instance of Order0{Complex} because we restricted T to be a subtype of real

a(rand()) == 1


struct Order1{T0, T1} <: Polynomial
    a0::T0
    a1::T1

    # The inner constructor replaces the default constructor
    function Order1(a0::T0, a1::T1) where {T0 <: Real, T1 <: Real}
        if a1 == 0
            return Order0(a0)
        else
            return new{T0, T1}(a0, a1) # create a new instance
        end
    end
end
(eq::Order1)(x) = eq.a0 + eq.a1*x

a = Order1(2, 1.0)          # an instance of Order1
b = Order1(2.0, 0)          # this is now an instance of Order0 (because a1 == 0)

a(3) == 5

struct Order2{T0, T1, T2} <: Polynomial
    a0::T0
    a1::T1
    a2::T2
    function Order2(a0::T0, a1::T1, a2::T2) where {T0 <: Real, T1 <: Real, T2 <: Real}
        if a2 == 0
            return Order1(a0, a1)
        else
            return new{T0, T1, T2}(a0, a1, a2)
        end
    end
end
(eq::Order2)(x) = eq.a0 + eq.a1*x + eq.a2*x^2

# Note: the constructors will not be type stable (it depends on the VALUE of a1, not on its type), but it will not matter
@code_warntype Order1(1, 1) 

myparabola = Order2(1, 2, 3) # the function x -> 3x^2 + 2x + 1, with derivative 6x + 2
iden = Order2(0, 1, 0) # same as Order1(0, 1)

# Now it becomes interesting
derivative(eq::Order2) = Order1(eq.a1, 2*eq.a2)
derivative(eq::Order1) = Order0(eq.a1)
derivative(eq::Order0) = Order0(0)

derivative(myparabola)
derivative(derivative(myparabola))

# Function composition
secondderivative = derivative ∘ derivative
secondderivative(myparabola)

# Piping 
myparabola |> derivative |> derivative

derivative(myparabola)(3)
secondderivative(myparabola)(3)

function nth_derivative(n::Integer) 
    if n == 0
        return (x) -> x
    else
        return nth_derivative(n - 1) ∘ derivative
    end
end

nth_derivative(0)(myparabola)(3)
nth_derivative(1)(myparabola)(3//1)
nth_derivative(2)(myparabola)(3)
nth_derivative(3)(myparabola)(3)
nth_derivative(4)(myparabola)(3)

@code_warntype nth_derivative(2)(myparabola)(3) # as we said, it didn't matter

# Type-instability WOULD matter here instead:
struct Order0{T} <: Polynomial
    a0::T
    f::Function
    Order0(a0::T) where {T <: Real} = new{T}(a0, (x) -> a0)
end
(eq::Order0)(x) = eq.f(x)
@code_warntype nth_derivative(2)(myparabola)(3)

#############################
# Advanced topics

# Type stability is not all that matters, recursion usually badly scales up

@btime nth_derivative(0)($myparabola)(3)
@btime nth_derivative(2)($myparabola)(3)
@btime nth_derivative(4)($myparabola)(3)
@btime nth_derivative(8)($myparabola)(3)

@generated function nth_generated(::Type{Val{n}}) where {n}
    if n == 0
        return (x) -> x
    else
        return nth_generated(Val{n-1}) ∘ derivative 
    end
end
nth_generated(n::Integer) = nth_generated(Val{n})

@btime nth_generated(0)($myparabola)(3)
@btime nth_generated(4)($myparabola)(3)
@btime nth_generated(8)($myparabola)(3)

# Could have done this using metaprogramming

#############################
# Types (constructors and methods) and Named Tuples
#############################

struct MicroSurveyObservation
    id::Int64
    year::Int64
    quarter::Int64
    region::String
    ageHouseholdHead::Int64
    familySize::Int64
    numberChildrenunder18::Int64
    consumption::Float64
end

household1 = MicroSurveyObservation(12,2017,3,"angushire",23,2,0,345.34)

fieldnames(MicroSurveyObservation)

household1.familySize
totalPopulation = household1.familySize
household1.id = 31 # it will give you an error

# Mutable
mutable struct MutableMicroSurveyObservation
    id::Int64
    year::Int64
    quarter::Int64
    region::String
    ageHouseholdHead::Int64
    familySize::Int64
    numberChildrenunder18::Int64
    consumption::Float64
end

household1 = MutableMicroSurveyObservation(12,2017,3,"angushire",23,2,0,345.34)
household1.id = 31

function EquivalenceScale(x::MicroSurveyObservation)
    if x.familySize == 1
      return x.consumption
    else
      return x.consumption/(1+0.5*(x.familySize-1))
    end
end

household1 = MicroSurveyObservation(12,2017,3,"angushire",23,2,0,345.34)
EquivalenceScale(household1)

function AverageConsumption(x::MicroSurveyObservation,y::MicroSurveyObservation)
    return 0.5*(x.consumption+y.consumption)
end

import Base: +
+(x::MicroSurveyObservation,y::MicroSurveyObservation) = x.consumption + y.consumption

household1 = MicroSurveyObservation(12,2017,3,"angushire",23,2,0,345.34)
household2 = MicroSurveyObservation(13,2015,2,"Wolpex",35,5,2,645.34)

household = Vector{MicroSurveyObservation}(undef, 10)
household[1] = MicroSurveyObservation(12,2017,3,"angushire", 23, 2,0,345.34)
household[2] = MicroSurveyObservation(13,2015,2,"Wolpex", 35, 5,2,645.34)

for i in 1:10
    # read file with observation
    household[i] = MicroSurveyObservation(#data from previous step)
end

household1 = (id = 12,
              year = 2017,
              quarter = 3,
              region = "angushire",
              ageHouseholdHead = 23,
              familySize = 2,
              numberChildrenunder18 = 0,
              consumption = 345.34)

using DataFrames, Statistics
microSurveyObservations = DataFrame(;household1...) #Creating with named tuple
household2 = (  id = 15,
                year = 2017,
                quarter = 3,
                region = "angushire",
                ageHouseholdHead = 26,
                familySize = 2,
                numberChildrenunder18 = 0,
                consumption = 1345.34)
push!(microSurveyObservations, household2) #Push named tuples onto the dataframe
mean(microSurveyObservations[:consumption]) #Statistics.

#############################
# Dictionaries
#############################

# Creating a dictionary
a = Dict("University of Pennsylvania" => "Philadelphia", "Boston College" => "Boston")
a["University of Pennsylvania"]     # access one key
a["Harvard"] = "Cambridge"  # adds an additional key
delete!(a,"Harvard")    # deletes a key
keys(a)
values(a)
haskey(a,"University of Pennsylvania")  # returns true
haskey(a,"MIT") # returns false