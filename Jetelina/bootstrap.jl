(pwd() != @__DIR__) && cd(@__DIR__) # allow starting app from bin/ dir

using Jetelina
push!(Base.modules_warned_for, Base.PkgId(Jetelina))
Jetelina.main()
