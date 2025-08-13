#macro DISCORD_APP_ID "1260857725018050643"

if (!np_initdiscord(DISCORD_APP_ID, true, np_steam_app_id_empty))
{
    throw "NekoPresence init fail.";
}