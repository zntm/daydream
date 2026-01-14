/// @desc Initialize Loom editor

// Create a test graph
graph = new LoomGraph("Test Graph");

// Camera/view
view_x = 0;
view_y = 0;
view_scale = 1.0;

// Interaction state
dragging_nodes = false;
drag_offset_x = 0;
drag_offset_y = 0;

connecting_from_pin = undefined;
connecting_from_node = undefined;

// Context menu
context_menu_open = false;
context_menu_x = 0;
context_menu_y = 0;
context_menu_width = 200;
context_menu_hover_category = undefined;
context_menu_active_category = undefined;

// Node Categories
node_categories = {
    "Math": ["Constant", "Add", "Subtract", "Multiply", "Divide", "Max", "Min", "Clamp", "Lerp", "Abs"],
    "Logic": ["Compare", "AND", "OR", "NOT"],
    "Data": ["Color", "String", "Array", "Spline"],
    "Generators": ["Simplex Noise", "Simplex Noise 3D", "Random", "Noise Config"],
    "Terrain": ["Terrain Gradient", "Continentalness", "Peaks", "Squashed Noise", "Erosion", "Terrain Combine", "Terrain Shaping"],
    "Cave": ["Cave Swiss", "Cave Noodle", "Cave Settings", "Aquifer"],
    "World Config": ["World Settings", "Time Settings", "Vignette", "Surface Settings"],
    "Sky": ["Sky Settings", "Celestial Body"],
    "Biome": ["Biome"],
    "Input": ["Coordinate", "Seed", "World Data"],
    "World Data": ["Surface Height", "Get Biome", "Terrain Density"],
    "Output": ["Result"]
};

// Selection
selected_nodes = [];
selection_box_active = false;
selection_box_start_x = 0;
selection_box_start_y = 0;

// Preview
preview_surface = -1;
preview_width = 200;
preview_height = 450; // Taller default to see Y=400 surface
preview_dirty = true;
preview_scale = 1;
preview_resizing = false;
preview_current_col = 0;       // Progressive rendering: current col
preview_cols_per_frame = 1;   // Faster rendering (16 columns per frame)
preview_view_offset_y = 200;   // Vertical offset for terrain preview

// Mouse tracking (must initialize to avoid jump on first pan)
mouse_last_x = mouse_x;
mouse_last_y = mouse_y;

// Constant node text editing
editing_constant_node = undefined;
editing_constant_text = "";
last_click_time = 0;
last_clicked_node = undefined;

// Attribute editing
editing_attr_node = undefined;
editing_attr_name = "";
editing_attr_text = "";

// Color picker popup
color_picker_open = false;
color_picker_node = undefined;
color_picker_attr = "";
color_picker_hue = 0;
color_picker_sat = 1;
color_picker_val = 1;

// Grid settings
grid_size = 20;
grid_color = make_color_rgb(40, 40, 45);
background_color = make_color_rgb(30, 30, 35);

// Node colors
node_header_color = make_color_rgb(80, 80, 100);
node_body_color = make_color_rgb(50, 50, 60);
node_selected_color = make_color_rgb(100, 150, 200);
pin_color_value = make_color_rgb(150, 200, 100);
pin_color_bool = make_color_rgb(200, 100, 100);
pin_color_struct = make_color_rgb(100, 150, 200);
pin_color_any = make_color_rgb(200, 200, 200);
pin_color_color = make_color_rgb(255, 100, 200);   // Magenta for color type
pin_color_string = make_color_rgb(255, 180, 80);   // Orange for string type
pin_color_spline = make_color_rgb(80, 200, 255);   // Cyan for spline type
connection_color = make_color_rgb(180, 180, 200);

// --- Create Terrain Demo Graph (TerrainShaper 1:1 Port) ---
graph = new LoomGraph("TerrainShaper Port");

var _coord = loom_create_node("Coordinate"); _coord.set_position(50, 400); graph.add_node(_coord);

// Constants (Keep them for editing)
var _c_base = loom_create_node("Constant"); _c_base.constant_value = 512; _c_base.display_name = "Base Height"; _c_base.set_position(50, 100); graph.add_node(_c_base);
var _c_grad = loom_create_node("Constant"); _c_grad.constant_value = 0.006; _c_grad.display_name = "Grad Str"; _c_grad.set_position(50, 200); graph.add_node(_c_grad);
var _c_cont = loom_create_node("Constant"); _c_cont.constant_value = 180; _c_cont.display_name = "Cont Amp"; _c_cont.set_position(50, 300); graph.add_node(_c_cont);
var _c_peak = loom_create_node("Constant"); _c_peak.constant_value = 100; _c_peak.display_name = "Peak Amp"; _c_peak.set_position(50, 0); graph.add_node(_c_peak);
var _c_squash = loom_create_node("Constant"); _c_squash.constant_value = 4.0; _c_squash.display_name = "Squash"; _c_squash.set_position(50, 500); graph.add_node(_c_squash);

// Component Nodes
var _grad = loom_create_node("Terrain Gradient"); _grad.set_position(300, 200); graph.add_node(_grad);
graph.connect(_coord.get_output("y"), _grad.get_input("y"));
graph.connect(_c_base.get_output("value"), _grad.get_input("base"));
graph.connect(_c_grad.get_output("value"), _grad.get_input("strength"));

var _cont = loom_create_node("Continentalness"); _cont.set_position(300, 400); graph.add_node(_cont);
graph.connect(_coord.get_output("x"), _cont.get_input("x"));
graph.connect(_c_cont.get_output("value"), _cont.get_input("amp"));
graph.connect(_c_grad.get_output("value"), _cont.get_input("grad_str"));

var _peaks = loom_create_node("Peaks"); _peaks.set_position(300, 0); graph.add_node(_peaks);
graph.connect(_coord.get_output("x"), _peaks.get_input("x"));
graph.connect(_c_peak.get_output("value"), _peaks.get_input("amp"));
graph.connect(_c_grad.get_output("value"), _peaks.get_input("grad_str"));

// Adjustment: Gradient - Cont - Peaks
var _sub1 = loom_create_node("Subtract"); _sub1.set_position(550, 200); graph.add_node(_sub1);
graph.connect(_grad.get_output("value"), _sub1.get_input("a"));
graph.connect(_cont.get_output("value"), _sub1.get_input("b"));

var _sub2 = loom_create_node("Subtract"); _sub2.set_position(700, 200); graph.add_node(_sub2);
graph.connect(_sub1.get_output("result"), _sub2.get_input("a"));
graph.connect(_peaks.get_output("value"), _sub2.get_input("b"));

// 3D Noise (Squashed)
var _sq_noise = loom_create_node("Squashed Noise"); _sq_noise.set_position(300, 600); graph.add_node(_sq_noise);
graph.connect(_coord.get_output("x"), _sq_noise.get_input("x"));
graph.connect(_coord.get_output("y"), _sq_noise.get_input("y"));
graph.connect(_coord.get_output("z"), _sq_noise.get_input("z"));
graph.connect(_c_squash.get_output("value"), _sq_noise.get_input("squash"));

// Erosion
var _erosion = loom_create_node("Erosion"); _erosion.set_position(300, 800); graph.add_node(_erosion);
graph.connect(_coord.get_output("x"), _erosion.get_input("x"));
graph.connect(_coord.get_output("y"), _erosion.get_input("y"));

// Combine
var _combine = loom_create_node("Terrain Combine"); _combine.set_position(900, 400); graph.add_node(_combine);
graph.connect(_sub2.get_output("result"), _combine.get_input("gradient"));
graph.connect(_sq_noise.get_output("value"), _combine.get_input("noise3d"));
graph.connect(_erosion.get_output("value"), _combine.get_input("erosion"));

// --- Cave System ---
var _c_swiss = loom_create_node("Cave Swiss"); _c_swiss.set_position(900, 600); graph.add_node(_c_swiss);
graph.connect(_coord.get_output("x"), _c_swiss.get_input("x"));
graph.connect(_coord.get_output("y"), _c_swiss.get_input("y"));
graph.connect(_c_squash.get_output("value"), _c_swiss.get_input("squash"));

var _c_noodle1 = loom_create_node("Cave Noodle"); _c_noodle1.set_position(900, 800); graph.add_node(_c_noodle1);
graph.connect(_coord.get_output("x"), _c_noodle1.get_input("x"));
graph.connect(_coord.get_output("y"), _c_noodle1.get_input("y"));
graph.connect(_c_squash.get_output("value"), _c_noodle1.get_input("squash"));
_c_noodle1.set_attribute("range_min", 50);
_c_noodle1.set_attribute("range_max", 70);

var _c_noodle2 = loom_create_node("Cave Noodle"); _c_noodle2.set_position(900, 1000); graph.add_node(_c_noodle2);
graph.connect(_coord.get_output("x"), _c_noodle2.get_input("x"));
graph.connect(_coord.get_output("y"), _c_noodle2.get_input("y"));
graph.connect(_c_squash.get_output("value"), _c_noodle2.get_input("squash"));
_c_noodle2.set_attribute("range_min", 116);
_c_noodle2.set_attribute("range_max", 140);

// Combine Caves
var _max1 = loom_create_node("Max"); _max1.set_position(1150, 700); graph.add_node(_max1);
graph.connect(_c_swiss.get_output("value"), _max1.get_input("a"));
graph.connect(_c_noodle1.get_output("value"), _max1.get_input("b"));

var _max2 = loom_create_node("Max"); _max2.set_position(1300, 800); graph.add_node(_max2);
graph.connect(_max1.get_output("result"), _max2.get_input("a"));
graph.connect(_c_noodle2.get_output("value"), _max2.get_input("b"));

// Carve Caves out of Terrain
var _carve = loom_create_node("Subtract"); _carve.set_position(1100, 400); graph.add_node(_carve);
graph.connect(_combine.get_output("value"), _carve.get_input("a"));
graph.connect(_max2.get_output("result"), _carve.get_input("b"));

// Result
var _res = loom_create_node("Result"); _res.set_position(1500, 400); graph.add_node(_res);
graph.connect(_carve.get_output("result"), _res.get_input("value"));
