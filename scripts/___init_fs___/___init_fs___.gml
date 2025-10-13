#macro PROGRAM_DIRECTORY_RESOURCES ((GM_build_type == "run") ? $"{filename_dir(GM_project_filename)}/datafiles/resources" : "resources")
#macro PROGRAM_DIRECTORY_DATA      ((GM_build_type == "run") ? $"{filename_dir(GM_project_filename)}/datafiles/data" : "data")

#macro PROGRAM_DIRECTORY_APPDATA $"{environment_get_variable("LOCALAPPDATA")}/{PROGRAM_NAME}"

#macro PROGRAM_DIRECTORY_CRASH_LOG   $"{PROGRAM_DIRECTORY_APPDATA}/crash_log"
#macro PROGRAM_DIRECTORY_PLAYERS     $"{PROGRAM_DIRECTORY_APPDATA}/players"
#macro PROGRAM_DIRECTORY_SCREENSHOTS $"{PROGRAM_DIRECTORY_APPDATA}/screenshots"
#macro PROGRAM_DIRECTORY_STRUCTURES  $"{PROGRAM_DIRECTORY_APPDATA}/structures"
#macro PROGRAM_DIRECTORY_WORLDS      $"{PROGRAM_DIRECTORY_APPDATA}/worlds"

if (!directory_exists(PROGRAM_DIRECTORY_CRASH_LOG))
{
    directory_create(PROGRAM_DIRECTORY_CRASH_LOG);
}

if (!directory_exists(PROGRAM_DIRECTORY_PLAYERS))
{
    directory_create(PROGRAM_DIRECTORY_PLAYERS);
}

if (!directory_exists(PROGRAM_DIRECTORY_SCREENSHOTS))
{
    directory_create(PROGRAM_DIRECTORY_SCREENSHOTS);
}

if (!directory_exists(PROGRAM_DIRECTORY_STRUCTURES))
{
    directory_create(PROGRAM_DIRECTORY_STRUCTURES);
}

if (!directory_exists(PROGRAM_DIRECTORY_WORLDS))
{
    directory_create(PROGRAM_DIRECTORY_WORLDS);
}