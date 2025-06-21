#macro PROGRAM_VERSION_MAJOR current_year
#macro PROGRAM_VERSION_MINOR current_month
#macro PROGRAM_VERSION_PATCH 0

#macro PROGRAM_NAME "Phantasia"

#macro GAME_TICK 60

#macro SITE_BLUESKY "https://bsky.app/profile/phantasiagame.bsky.social"
#macro SITE_DISCORD "https://discord.gg/PjdKzPZUKK"
#macro SITE_TWITTER "https://x.com/PhantasiaGame"

cursor_sprite = spr_Mouse;

randomize();

window_set_cursor(cr_none);

gml_pragma("MarkTagAsUsed", "include_me");