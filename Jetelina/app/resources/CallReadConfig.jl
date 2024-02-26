module CallReadConfig
    using Jetelina.JMessage
    
    JMessage.showModuleInCompiling(@__MODULE__)
    
    include("ReadConfig.jl")
end