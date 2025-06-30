global.menu_player_attire_index = 0;
global.menu_player_attire_page  = 0;

global.menu_player_colour_page = 0;

function menu_refresh_value_player_save()
{
    global.player_save_data = {
        name: "",
        attire: {
            body: {
                colour: 33
            },
            headwear: {
                index: 0,
                colour: 44
            },
            eyes: {
                index: 0,
                colour: 39
            },
            face: {
                index: 0,
                colour: 8
            },
            hair: {
                index: 0,
                colour: 44
            },
            pants: {
                index: 0,
                colour: 44
            },
            shirt: {
                index: 0,
                colour: 46
            },
            shirt_detail: {
                index: 0,
                colour: 8
            },
            footwear: {
                index: 0,
                colour: 8
            }
        }
    }
    
    global.menu_player_attire_index = 0;
    global.menu_player_attire_page  = 0;
    
    global.menu_player_colour_page = 0;
}