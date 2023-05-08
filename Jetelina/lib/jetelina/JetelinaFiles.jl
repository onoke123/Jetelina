module JetelinaFiles

export getFileNameFromConfigPath,getJsFileNameFromPublicPath,getFileNameFromLogPath

function getFileNameFromConfigPath( fname )
    return string( joinpath( @__DIR__, "config", fname ))
end

function getJsFileNameFromPublicPath( fname )
    return string(joinpath(@__DIR__, "..", "..", "public", "jetelina", "js", fname))
end

function getFileNameFromLogPath( fname )
    return string( joinpath( @__DIR__, "log", fname ) )
end

end