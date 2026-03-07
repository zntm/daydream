/// @desc Initialise all in-game declarative UI panels (hotbar, inventory, crafting, chat, choices, effects).
/// @param {Real} _logical_width  Logical design width in UI units.
/// @param {Real} _logical_height Logical design height in UI units.
function control_game_ui_init(_logical_width, _logical_height)
{
    var _hotbar_def = ui_load("ui/hotbar.ui");

    global.ui_hotbar = ui_spawn(_hotbar_def, {
        link:   {},
        parent: global.gui_root
    }, ["inventory_changed"]);

    global.gui_panel_hotbar_modular = global.ui_hotbar;

    var _inventory_def = ui_load("ui/inventory.ui");

    global.ui_inventory = ui_spawn(_inventory_def, {
        link:   {},
        parent: global.gui_root
    }, ["inventory_changed"]);

    global.gui_panel_inventory_modular = global.ui_inventory;
    global.ui_inventory.visible        = false;

    global.ui_crafting_def      = ui_load("ui/crafting.ui");
    global.ui_crafting_slot_def = ui_load("ui/crafting_slot.ui");

    global.ui_crafting = ui_spawn(global.ui_crafting_def, {
        link:   {},
        parent: global.gui_root
    });

    global.ui_crafting.visible = false;

    var _chest_pull_btn = global.ui_crafting.elements[$ "btn_chest_pull"];

    if (_chest_pull_btn != undefined)
    {
        _chest_pull_btn.add_event_handler("on_select_release", function()
        {
            global.crafting_pull_from_chests = !global.crafting_pull_from_chests;
            self.text = "PULL FROM CHESTS is " + (global.crafting_pull_from_chests ? "ON" : "OFF");

            inventory_refresh_craftable();
        });
    }

    global.gui_panel_crafting_modular = global.ui_crafting.root_elements[0];

    global.gui_panel_chat = new GUIChatHistory(8, _logical_height - 160, 300, 128, 8);
    global.gui_root.add_child(global.gui_panel_chat);

    global.gui_panel_choices = new GUIChoicePanel((_logical_width - 300) / 2, _logical_height / 2 - 50, 300);
    global.gui_panel_choices.visible = false;
    global.gui_root.add_child(global.gui_panel_choices);

    global.gui_panel_effects = new GUIEffectPanel(0, 0);
    global.gui_panel_effects.offset_x = 16;
    global.gui_panel_effects.offset_y = 16;
    global.gui_panel_effects.set_anchor("right", "bottom");
    global.gui_root.add_child(global.gui_panel_effects);
}
