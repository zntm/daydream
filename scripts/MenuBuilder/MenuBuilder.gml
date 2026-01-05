/// @description MenuBuilder - Factory for creating common menu layouts using the UIElement system

function _MenuBuilder() constructor
{
    // --- Settings Panel ---
    
    /// @desc Creates a settings panel for a given category
    /// @param {String} _category The settings category (e.g., "general", "graphics", "audio", "controls")
    /// @returns {Struct.UIElement} Root element for the settings panel
    static create_settings_panel = function(_category)
    {
        var _settings_data = global.settings_data;
        var _settings = global.settings;
        var _settings_category = global.settings_data_category;
        
        // Handle controls category with input type toggle
        var _actual_category = _category;
        if (_category == "controls" || _category == "controls_gamepad" || _category == "controls_touch")
        {
            _actual_category = "controls_" + global.controls_input_type;
            if (global.controls_input_type == "keyboard") _actual_category = "controls";
        }
        
        var _category_items = _settings_category[$ _actual_category];
        if (_category_items == undefined) _category_items = [];
        
        // Create main container
        var _root = new UIBox("settings_panel")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(0, UI_SIZE_MODE.FILL_PARENT)
            .set_layout(UI_LAYOUT.FLEX_COLUMN, 0)
            .set_background(c_black, 0);
        
        // Create scrollable content area
        var _scroll = new UIScrollView("settings_scroll")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(0, UI_SIZE_MODE.FILL_PARENT)
            .set_layout(UI_LAYOUT.FLEX_COLUMN, 8)
            .set_padding(16, 16, 16, 16)
            .set_background(c_black, 0);
        
        _root.add_child(_scroll);
        
        // Add input type toggle for controls
        if (_category == "controls" || _category == "controls_gamepad" || _category == "controls_touch")
        {
            var _toggle_row = new UIBox("input_type_toggle")
                .set_width(0, UI_SIZE_MODE.FILL_PARENT)
                .set_height(32, UI_SIZE_MODE.FIXED)
                .set_layout(UI_LAYOUT.FLEX_ROW, 8)
                .set_justify(UI_ALIGN.CENTER)
                .set_background(c_black, 0)
                .set_margin(0, 0, 16, 0);
            
            var _mode_text = string_upper(string_char_at(global.controls_input_type, 1)) + 
                             string_copy(global.controls_input_type, 2, string_length(global.controls_input_type) - 1);
            
            var _toggle_btn = new UIButton("input_mode_btn", $"Mode: {_mode_text}")
                .set_on_click(function(_self) {
                    static __input_types = ["keyboard", "gamepad"];
                    var _current = global.controls_input_type;
                    var _index = array_get_index(__input_types, _current);
                    _index = (_index + 1) mod array_length(__input_types);
                    global.controls_input_type = __input_types[_index];
                    
                    // Rebuild the settings panel
                    var _new_panel = MenuBuilder.create_settings_panel("controls");
                    global.ui_manager.set_root(_new_panel);
                    global.ui_manager.layout();
                });
            
            _toggle_row.add_child(_toggle_btn);
            _scroll.add_child(_toggle_row);
        }
        
        // Generate settings items
        var _length = array_length(_category_items);
        for (var i = 0; i < _length; ++i)
        {
            var _name = _category_items[i];
            var _data = _settings_data[$ _name];
            var _value = _settings[$ _name];
            var _type = _data.get_type();
            
            var _row = _create_setting_row(_name, _data, _value, _type);
            _scroll.add_child(_row);
        }
        
        return _root;
    }
    
    /// @desc Creates a single settings row with label and control
    static _create_setting_row = function(_name, _data, _value, _type)
    {
        var _row = new UIBox($"setting_{_name}")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(48, UI_SIZE_MODE.FIXED)
            .set_layout(UI_LAYOUT.FLEX_ROW, 16)
            .set_align(UI_ALIGN.CENTER)
            .set_padding(8, 8, 0, 0)
            .set_background(make_colour_rgb(30, 30, 45), 0.6)
            .set_border(make_colour_rgb(50, 50, 70), 1, 0.3)
            .set_corner_radius(4);
        
        // Label container (left side)
        var _label_container = new UIElement("label_container")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(0, UI_SIZE_MODE.FILL_PARENT)
            .set_flex(1, 0)
            .set_layout(UI_LAYOUT.FLEX_COLUMN, 2);
        
        // Setting name
        var _label = new UIText($"label_{_name}", loca_translate($"phantasia:settings.{_name}.name"))
            .set_text_scale(1);
        
        // Setting description
        var _desc = new UIText($"desc_{_name}", loca_translate($"phantasia:settings.{_name}.description"))
            .set_text_scale(0.7)
            .set_text_colour(c_ltgray)
            .set_text_alpha(0.6);
        
        _label_container.add_child(_label);
        _label_container.add_child(_desc);
        _row.add_child(_label_container);
        
        // Control (right side)
        var _control = undefined;
        
        switch (_type)
        {
            case SETTINGS_TYPE.SWITCH:
                _control = new UISwitch($"switch_{_name}", _value)
                    .set_on_change(method({ setting_name: _name, data: _data }, function(_self, _val) {
                        global.settings[$ setting_name] = _val;
                        
                        var _on_update = data.get_on_update();
                        if (_on_update != undefined) _on_update(setting_name, _val);
                        
                        var _on_release = data.get_on_release();
                        if (_on_release != undefined) _on_release(setting_name, _val);
                    }));
                break;
                
            case SETTINGS_TYPE.SLIDER:
                var _min = _data.get_range_min();
                var _max = _data.get_range_max();
                if (_min == 0 && _max == 0) _max = 1;
                
                var _step = _data.get_step();
                if (_step == undefined) _step = (_max - _min) / 100;
                
                _control = new UISlider($"slider_{_name}", _min, _max, _value)
                    .set_step(_step)
                    .set_width(200, UI_SIZE_MODE.FIXED)
                    .set_on_value_change(method({ setting_name: _name, data: _data }, function(_self, _val) {
                        global.settings[$ setting_name] = _val;
                        
                        var _on_update = data.get_on_update();
                        if (_on_update != undefined) _on_update(setting_name, _val);
                    }));
                break;
                
            case SETTINGS_TYPE.ARROW:
                var _values = _data.get_values();
                if (_values != undefined && array_length(_values) > 0)
                {
                    var _options = array_map(_values, function(_val) {
                        if (is_string(_val)) return _val;
                        return string(_val);
                    });
                    
                    _control = new UIDropdown($"dropdown_{_name}", _options, _value)
                        .set_dropdown_size(180, 28)
                        .set_on_change(method({ setting_name: _name, data: _data }, function(_self, _index, _val) {
                            global.settings[$ setting_name] = _index;
                            
                            var _on_update = data.get_on_update();
                            if (_on_update != undefined) _on_update(setting_name, _index);
                        }));
                }
                break;
                
            case SETTINGS_TYPE.HOTKEY:
                var _is_gamepad = string_pos("gamepad", _name) > 0;
                var _key_name = _is_gamepad ? input_get_gamepad_name(_value) : input_get_name(_value);
                
                _control = new UIButton($"hotkey_{_name}", _key_name)
                    .set_on_click(method({ setting_name: _name, is_gamepad: _is_gamepad }, function(_self) {
                        // Show keybind remapping dialog
                        var _dialog = MenuBuilder.create_keybind_dialog(setting_name, is_gamepad, function(_new_key) {
                            global.settings[$ setting_name] = _new_key;
                            // Rebuild to update display
                        });
                        // TODO: Push dialog as modal
                    }));
                break;
        }
        
        if (_control != undefined)
        {
            _row.add_child(_control);
        }
        
        return _row;
    }
    
    // --- Category Tab Panel ---
    
    /// @desc Creates a full settings screen with category tabs
    /// @returns {Struct.UIElement} Root element for the settings screen
    static create_settings_screen = function()
    {
        var _categories = ["general", "accessibility", "graphics", "audio", "controls"];
        
        var _root = new UIBox("settings_screen")
            .set_anchor(UI_ALIGN.CENTER, UI_ALIGN.CENTER)
            .set_width(800, UI_SIZE_MODE.FIXED)
            .set_height(500, UI_SIZE_MODE.FIXED)
            .set_layout(UI_LAYOUT.FLEX_COLUMN, 0)
            .set_background(make_colour_rgb(20, 20, 30), 0.95)
            .set_border(make_colour_rgb(60, 60, 100), 2, 1)
            .set_corner_radius(8);
        
        // Header
        var _header = new UIBox("settings_header")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(48, UI_SIZE_MODE.FIXED)
            .set_layout(UI_LAYOUT.FLEX_ROW, 0)
            .set_justify(UI_ALIGN.CENTER)
            .set_align(UI_ALIGN.CENTER)
            .set_background(make_colour_rgb(30, 30, 50), 1);
        
        var _title = new UIText("settings_title", loca_translate("phantasia:menu.settings.title"))
            .set_text_scale(1.5)
            .set_text_colour(c_white);
        
        _header.add_child(_title);
        _root.add_child(_header);
        
        // Tab panel for categories
        var _tabs = new UITabPanel("settings_tabs")
            .set_flex(1, 0)
            .set_width(0, UI_SIZE_MODE.FILL_PARENT);
        
        // Add each category as a tab
        for (var i = 0; i < array_length(_categories); ++i)
        {
            var _cat = _categories[i];
            var _cat_name = loca_translate($"phantasia:menu.settings.category.{_cat}");
            var _panel = create_settings_panel(_cat);
            
            _tabs.add_tab(_cat_name, _panel);
        }
        
        _root.add_child(_tabs);
        
        // Back button
        var _footer = new UIBox("settings_footer")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(48, UI_SIZE_MODE.FIXED)
            .set_layout(UI_LAYOUT.FLEX_ROW, 0)
            .set_justify(UI_ALIGN.CENTER)
            .set_align(UI_ALIGN.CENTER)
            .set_background(make_colour_rgb(25, 25, 40), 1);
        
        var _back_btn = new UIButton("settings_back", loca_translate("phantasia:menu.back"))
            .set_on_click(function(_self) {
                // Navigate back
                menu_transition_goto(rm_Menu_Title);
            });
        
        _footer.add_child(_back_btn);
        _root.add_child(_footer);
        
        return _root;
    }
    
    // --- Keybind Dialog ---
    
    /// @desc Creates a keybind remapping dialog
    /// @param {String} _setting_name The setting being remapped
    /// @param {Bool} _is_gamepad Whether this is a gamepad binding
    /// @param {Function} _on_complete Callback when binding is complete
    /// @returns {Struct.UIElement} Dialog element
    static create_keybind_dialog = function(_setting_name, _is_gamepad, _on_complete)
    {
        var _overlay = new UIBox("keybind_overlay")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(0, UI_SIZE_MODE.FILL_PARENT)
            .set_background(c_black, 0.7)
            .set_layout(UI_LAYOUT.BLOCK);
        
        var _dialog = new UIBox("keybind_dialog")
            .set_anchor(UI_ALIGN.CENTER, UI_ALIGN.CENTER)
            .set_size(400, 200)
            .set_layout(UI_LAYOUT.FLEX_COLUMN, 16)
            .set_justify(UI_ALIGN.CENTER)
            .set_align(UI_ALIGN.CENTER)
            .set_padding(24)
            .set_background(make_colour_rgb(30, 30, 50), 1)
            .set_border(make_colour_rgb(80, 80, 140), 2, 1)
            .set_corner_radius(8);
        
        var _title = new UIText("keybind_title", loca_translate("phantasia:menu.settings.keybind.title"))
            .set_text_scale(1.2)
            .set_text_align(fa_center, fa_top);
        
        var _instruction = new UIText("keybind_instruction", 
            _is_gamepad ? loca_translate("phantasia:menu.settings.keybind.press_gamepad") 
                        : loca_translate("phantasia:menu.settings.keybind.press_key"))
            .set_text_scale(0.9)
            .set_text_colour(c_ltgray)
            .set_text_align(fa_center, fa_top);
        
        var _cancel_btn = new UIButton("keybind_cancel", loca_translate("phantasia:menu.cancel"))
            .set_on_click(function(_self) {
                // Close dialog
                global.ui_manager.pop_root();
            });
        
        _dialog.add_child(_title);
        _dialog.add_child(_instruction);
        _dialog.add_child(_cancel_btn);
        
        _overlay.add_child(_dialog);
        
        // Store context for input handling
        _overlay.setting_name = _setting_name;
        _overlay.is_gamepad = _is_gamepad;
        _overlay.on_complete = _on_complete;
        
        // Custom update to detect key press
        _overlay.set_on_update(function(_self) {
            if (_self.is_gamepad)
            {
                // Check all gamepad buttons
                for (var i = gp_face1; i <= gp_axisrv; ++i)
                {
                    if (gamepad_button_check_pressed(0, i))
                    {
                        global.settings[$ _self.setting_name] = i;
                        if (_self.on_complete != undefined) _self.on_complete(i);
                        global.ui_manager.pop_root();
                        return;
                    }
                }
            }
            else
            {
                // Check keyboard
                var _key = keyboard_lastkey;
                if (_key > 0 && _key != vk_nokey && keyboard_check_pressed(_key))
                {
                    global.settings[$ _self.setting_name] = _key;
                    if (_self.on_complete != undefined) _self.on_complete(_key);
                    global.ui_manager.pop_root();
                    keyboard_lastkey = vk_nokey;
                    return;
                }
            }
        });
        
        return _overlay;
    }
    
    // --- Title Menu ---
    
    /// @desc Creates the main title menu
    /// @returns {Struct.UIElement} Root element for the title screen
    static create_title_menu = function()
    {
        var _root = new UIBox("title_root")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(0, UI_SIZE_MODE.FILL_PARENT)
            .set_background(c_black, 0)
            .set_layout(UI_LAYOUT.BLOCK);
        
        // Button container (centered)
        var _button_container = new UIBox("title_buttons")
            .set_anchor(UI_ALIGN.CENTER, UI_ALIGN.CENTER)
            .set_layout(UI_LAYOUT.FLEX_COLUMN, 12)
            .set_padding(32)
            .set_background(make_colour_rgb(20, 20, 30), 0.8)
            .set_border(make_colour_rgb(50, 50, 80), 1, 0.5)
            .set_corner_radius(8);
        
        // Play button
        var _play_btn = new UIButton("btn_play", loca_translate("phantasia:menu.play"))
            .set_size(200, 40)
            .set_on_click(function(_self) {
                menu_transition_goto(rm_Menu_Player);
            });
        
        // Settings button
        var _settings_btn = new UIButton("btn_settings", loca_translate("phantasia:menu.settings"))
            .set_size(200, 40)
            .set_on_click(function(_self) {
                var _settings_screen = MenuBuilder.create_settings_screen();
                global.ui_manager.set_root(_settings_screen);
                global.ui_manager.layout();
            });
        
        // Credits button
        var _credits_btn = new UIButton("btn_credits", loca_translate("phantasia:menu.credits"))
            .set_size(200, 40)
            .set_on_click(function(_self) {
                menu_transition_goto(rm_Menu_Credits);
            });
        
        // Quit button
        var _quit_btn = new UIButton("btn_quit", loca_translate("phantasia:menu.quit"))
            .set_size(200, 40)
            .set_on_click(function(_self) {
                game_end();
            });
        
        _button_container.add_child(_play_btn);
        _button_container.add_child(_settings_btn);
        _button_container.add_child(_credits_btn);
        _button_container.add_child(_quit_btn);
        
        _root.add_child(_button_container);
        
        return _root;
    }
    
    // --- Player Selection ---
    
    /// @desc Creates the player selection menu
    /// @returns {Struct.UIElement} Root element for player selection
    static create_player_select = function()
    {
        var _root = new UIBox("player_select_root")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(0, UI_SIZE_MODE.FILL_PARENT)
            .set_background(c_black, 0)
            .set_layout(UI_LAYOUT.FLEX_COLUMN, 16)
            .set_padding(32);
        
        // Header
        var _header = new UIBox("player_header")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(48, UI_SIZE_MODE.FIXED)
            .set_layout(UI_LAYOUT.FLEX_ROW, 16)
            .set_align(UI_ALIGN.CENTER)
            .set_background(c_black, 0);
        
        var _back_btn = new UIButton("player_back", "<")
            .set_size(40, 40)
            .set_on_click(function(_self) {
                menu_transition_goto(rm_Menu_Title);
            });
        
        var _title = new UIText("player_title", loca_translate("phantasia:menu.player.title"))
            .set_text_scale(1.5);
        
        _header.add_child(_back_btn);
        _header.add_child(_title);
        _root.add_child(_header);
        
        // Player list (scrollable)
        var _scroll = new UIScrollView("player_scroll")
            .set_flex(1, 0)
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_layout(UI_LAYOUT.FLEX_COLUMN, 8)
            .set_background(make_colour_rgb(20, 20, 30), 0.5)
            .set_corner_radius(4)
            .set_padding(8);
        
        // Load player saves
        var _players = file_read_directory($"{PROGRAM_DIRECTORY_SAVES}\\players");
        if (_players != undefined)
        {
            var _player_count = array_length(_players);
            for (var i = 0; i < _player_count; ++i)
            {
                var _player_name = _players[i];
                var _card = _create_player_card(_player_name);
                _scroll.add_child(_card);
            }
        }
        
        // Create new player button
        var _create_btn = new UIButton("create_player", loca_translate("phantasia:menu.player.create"))
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(48, UI_SIZE_MODE.FIXED)
            .set_on_click(function(_self) {
                // Show player creation dialog
            });
        
        _scroll.add_child(_create_btn);
        _root.add_child(_scroll);
        
        return _root;
    }
    
    /// @desc Creates a player card for the player list
    static _create_player_card = function(_player_name)
    {
        var _card = new UIBox($"player_card_{_player_name}")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(64, UI_SIZE_MODE.FIXED)
            .set_layout(UI_LAYOUT.FLEX_ROW, 12)
            .set_align(UI_ALIGN.CENTER)
            .set_padding(12)
            .set_background(make_colour_rgb(35, 35, 50), 0.9)
            .set_border(make_colour_rgb(60, 60, 90), 1, 0.5)
            .set_corner_radius(4);
        
        // Player avatar placeholder
        var _avatar = new UIBox("avatar")
            .set_size(48, 48)
            .set_background(make_colour_rgb(60, 60, 80), 1)
            .set_corner_radius(4);
        
        // Player name
        var _name_text = new UIText("name", _player_name)
            .set_text_scale(1.2)
            .set_flex(1, 0);
        
        // Select button
        var _select_btn = new UIButton("select", loca_translate("phantasia:menu.select"))
            .set_on_click(method({ player: _player_name }, function(_self) {
                global.selected_player = player;
                menu_transition_goto(rm_Menu_World);
            }));
        
        // Delete button
        var _delete_btn = new UIButton("delete", "X")
            .set_size(32, 32)
            .set_normal_colour(make_colour_rgb(120, 40, 40), make_colour_rgb(180, 60, 60))
            .set_hover_colour(make_colour_rgb(180, 60, 60), make_colour_rgb(220, 80, 80))
            .set_on_click(method({ player: _player_name }, function(_self) {
                // Show delete confirmation
            }));
        
        _card.add_child(_avatar);
        _card.add_child(_name_text);
        _card.add_child(_select_btn);
        _card.add_child(_delete_btn);
        
        return _card;
    }
    
    // --- World Selection ---
    
    /// @desc Creates the world selection menu
    /// @returns {Struct.UIElement} Root element for world selection
    static create_world_select = function()
    {
        var _root = new UIBox("world_select_root")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(0, UI_SIZE_MODE.FILL_PARENT)
            .set_background(c_black, 0)
            .set_layout(UI_LAYOUT.FLEX_COLUMN, 16)
            .set_padding(32);
        
        // Header
        var _header = new UIBox("world_header")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(48, UI_SIZE_MODE.FIXED)
            .set_layout(UI_LAYOUT.FLEX_ROW, 16)
            .set_align(UI_ALIGN.CENTER)
            .set_background(c_black, 0);
        
        var _back_btn = new UIButton("world_back", "<")
            .set_size(40, 40)
            .set_on_click(function(_self) {
                menu_transition_goto(rm_Menu_Player);
            });
        
        var _title = new UIText("world_title", loca_translate("phantasia:menu.world.title"))
            .set_text_scale(1.5);
        
        _header.add_child(_back_btn);
        _header.add_child(_title);
        _root.add_child(_header);
        
        // World list (scrollable)
        var _scroll = new UIScrollView("world_scroll")
            .set_flex(1, 0)
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_layout(UI_LAYOUT.FLEX_COLUMN, 8)
            .set_background(make_colour_rgb(20, 20, 30), 0.5)
            .set_corner_radius(4)
            .set_padding(8);
        
        // Load world saves
        var _worlds = file_read_directory($"{PROGRAM_DIRECTORY_SAVES}\\worlds");
        if (_worlds != undefined)
        {
            var _world_count = array_length(_worlds);
            for (var i = 0; i < _world_count; ++i)
            {
                var _world_name = _worlds[i];
                var _card = _create_world_card(_world_name);
                _scroll.add_child(_card);
            }
        }
        
        // Create new world button
        var _create_btn = new UIButton("create_world", loca_translate("phantasia:menu.world.create"))
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(48, UI_SIZE_MODE.FIXED)
            .set_on_click(function(_self) {
                // Show world creation dialog
            });
        
        _scroll.add_child(_create_btn);
        _root.add_child(_scroll);
        
        return _root;
    }
    
    /// @desc Creates a world card for the world list
    static _create_world_card = function(_world_name)
    {
        var _card = new UIBox($"world_card_{_world_name}")
            .set_width(0, UI_SIZE_MODE.FILL_PARENT)
            .set_height(72, UI_SIZE_MODE.FIXED)
            .set_layout(UI_LAYOUT.FLEX_ROW, 12)
            .set_align(UI_ALIGN.CENTER)
            .set_padding(12)
            .set_background(make_colour_rgb(35, 35, 50), 0.9)
            .set_border(make_colour_rgb(60, 60, 90), 1, 0.5)
            .set_corner_radius(4);
        
        // World preview placeholder
        var _preview = new UIBox("preview")
            .set_size(96, 54)
            .set_background(make_colour_rgb(60, 60, 80), 1)
            .set_corner_radius(4);
        
        // World info container
        var _info = new UIElement("info")
            .set_flex(1, 0)
            .set_layout(UI_LAYOUT.FLEX_COLUMN, 4);
        
        var _name_text = new UIText("name", _world_name)
            .set_text_scale(1.1);
        
        var _seed_text = new UIText("seed", "Seed: ???")
            .set_text_scale(0.8)
            .set_text_colour(c_ltgray);
        
        _info.add_child(_name_text);
        _info.add_child(_seed_text);
        
        // Play button
        var _play_btn = new UIButton("play", loca_translate("phantasia:menu.play"))
            .set_on_click(method({ world: _world_name }, function(_self) {
                global.selected_world = world;
                // Start game
                room_goto(rm_World);
            }));
        
        // Delete button
        var _delete_btn = new UIButton("delete", "X")
            .set_size(32, 32)
            .set_normal_colour(make_colour_rgb(120, 40, 40), make_colour_rgb(180, 60, 60))
            .set_hover_colour(make_colour_rgb(180, 60, 60), make_colour_rgb(220, 80, 80))
            .set_on_click(method({ world: _world_name }, function(_self) {
                // Show delete confirmation
            }));
        
        _card.add_child(_preview);
        _card.add_child(_info);
        _card.add_child(_play_btn);
        _card.add_child(_delete_btn);
        
        return _card;
    }
}

// Create global instance
global.MenuBuilder = new _MenuBuilder();

/// @desc Get the MenuBuilder singleton instance
/// @returns {Struct._MenuBuilder} The MenuBuilder instance
function MenuBuilder() { return global.MenuBuilder; }

