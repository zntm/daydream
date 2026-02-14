/// @description Initialize the modular GUI system

#macro GUI_HP_BAR_HEIGHT 8
#macro GUI_HP_HEART_SCALE 1
#macro GUI_HP_BAR_LOGICAL_HEIGHT 8
#macro GUI_HP_HEART_OVERLAP_RATIO 0.5
#macro GUI_HP_SPRITE_INDEX 2
#macro GUI_HP_COLOUR make_colour_rgb(255, 20, 147)
#macro GUI_STAMINA_COLOUR make_colour_rgb(0, 191, 255)
#macro GUI_HP_HEART_XOFFSET 0
#macro GUI_HP_HEART_YOFFSET 0

function gui_init_modular()
{
    show_debug_message("[Daydream] gui_init_modular called");
    // Register component types
    gui_register_component("panel", GUIPanel);
    gui_register_component("slot", GUISlot);
    gui_register_component("text", GUIText);
    gui_register_component("chat_history", GUIChatHistory);
    gui_register_component("choice_panel", GUIChoicePanel);
    gui_register_component("effect_panel", GUIEffectPanel);
    gui_register_component("effect_icon", GUIEffectIcon);

    gui_register_component("hp_bar", GUIHPBar);
    
    global.gui_deferred_text = [];
    
    // Create root panel using logical dimensions (reference width 960)
    var _gui_scale = global.gui_scale * (global.gui_width / 960);
    var _logical_width = global.gui_width / _gui_scale;
    var _logical_height = global.gui_height / _gui_scale;
    
    global.gui_root = new GUIPanel(0, 0, _logical_width, _logical_height);
    
    // Load hotbar from declarative .ui system
    var _hotbar_def = ui_load("ui/hotbar.ui");
    global.ui_hotbar = ui_spawn(_hotbar_def, {
        link: {},
        parent: global.gui_root
    }, ["inventory_changed"]);
    // Legacy alias for control_inventory_position
    global.gui_panel_hotbar_modular = global.ui_hotbar;
    
    // Stat Bars are now spawned in obj_Player's Create event to ensure player context
    
    // Load inventory from declarative .ui system
    var _inventory_def = ui_load("ui/inventory.ui");
    global.ui_inventory = ui_spawn(_inventory_def, {
        link: {},
        parent: global.gui_root
    }, ["inventory_changed"]);
    global.gui_panel_inventory_modular = global.ui_inventory;
    // Start hidden
    global.ui_inventory.visible = false;
    
    // Note: Inventory visibility is controlled by ui_inventory.visible in control_inventory()
    // and its root elements will follow that visibility if we sync them.
    // However, the cleanest way is often to just let the individual elements handle their visibility
    // based on the global state.
    
    // Create crafting panel (dynamic)
    global.gui_panel_crafting_modular = new GUIPanel(0, 0, 0, 0);
    global.gui_panel_crafting_modular.set_anchor("center", "bottom");
    global.gui_panel_crafting_modular.visible = false;
    global.gui_root.add_child(global.gui_panel_crafting_modular);
    
    // Create chat history panel (bottom-left)
    global.gui_panel_chat = new GUIChatHistory(8, _logical_height - 160, 300, 128, 8);
    global.gui_root.add_child(global.gui_panel_chat);
    
    // Create choice panel (centered, initially hidden)
    global.gui_panel_choices = new GUIChoicePanel((_logical_width - 300) / 2, _logical_height / 2 - 50, 300);
    global.gui_panel_choices.visible = false;
    global.gui_root.add_child(global.gui_panel_choices);
    
    // Create effect panel (bottom-right)
    global.gui_panel_effects = new GUIEffectPanel(0, 0);
    global.gui_panel_effects.offset_x = 16;
    global.gui_panel_effects.offset_y = 16;
    global.gui_panel_effects.set_anchor("right", "bottom");
    global.gui_root.add_child(global.gui_panel_effects);
    
    show_debug_message("GUI: Modular GUI system initialized");
}

/// @description GUI HP Bar Component
/// @param {Real} _x X position relative to parent
/// @param {Real} _y Y position relative to parent
/// @param {Real} _width Component width
/// @param {Real} _height Component height

function GUIHPBar(_x, _y, _width, _height) : GUIComponent(_x, _y, _width, _height) constructor
{
    static draw_content = function()
    {
        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_width / 960);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _screen_x = _abs_x * _base_scale_x;
        var _screen_y = _abs_y * _base_scale_y;
        // The component width is in logical units.
        var _screen_width = width * _base_scale_x;
        
        var _lp = noone;
        with (obj_Player) { if (is_local) { _lp = id; break; } }
        if (_lp == noone) return;
        
        var _hp = _lp.hp;
        var _hp_max = _lp.hp_max;
        var _hp_ratio = clamp(_hp / _hp_max, 0, 1);
        
        var _stamina = _lp.stamina;
        var _stamina_max = _lp.stamina_max;
        var _stamina_ratio = clamp(_stamina / _stamina_max, 0, 1);
        
        // Heart Icon Settings
        var _heart_sprite = spr_GUI_HP; 
        var _heart_sprite_width = sprite_get_width(_heart_sprite);
        var _heart_sprite_height = sprite_get_height(_heart_sprite);
        var _heart_width = _heart_sprite_width * GUI_HP_HEART_SCALE * _base_scale_x;
        var _heart_height = _heart_sprite_height * GUI_HP_HEART_SCALE * _base_scale_y;
        
        // Position Heart
        var _bar_height = GUI_HP_BAR_LOGICAL_HEIGHT * _base_scale_y;
        var _half_height = _bar_height / 2;
        
        // Bar starts halfway through the heart to appear "connected/behind"
        var _bar_x_offset = _heart_width * GUI_HP_HEART_OVERLAP_RATIO; 
        
        // The bar extends to the full width of the component
        var _bar_width = _screen_width - _bar_x_offset;
        
        // Let's place bar at the bottom half.
        var _bar_y = _screen_y + (height * _base_scale_y) - _bar_height;
        
        // Draw Bar Background (Draw FIRST so it is behind the heart)
        draw_set_colour(c_black);
        draw_rectangle(_screen_x + _bar_x_offset, _bar_y, _screen_x + _bar_x_offset + _bar_width, _bar_y + _bar_height, false);
        
        // Draw HP Fill (Top Half)
        draw_set_colour(GUI_HP_COLOUR);
        if (_hp_ratio > 0)
        {
            draw_rectangle(_screen_x + _bar_x_offset, _bar_y, _screen_x + _bar_x_offset + (_bar_width * _hp_ratio), _bar_y + _half_height, false);
        }
        
        // Draw Stamina Fill (Bottom Half)
        draw_set_colour(GUI_STAMINA_COLOUR);
        if (_stamina_ratio > 0)
        {
            draw_rectangle(_screen_x + _bar_x_offset, _bar_y + _half_height, _screen_x + _bar_x_offset + (_bar_width * _stamina_ratio), _bar_y + _bar_height, false);
        }
        
        draw_set_colour(c_white);
        
        // Draw Heart (aligned with bar center, drawn AFTER bar)
        var _heart_x = _screen_x + (GUI_HP_HEART_XOFFSET * _base_scale_x);
        var _heart_y = _bar_y + (_bar_height / 2) - (_heart_height / 2) + (GUI_HP_HEART_YOFFSET * _base_scale_y);
        draw_sprite_ext(_heart_sprite, GUI_HP_SPRITE_INDEX, _heart_x, _heart_y, GUI_HP_HEART_SCALE * _base_scale_x, GUI_HP_HEART_SCALE * _base_scale_y, 0, c_white, 1);
        
        // Draw Text "50/100"
        var _text_string = $"{ceil(_hp)}/{ceil(_hp_max)}";
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        
        var _text_x = _screen_x + _bar_x_offset + (_bar_width / 2);
        var _text_y = _bar_y - (2 * _base_scale_y); // 2px padding above bar
        
        // Use global font settings if available, or just render_text defaults
        render_text(_text_x, _text_y, _text_string, _base_scale_x, _base_scale_y);
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}
