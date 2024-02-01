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
    fileBackup(fname::String) back up the ordered file with date suffix. ex. <file>.txt -> <file>.txt.yyyymmdd-HHMMSS
"""
module JetelinaFiles
#    using JetelinaLog
    
    export getFileNameFromConfigPath,getJsFileNameFromPublicPath,getFileNameFromLogPath,fileBackup

    """
    function getFileNameFromConfigPath(fname)

        get full path of Jetelina Configuration files 

    # Arguments
    - `fname: String`: target file name. expect String type, but not limited to that.
    - return: full path of the tartget name. this path is under Genie zone.
    """
    function getFileNameFromConfigPath(fname)
        fn = string( joinpath( @__DIR__, "config", fname ))
        if !isfile(fn)
            fn ="JetelinaFiles.getFileNameFromConfigPath: $fn does not exist"
        end

        return fn            
    end
    """
    function getJsFileNameFromPublicPath(fname)

        get full path of Jetelina public files

    # Arguments
    - `fname: String`: target file name. expect String type, but not limited to that.
    - return: full path of the tartget name. this path is under Genie zone.
    """
    function getJsFileNameFromPublicPath(fname)
        fn = string(joinpath(@__DIR__, "..", "..", "public", "jetelina", "js", fname))
        if !isfile(fn)
            fn = "JetelinaFiles.getJsFileNameFromPublicPath: $fn does not exist"
        end

        return fn            
    end
    """
    function getJsFileNameFromPublicPath(fname)

        get full path of Jetelina log files

    # Arguments
    - `fname: String`: target file name. expect String type, but not limited to that.
    - return: full path of the tartget name. this path is under Genie zone.
    """
    function getFileNameFromLogPath(fname)
        fn = string( joinpath( @__DIR__, "log", fname ) )
        if !isfile(fn)
            fn = "JetelinaFiles.getFileNameFromLogPath: $fn does not exist"
        end

        return fn            
    end
    """
    function fileBackup(fname::String)

        back up the ordered file with date suffix. ex. <file>.txt -> <file>.txt.yyyymmdd-HHMMSS

    # Arguments
    - `fname::String`: target file name
    """
    function fileBackup(fname::String)
        backupfilesuffix = Dates.format(now(), "yyyymmdd-HHMMSS")
        cp(fname, string(fname, backupfilesuffix), force=true)
    end

end