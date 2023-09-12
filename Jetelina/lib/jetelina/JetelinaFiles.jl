"""
module: JetelinaFiles

Author: Ono keiji
Version: 1.0
Description:
    determaine the path of Jetelina files

functions
    getFileNameFromConfigPath(fname)  get full path of Jetelina Configuration files
    getJsFileNameFromPublicPath(fname)  get full path of Jetelina public files
    getFileNameFromLogPath(fname)  get full path of Jetelina log files
"""
module JetelinaFiles

    export getFileNameFromConfigPath,getJsFileNameFromPublicPath,getFileNameFromLogPath

    """
    function getFileNameFromConfigPath(fname)

        get full path of Jetelina Configuration files 

    # Arguments
    - `fname: String`: target file name. expect String type, but not limited to that.
    - return: full path of the tartget name. this path is under Genie zone.
    """
    function getFileNameFromConfigPath(fname)
        return string( joinpath( @__DIR__, "config", fname ))
    end
    """
    function getJsFileNameFromPublicPath(fname)

        get full path of Jetelina public files

    # Arguments
    - `fname: String`: target file name. expect String type, but not limited to that.
    - return: full path of the tartget name. this path is under Genie zone.
    """
    function getJsFileNameFromPublicPath(fname)
        return string(joinpath(@__DIR__, "..", "..", "public", "jetelina", "js", fname))
    end
    """
    function getJsFileNameFromPublicPath(fname)

        get full path of Jetelina log files

    # Arguments
    - `fname: String`: target file name. expect String type, but not limited to that.
    - return: full path of the tartget name. this path is under Genie zone.
    """
    function getFileNameFromLogPath(fname)
        return string( joinpath( @__DIR__, "log", fname ) )
    end

end