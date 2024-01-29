f = open(string(joinpath(@__DIR__,"testconfig.config")))
l = readlines(f)

for i = 1:size(l)[1]
    println( l[i] )
end
