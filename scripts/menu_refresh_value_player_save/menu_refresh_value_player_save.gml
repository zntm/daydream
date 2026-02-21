global.menu_player_attire_index = 0;
global.menu_player_attire_page  = 0;

global.menu_player_colour_page = 0;

global.current_player = {
    name: "",
    uuid: "",
    hp: 100,
    hp_max: 100,
    attire: [33, 1, 0, 1.0, 0] // [body_colour, hair_index, shirt_index, pitch, voice_index]
}

function menu_refresh_value_player_save()
{
    global.current_player.name = "";
    global.current_player.uuid = "";
    
    global.current_player.hp = 100;
    global.current_player.hp_max = 100;
    
    global.current_player.attire = [33, 1, 0, 1.0, 0];
    
    global.menu_player_attire_index = 0;
    global.menu_player_attire_page  = 0;
    
    global.menu_player_colour_page = 0;
}

