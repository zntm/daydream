function program_get_version()
{
    static __version_type = [
        "Alpha",
        "Beta",
        "Release"
    ];
    
    if (PROGRAM_VERSION_PATCH > 0)
    {
        if (IS_DEVELOPER_MODE)
        {
            return $"{__version_type[PROGRAM_VERSION_TYPE]} {PROGRAM_VERSION_MAJOR}.{PROGRAM_VERSION_MINOR}.{PROGRAM_VERSION_PATCH}-dev";
        }
        
        return $"{__version_type[PROGRAM_VERSION_TYPE]} {PROGRAM_VERSION_MAJOR}.{PROGRAM_VERSION_MINOR}.{PROGRAM_VERSION_PATCH}";
    }
    
    if (IS_DEVELOPER_MODE)
    {
        return $"{__version_type[PROGRAM_VERSION_TYPE]} {PROGRAM_VERSION_MAJOR}.{PROGRAM_VERSION_MINOR}-dev";
    }
    
    return $"{__version_type[PROGRAM_VERSION_TYPE]} {PROGRAM_VERSION_MAJOR}.{PROGRAM_VERSION_MINOR}";
}