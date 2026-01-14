enum VERISON_TYPE {
    ALPHA,
    BETA,
    RELEASE
}

#macro IS_DEVELOPER_MODE 1

#macro IS_LOOM_ENABLED 1
#macro IS_MULTIPLAYER_ENABLED 1

#macro PROGRAM_VERSION_MAJOR current_year
#macro PROGRAM_VERSION_MINOR 0
#macro PROGRAM_VERSION_PATCH 0
#macro PROGRAM_VERSION_TYPE VERISON_TYPE.ALPHA
#macro PROGRAM_VERSION_NUMBER (PROGRAM_VERSION_MAJOR << 16) | (PROGRAM_VERSION_MINOR << 8) | (PROGRAM_VERSION_PATCH << 0)

#macro PROGRAM_NAME "Phantasia"

#macro GAME_TICK 60

#macro SITE_BLUESKY "https://bsky.app/profile/phantasiagame.bsky.social"
#macro SITE_DISCORD "https://discord.gg/MetyWwT8fs"
#macro SITE_TWITTER "https://x.com/PhantasiaGame"

cursor_sprite = spr_Mouse;

randomize();

window_set_cursor(cr_none);

gml_pragma("MarkTagAsUsed", "include_me");

sysinfo_init();