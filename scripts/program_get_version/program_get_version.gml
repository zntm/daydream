function program_get_version()
{
    static __version_type = [
        "Alpha",
        "Beta",
        "Release"
    ];
    
    if (PROGRAM_VERSION_PATCH > 0)
    {
        return $"{__version_type[PROGRAM_VERSION_TYPE]} {PROGRAM_VERSION_MAJOR}.{PROGRAM_VERSION_MINOR}.{PROGRAM_VERSION_PATCH}";
    }
    
    return $"{__version_type[PROGRAM_VERSION_TYPE]} {PROGRAM_VERSION_MAJOR}.{PROGRAM_VERSION_MINOR}";
}