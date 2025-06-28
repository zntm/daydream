global.menu_attire_index = 0;

global.menu_player_data = {
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

function menu_refresh_attire()
{
    global.menu_player_data.name = "";
    
    global.menu_player_data.attire.body.colour = 33;
    
    global.menu_player_data.attire.headwear.index  = 0;
    global.menu_player_data.attire.headwear.colour = 44;
    
    global.menu_player_data.attire.eyes.index  = 0;
    global.menu_player_data.attire.eyes.colour = 39;
    
    global.menu_player_data.attire.face.index  = 0;
    global.menu_player_data.attire.face.colour = 8;
    
    global.menu_player_data.attire.hair.index  = 0;
    global.menu_player_data.attire.hair.colour = 44;
    
    global.menu_player_data.attire.pants.index  = 0;
    global.menu_player_data.attire.pants.colour = 44;
    
    global.menu_player_data.attire.shirt.index  = 0;
    global.menu_player_data.attire.shirt.colour = 46;
    
    global.menu_player_data.attire.shirt_detail.index  = 0;
    global.menu_player_data.attire.shirt_detail.colour = 8;
    
    global.menu_player_data.attire.footwear.index  = 0;
    global.menu_player_data.attire.footwear.colour = 8;
    
    global.menu_attire_index = 0;
}