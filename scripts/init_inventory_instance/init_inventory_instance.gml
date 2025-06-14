#macro INVENTORY_SLOT_DIMENSION 16
#macro INVENTORY_SLOT_SCALE 2
#macro INVENTORY_SLOT_DIMENSION_SCALED (INVENTORY_SLOT_DIMENSION * INVENTORY_SLOT_SCALE)

#macro INVENTORY_BACKPACK_XOFFSET 0
#macro INVENTORY_BACKPACK_YOFFSET 16

#macro INVENTORY_OUTLINE_THICKNESS 1
#macro INVENTORY_OUTLINE_COLOUR #080716

#macro INVENTORY_EMPTY 0

enum INVENTORY_LENGTH {
    BASE      = 50,
    ROW       = 10,
    ARMOR     = 3,
    ACCESSORY = 6,
}

enum GUI_ANCHOR {
    TOP_LEFT,
    TOP,
    TOP_RIGHT,
    MIDDLE_LEFT,
    MIDDLE,
    MIDDLE_RIGHT,
    BOTTOM_LEFT,
    BOTTOM,
    BOTTOM_RIGHT
}

#macro GUI_INVENTORY_SURFACE_PADDING (INVENTORY_SLOT_SCALE * 8)

global.gui_inventory = {
    hotbar: {
        anchor_type: GUI_ANCHOR.TOP_LEFT,
        sprite: spr_Inventory_Slot,
        surface_xoffset: 0,
        surface_yoffset: 0,
        surface_width:  (GUI_INVENTORY_SURFACE_PADDING * 2) + INVENTORY_BACKPACK_XOFFSET + (INVENTORY_SLOT_DIMENSION_SCALED * INVENTORY_LENGTH.ROW),
        surface_height: (GUI_INVENTORY_SURFACE_PADDING * 2) + INVENTORY_BACKPACK_YOFFSET + INVENTORY_SLOT_DIMENSION_SCALED,
        outline: [
            {
                colour: INVENTORY_OUTLINE_COLOUR,
                xoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                yoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                width:  (INVENTORY_OUTLINE_THICKNESS * 2) + (INVENTORY_SLOT_DIMENSION * INVENTORY_LENGTH.ROW),
                height: (INVENTORY_OUTLINE_THICKNESS * 2) + INVENTORY_SLOT_DIMENSION
            }
        ]
    },
    base: {
        anchor_type: GUI_ANCHOR.TOP_LEFT,
        sprite: spr_Inventory_Slot,
        surface_xoffset: 0,
        surface_yoffset: 0,
        surface_width:  (GUI_INVENTORY_SURFACE_PADDING * 2) + INVENTORY_BACKPACK_XOFFSET + (INVENTORY_SLOT_DIMENSION_SCALED * INVENTORY_LENGTH.ROW),
        surface_height: (GUI_INVENTORY_SURFACE_PADDING * 2) + INVENTORY_BACKPACK_YOFFSET + (INVENTORY_SLOT_DIMENSION_SCALED * (INVENTORY_LENGTH.BASE div INVENTORY_LENGTH.ROW)),
        outline: [
            {
                colour: INVENTORY_OUTLINE_COLOUR,
                xoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                yoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                width:  (INVENTORY_OUTLINE_THICKNESS * 2) + (INVENTORY_SLOT_DIMENSION * INVENTORY_LENGTH.ROW),
                height: (INVENTORY_OUTLINE_THICKNESS * 2) + INVENTORY_SLOT_DIMENSION
            },
            {
                colour: INVENTORY_OUTLINE_COLOUR,
                xoffset: GUI_INVENTORY_SURFACE_PADDING + INVENTORY_BACKPACK_XOFFSET - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                yoffset: GUI_INVENTORY_SURFACE_PADDING + INVENTORY_BACKPACK_YOFFSET - INVENTORY_OUTLINE_THICKNESS,
                width:  (INVENTORY_OUTLINE_THICKNESS * 2) + (INVENTORY_SLOT_DIMENSION * INVENTORY_LENGTH.ROW),
                height: (INVENTORY_OUTLINE_THICKNESS * 2) + (INVENTORY_SLOT_DIMENSION * ((INVENTORY_LENGTH.BASE - INVENTORY_LENGTH.ROW) div INVENTORY_LENGTH.ROW))
            }
        ]
    },
    armor_helmet: {
        anchor_type: GUI_ANCHOR.BOTTOM_RIGHT,
        sprite: spr_Inventory_Slot,
        icon: spr_Inventory_Slot_Icon,
        icon_index: 0,
        surface_xoffset: (-INVENTORY_SLOT_DIMENSION_SCALED * 2) - (1 * INVENTORY_SLOT_SCALE),
        surface_yoffset: -INVENTORY_SLOT_DIMENSION_SCALED * 3,
        surface_width:  (GUI_INVENTORY_SURFACE_PADDING * 2) + INVENTORY_SLOT_DIMENSION_SCALED,
        surface_height: (GUI_INVENTORY_SURFACE_PADDING * 2) + INVENTORY_SLOT_DIMENSION_SCALED,
        outline: [
            {
                colour: INVENTORY_OUTLINE_COLOUR,
                xoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                yoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                width:  (INVENTORY_OUTLINE_THICKNESS * 2) + INVENTORY_SLOT_DIMENSION,
                height: (INVENTORY_OUTLINE_THICKNESS * 2) + INVENTORY_SLOT_DIMENSION
            },
        ]
    },
    armor_breastplate: {
        anchor_type: GUI_ANCHOR.BOTTOM_RIGHT,
        sprite: spr_Inventory_Slot,
        icon: spr_Inventory_Slot_Icon,
        icon_index: 1,
        surface_xoffset: (-INVENTORY_SLOT_DIMENSION_SCALED * 2) - (1 * INVENTORY_SLOT_SCALE),
        surface_yoffset: -INVENTORY_SLOT_DIMENSION_SCALED * 2,
        surface_width:  (GUI_INVENTORY_SURFACE_PADDING * 2) + INVENTORY_SLOT_DIMENSION_SCALED,
        surface_height: (GUI_INVENTORY_SURFACE_PADDING * 2) + INVENTORY_SLOT_DIMENSION_SCALED,
        outline: [
            {
                colour: INVENTORY_OUTLINE_COLOUR,
                xoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                yoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                width:  (INVENTORY_OUTLINE_THICKNESS * 2) + INVENTORY_SLOT_DIMENSION,
                height: (INVENTORY_OUTLINE_THICKNESS * 2) + INVENTORY_SLOT_DIMENSION
            }
        ]
    },
    armor_leggings: {
        anchor_type: GUI_ANCHOR.BOTTOM_RIGHT,
        sprite: spr_Inventory_Slot,
        icon: spr_Inventory_Slot_Icon,
        icon_index: 2,
        surface_xoffset: (-INVENTORY_SLOT_DIMENSION_SCALED * 2) - (1 * INVENTORY_SLOT_SCALE),
        surface_yoffset: -INVENTORY_SLOT_DIMENSION_SCALED * 1,
        surface_width:  (GUI_INVENTORY_SURFACE_PADDING * 2) + INVENTORY_SLOT_DIMENSION_SCALED,
        surface_height: (GUI_INVENTORY_SURFACE_PADDING * 2) + INVENTORY_SLOT_DIMENSION_SCALED,
        outline: [
            {
                colour: INVENTORY_OUTLINE_COLOUR,
                xoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                yoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                width:  (INVENTORY_OUTLINE_THICKNESS * 2) + INVENTORY_SLOT_DIMENSION,
                height: (INVENTORY_OUTLINE_THICKNESS * 2) + INVENTORY_SLOT_DIMENSION
            }
        ]
    },
    accessory: {
        anchor_type: GUI_ANCHOR.BOTTOM_RIGHT,
        sprite: spr_Inventory_Slot,
        icon: spr_Inventory_Slot_Icon,
        icon_index: 3,
        surface_xoffset: -INVENTORY_SLOT_DIMENSION_SCALED,
        surface_yoffset: -INVENTORY_SLOT_DIMENSION_SCALED * INVENTORY_LENGTH.ACCESSORY,
        surface_width:  (GUI_INVENTORY_SURFACE_PADDING * 2) + INVENTORY_SLOT_DIMENSION_SCALED,
        surface_height: (GUI_INVENTORY_SURFACE_PADDING * 2) + (INVENTORY_SLOT_DIMENSION_SCALED * INVENTORY_LENGTH.ACCESSORY),
        outline: [
            {
                colour: INVENTORY_OUTLINE_COLOUR,
                xoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                yoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                width:  (INVENTORY_OUTLINE_THICKNESS * 2) + INVENTORY_SLOT_DIMENSION,
                height: (INVENTORY_OUTLINE_THICKNESS * 2) + (INVENTORY_SLOT_DIMENSION * INVENTORY_LENGTH.ACCESSORY)
            }
        ]
    },
    craftable: {
        anchor_type: GUI_ANCHOR.TOP_LEFT,
        sprite: spr_Inventory_Slot,
        icon: spr_Inventory_Slot_Icon,
        icon_index: 0,
        surface_xoffset: INVENTORY_BACKPACK_XOFFSET,
        surface_yoffset: (INVENTORY_BACKPACK_YOFFSET * 2) + (INVENTORY_SLOT_DIMENSION_SCALED * (INVENTORY_LENGTH.BASE div INVENTORY_LENGTH.ROW)),
        surface_width: 0,
        surface_height: 0,
        outline: [
            {
                colour: INVENTORY_OUTLINE_COLOUR,
                xoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                yoffset: GUI_INVENTORY_SURFACE_PADDING - INVENTORY_OUTLINE_THICKNESS - (INVENTORY_SLOT_DIMENSION / 2),
                width:  0,
                height: 0
            }
        ]
    },
    container: {
        anchor_type: GUI_ANCHOR.TOP_LEFT,
        surface_xoffset: 0,
        surface_yoffset: 0,
        surface_width: 0,
        surface_height: 0
    }
}

function init_inventory_instance()
{
    var _gui_width  = global.gui_width;
    var _gui_height = global.gui_height;
    
    var _inventory = global.inventory;
    var _inventory_instance = global.inventory_instance;
    
    var _inventory_names = global.inventory_names;
    var _inventory_names_length = array_length(_inventory_names);
    
    for (var i = 0; i < _inventory_names_length; ++i)
    {
        var _inventory_name = _inventory_names[i];
        var _i = _inventory_instance[$ _inventory_name];
        
        var _inventory_length = array_length(_i);
        
        for (var j = 0; j < _inventory_length; ++j)
        {
            var _inst = instance_create_layer(0, 0, "Instances", obj_Inventory);
            
            _inst.image_xscale = INVENTORY_SLOT_SCALE;
            _inst.image_yscale = INVENTORY_SLOT_SCALE;
            
            if (_inventory_name == "base")
            {
                if (j >= INVENTORY_LENGTH.ROW)
                {
                    _inst.xoffset = INVENTORY_BACKPACK_XOFFSET + ((j mod INVENTORY_LENGTH.ROW) * INVENTORY_SLOT_DIMENSION_SCALED);
                    _inst.yoffset = INVENTORY_BACKPACK_YOFFSET + ((j div INVENTORY_LENGTH.ROW) * INVENTORY_SLOT_DIMENSION_SCALED);
                }
                else
                {
                    _inst.xoffset = (j mod INVENTORY_LENGTH.ROW) * INVENTORY_SLOT_DIMENSION_SCALED;
                    _inst.yoffset = (j div INVENTORY_LENGTH.ROW) * INVENTORY_SLOT_DIMENSION_SCALED;
                }
                
                _inst.slot_type = INVENTORY_SLOT_TYPE.BASE;
            }
            else if (_inventory_name == "armor_helmet")
            {
                _inst.xoffset = 0;
                _inst.yoffset = 0;
                
                _inst.slot_type = INVENTORY_SLOT_TYPE.ARMOR_HELMET;
            }
            else if (_inventory_name == "armor_breastplate")
            {
                _inst.xoffset = 0;
                _inst.yoffset = 0;
                
                _inst.slot_type = INVENTORY_SLOT_TYPE.ARMOR_BREASTPLATE;
                
            }
            else if (_inventory_name == "armor_leggings")
            {
                _inst.xoffset = 0;
                _inst.yoffset = 0;
                
                _inst.slot_type = INVENTORY_SLOT_TYPE.ARMOR_LEGGINGS;
            }
            else if (_inventory_name == "accessory")
            {
                _inst.xoffset = 0;
                _inst.yoffset = INVENTORY_SLOT_DIMENSION_SCALED * j;
                
                _inst.slot_type = INVENTORY_SLOT_TYPE.ACCESSORY;
            }
            
            _inst.inventory_type  = _inventory_name;
            _inst.inventory_index = j;
            
            global.inventory_instance[$ _inventory_name][@ j] = _inst;
            
            instance_deactivate_object(_inst);
        }
    }
}