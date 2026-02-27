/// @function debug_init()
/// @desc Initialise the debug overlay
function debug_init()
{
    if (!IS_DEVELOPER_MODE) exit;
    
    show_debug_overlay(true);
    
    debug_text = "";
    global.debug_overlay_hint = "F3 to toggle overlay";
    
    global.debug_reload = {}
    
    // Initialize settings if they don't exist, otherwise keep existing values
    // (This allows settings to persist if we ever reload while keeping global state, 
    // though typically this is called on fresh obj_Game_Control create)
    if (!variable_global_exists("dbg_settings"))
    {
        global.dbg_settings = {
            fps: 0,
            fps_real: 0,
            delta_time: true,
            display_background_celestial: true,
            display_background_parallax: true,
            display_chunk_boundary: false,
            display_chunk_information: false,
            display_instances: true,
            display_sun_ray: true,
            spawn_creatures: true,
            enable_lighting: true,
            enable_physics: true,
            camera_size: 1,
            fly_speed: 1,
            time_speed: 1,
            noclip: false,
            // render_texture_page: false,
        }
    }
    
    // Create the debug view
    // Store it in a global variable so we can delete it later
    global.debug_view = dbg_view("Debug", true, -1, -1, 400, 600);
    
    // --- General Section ---
    dbg_section("General");
    
    global.debug_overlay_hint = "F3 to toggle overlay";
    dbg_text(ref_create(global, "debug_overlay_hint"));
    
    dbg_button("Reload Data", function()
    {
        // Placeholder for data reload logic
        show_debug_message("Reloading data...");
    });
    
    dbg_same_line();
    dbg_button("Restart Game", function()
    {
        game_restart();
    });
    
    // --- Stats Section ---
    dbg_section("Stats");
    dbg_watch(ref_create(global.dbg_settings, "fps_real"), "FPS Real");
    dbg_watch(ref_create(global.dbg_settings, "fps"), "FPS");

    
    dbg_checkbox(ref_create(global.dbg_settings, "delta_time"), "Use Delta Time");
    
    // --- Rendering Section ---
    dbg_section("Rendering");
    
    dbg_checkbox(ref_create(global.dbg_settings, "display_background_celestial"), "Celestial Background");
    dbg_checkbox(ref_create(global.dbg_settings, "display_background_parallax"), "Parallax Background");
    dbg_checkbox(ref_create(global.dbg_settings, "enable_lighting"), "Enable Lighting");
    dbg_checkbox(ref_create(global.dbg_settings, "display_sun_ray"), "Sun Rays");
    dbg_checkbox(ref_create(global.dbg_settings, "display_chunk_boundary"), "Chunk Bounds");
    dbg_checkbox(ref_create(global.dbg_settings, "display_chunk_information"), "Chunk Info");
    dbg_checkbox(ref_create(global.dbg_settings, "display_instances"), "Show Instances");
    
    // dbg_checkbox(ref_create(global.dbg_settings, "render_texture_page"), "Show Texture Page");
    
    // --- Gameplay Section ---
    dbg_section("Gameplay");
    
    dbg_checkbox(ref_create(global.dbg_settings, "enable_physics"), "Enable Physics");
    dbg_checkbox(ref_create(global.dbg_settings, "noclip"), "Noclip");
    dbg_checkbox(ref_create(global.dbg_settings, "spawn_creatures"), "Spawn Creatures");
    dbg_slider(ref_create(global.dbg_settings, "time_speed"), 0, 24, "Time Speed", 0.25);
    dbg_slider(ref_create(global.dbg_settings, "fly_speed"), 0.5, 64, "Fly Speed");
    
    // Camera
    dbg_slider(ref_create(global.dbg_settings, "camera_size"), 0.25, 4.0, "Camera Zoom");
    
    // --- Inventory Section ---
    dbg_section("Inventory");
    
    dbg_button("Randomize", function()
    {
        var _item_data = global.item_data;
        var _names  = struct_get_names(_item_data);
        var _length = array_length(_names) - 1;
        
        for (var i = 0; i < global.inventory_length.base; ++i)
        {
            var _item_id = _names[irandom(_length)];
            var _data = _item_data[$ _item_id];
            var _item = new Inventory(_item_id, _data.get_inventory_max());
            
            var _item_durability = _data.get_item_durability();
            
            if (_item_durability != undefined)
            {
                _item.set_durability(irandom_range(1, _item_durability.get_amount()));
            }
            
            global.inventory.base[@ i] = _item;
        }
        
        if (instance_exists(obj_Game_Control))
        {
            obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.INVENTORY_HOTBAR | SURFACE_REFRESH_BOOL.INVENTORY_BACKPACK;
            inventory_refresh_craftable(true);
        }
    });
    
    dbg_same_line();
    
    dbg_button("Clear", function()
    {
        global.inventory.base = array_create(global.inventory_length.base, INVENTORY_EMPTY);
        if (instance_exists(obj_Game_Control))
        {
            obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.INVENTORY_HOTBAR | SURFACE_REFRESH_BOOL.INVENTORY_BACKPACK;
        }
    });

    // --- Information Section ---
    dbg_section("Information");
    dbg_text(ref_create(self, "debug_text"));
    
    // System Information Cache
    global.debug_sysinfo = {
        username: "",
        hostname: "",
        cpu_name: "",
        core_count: 0,
        cpu_frequency: 0,
        gpu_name: "",
        gpu_vram: 0,
        sys_memory_used: 0,
        memory_max: 0,
        proc_memory_used: 0,
        sys_cpu_usage: 0,
        proc_cpu_usage: 0,
        gpu_usage: 0
    }
    global.debug_sysinfo_index = 0;
    global.debug_sysinfo_text = "";
    global.debug_sysinfo_timer = 0;
    
    ui_editor_init();
}

/// @function debug_cleanup()
/// @desc Clean up the debug overlay
function debug_cleanup()
{
    if (variable_global_exists("debug_view") && global.debug_view != undefined)
    {
        dbg_view_delete(global.debug_view);
        global.debug_view = undefined;
    }
}

/// @function debug_step()
/// @desc Update the debug overlay
function debug_step()
{
    if (!IS_DEVELOPER_MODE) exit;
    
    // Toggle overlay with F3
    if (keyboard_check_pressed(vk_f3))
    {
        var _is_enabled = is_debug_overlay_open();
        show_debug_overlay(!_is_enabled);
    }
    
    /* toggle ui editor with F4 */
    if (keyboard_check_pressed(vk_f4))
    {
        ui_editor_toggle();
    }
    
    ui_editor_step();
    
    // Only update text if overlay is visible
    if (is_debug_overlay_open())
    {
        var _player_exists = instance_exists(obj_Player);
        var _xplayer = (_player_exists ? obj_Player.x : 0);
        var _yplayer = (_player_exists ? obj_Player.y : 0);
        
        var _camera_x = global.camera_x;
        var _camera_y = global.camera_y;
        var _camera_width = global.camera_width;
        var _camera_height = global.camera_height;
        
        var _semver = program_get_version();
        
        // Staggered Refresh: Update ONE stat per frame
        var _info = global.debug_sysinfo;
        switch (global.debug_sysinfo_index)
        {
            case 0: _info.username = sysinfo_get_username(); break;
            case 1: _info.hostname = sysinfo_get_hostname(); break;
            case 2: _info.cpu_name = sysinfo_get_cpu_name(); break;
            case 3: _info.core_count = sysinfo_get_core_count(); break;
            case 4: _info.cpu_frequency = sysinfo_get_cpu_frequency(); break;
            case 5: _info.gpu_name = sysinfo_get_gpu_name(); break;
            case 6: _info.gpu_vram = sysinfo_get_gpu_vram(); break;
            case 7: _info.sys_memory_used = sysinfo_sys_memory_used(); break;
            case 8: _info.memory_max = sysinfo_get_memory_max(); break;
            case 9: _info.proc_memory_used = sysinfo_proc_memory_used(); break;
            case 10: _info.sys_cpu_usage = sysinfo_sys_cpu_usage(); break;
            case 11: _info.proc_cpu_usage = sysinfo_proc_cpu_usage(); break;
            case 12: _info.gpu_usage = sysinfo_get_gpu_usage(); break;
        }
        global.debug_sysinfo_index = (global.debug_sysinfo_index + 1) % 13;
        
        // Re-assemble text every 1 second
        if (global.debug_sysinfo_timer > 0)
        {
            global.debug_sysinfo_timer--;
        }
        else
        {
            global.debug_sysinfo_timer = 60;
            global.debug_sysinfo_text = 
                "System:\n" +
                $"{_info.username}@{_info.hostname}\n" +
                $"CPU: {_info.cpu_name} ({_info.core_count}C @ {_info.cpu_frequency}MHz)\n" +
                $"GPU: {_info.gpu_name} ({_info.gpu_vram / 1048576}MB VRAM)\n" +
                $"RAM: {_info.sys_memory_used / 1048576}/{_info.memory_max / 1048576}MB (Proc: {_info.proc_memory_used / 1048576}MB)\n" +
                $"Usage: CPU {_info.sys_cpu_usage}%/{_info.proc_cpu_usage}% | GPU {_info.gpu_usage}%";
        }

        var _text = 
            "Performance:\n" +
            $"FPS: {fps}/{fps_real} ({string_format(1000 / max(1, fps_real), 0, 2)}ms)\n" +
            $"Delta Time: {global.delta_time}\n" +
            "\n" +
            
            "Positions:\n" +
            $"Player: ({_xplayer}, {_yplayer}) ({round(_xplayer / TILE_SIZE)}, {round(_yplayer / TILE_SIZE)})\n" +
            $"Camera: ({_camera_x}, {_camera_y}, Width = {_camera_width}, Height = {_camera_height})\n" +
            $"Mouse: ({mouse_x}, {mouse_y})\n\n" +
            
            "World:\n" +
            $"Time: {global.current_world.time}\n" +
            $"Seed: {global.current_world.seed}\n" +
            $"Chunks Loaded: {chunk_map_count()}\n" +
            $"Total Instances: {instance_number(all)}\n\n" +
            
            $"Version: {_semver}\n\n" +
            
            global.debug_sysinfo_text;
            
        if (instance_exists(obj_Game_Control))
        {
            obj_Game_Control.debug_text = _text;
        }
        
        global.dbg_settings.fps = fps;
        global.dbg_settings.fps_real = fps_real;
    }
}
