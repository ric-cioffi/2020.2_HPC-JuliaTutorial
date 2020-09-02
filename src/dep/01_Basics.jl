https://julialang.org/

https://julialang.org/downloads/

http://junolab.org/

https://juliacomputing.com/

https://www.youtube.com/user/JuliaLanguage/videos



https://lectures.quantecon.org/jl/


# How to use julia
REPL/Shell
julia mycode.jl         # run as a script
include("mycode.jl")    # run as a script
juno/juliapro
jupyter https://jupyter.org/, see IJulia below

versioninfo() # more information

arrow up and down
# This is a comment
#= This is another comment =#

? # switches to help mode
cos # help on cosene

autocompletion
; shell commands
ctrl+L # cleans consol, also clearconsole()
exit()

\alpha (+ press Tab)
\int (+ press Tab)
\:whale: (+ press Tab)
\:pizza: (+ press Tab)
\:hamburger: (+ press Tab)
🍕>🍔


# Here is where unicode is supercool
∑(x,y) = x + y
∑(1,2)

ans # can use as any other variable
ans; # suppress output
ans+1

pi (+ press Tab)            # returns 3.14...
ℯ
Base.MathConstants.golden

println(ans)
println("I like economics")
println("""I like economics "with" quotes""")

] # for package manager
ctrl+C # to exit

st # status of packages

add PyPlot

up PyPlot # update PyPlot
rm PyPlot # remove package
update    # updates all packages
using Pyplot

List of packages
https://pkg.julialang.org/

# Some suggested packages
Printf        # Why in this way? Two reasons
Gadfly        # ggplot2-like plotting
Pandas
PyCall
TensorFlow
DifferentialEquations
JuMP
StatsBase
ForwardDiff
DataFrames    # linear/logistic regression
Distributions # Statistical distributions
Flux          # Machine learning
LightGraphs   # Network analysis
TextAnalysis  # NLP
ODBC

# Some very useful packages
Revise
BenchmarkTools
Debugger\Rebugger
Traceur
StaticArrays
Profile\ProfileView
TimerOutputs

using IJulia

notebook() # Jupyter
using PyPlot
x = range(0,stop=5,length=101)
y = cos.(2x .+ 5)
plot(x, y, linewidth=2.0, linestyle="--")
title("a nice cosinus")
xlabel("x axis")
ylabel("y axis")

ctrl+C # to exit

a = time()
b = time()-a

@btime # from BenchmarkTools

The LLVM

code_llvm(sqrt, (Int64,))