#const arr = []
using DataFrames, CSV

const d_const = Ref{}
function set()
#    push!( arr, "first" )
#    @info "after push: ", arr
    df2 = CSV.read("lib/jetelina/test_sample_deprecated/ftest2.csv",DataFrame)
    d_const = Ref(df2)
    @info "df2 -> d_const is " d_const
    df3 = CSV.read("lib/jetelina/test_sample_deprecated/ftest3.csv",DataFrame)
    d_const = Ref(df3)
    @info "df3 -> d_const is " d_const
end