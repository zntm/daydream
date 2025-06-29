global.menu_player_attire_index = 0;
global.menu_player_attire_page  = 0;

global.menu_player_colour_page = 0;

global.player_save_data = {
    name: "",
    attire: {
        body:         {},
        headwear:     {},
        eyes:         {},
        face:         {},
        hair:         {},
        pants:        {},
        shirt:        {},
        shirt_detail: {},
        footwear:     {}
    }
}

function menu_refresh_value_player_save()
{
    global.player_save_data.name = "";
    
    global.player_save_data.attire.body.colour = 33;
    
    global.player_save_data.attire.headwear.index  = 0;
    global.player_save_data.attire.headwear.colour = 44;
    
    global.player_save_data.attire.eyes.index  = 0;
    global.player_save_data.attire.eyes.colour = 39;
    
    global.player_save_data.attire.face.index  = 0;
    global.player_save_data.attire.face.colour = 8;
    
    global.player_save_data.attire.hair.index  = 0;
    global.player_save_data.attire.hair.colour = 44;
    
    global.player_save_data.attire.pants.index  = 0;
    global.player_save_data.attire.pants.colour = 44;
    
    global.player_save_data.attire.shirt.index  = 0;
    global.player_save_data.attire.shirt.colour = 46;
    
    global.player_save_data.attire.shirt_detail.index  = 0;
    global.player_save_data.attire.shirt_detail.colour = 8;
    
    global.player_save_data.attire.footwear.index  = 0;
    global.player_save_data.attire.footwear.colour = 8;
    
    global.menu_player_attire_index = 0;
    global.menu_player_colour_page = 0;
}