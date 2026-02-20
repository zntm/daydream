global.menu_player_attire_index = 0;
global.menu_player_attire_page  = 0;

global.menu_player_colour_page = 0;

global.current_player = {
    name: "",
    uuid: "",
    attire: {
        body: {},
        headwear: {},
        eyes: {},
        face: {},
        hair: {},
        pants: {},
        shirt: {},
        shirt_detail: {},
        footwear: {}
    }
}

function menu_refresh_value_player_save()
{
    global.current_player.name = "";
    global.current_player.uuid = "";
    
    global.current_player.attire.body.colour = 33;
    
    global.current_player.attire.headwear.index  = 0;
    global.current_player.attire.headwear.colour = 44;
        
    global.current_player.attire.eyes.index  = 0;
    global.current_player.attire.eyes.colour = 39;
    
    global.current_player.attire.face.index  = 0;
    global.current_player.attire.face.colour = 8;
    
    global.current_player.attire.hair.index  = 1;
    global.current_player.attire.hair.colour = 44;
    
    global.current_player.attire.pants.index  = 0;
    global.current_player.attire.pants.colour = 44;
    
    global.current_player.attire.shirt.index  = 0;
    global.current_player.attire.shirt.colour = 46;
    
    global.current_player.attire.shirt_detail.index  = 0;
    global.current_player.attire.shirt_detail.colour = 8;
    
    global.current_player.attire.footwear.index  = 0;
    global.current_player.attire.footwear.colour = 8;
    
    global.menu_player_attire_index = 0;
    global.menu_player_attire_page  = 0;
    
    global.menu_player_colour_page = 0;
}
