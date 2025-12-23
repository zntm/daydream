xoffset = 0;
yoffset = 0;

xscale = 1;
yscale = 1;

surface_index_shader = [ undefined ];
surface_index_boundary = [ undefined ];
surface_index_length = 1;

surfaces = [];

// Fix for stuck transition state when entering game world
if (room == rm_World)
{
    global.menu_transition_phase = 0;
    global.menu_transition_alpha = 1;
    global.menu_transition_scale = 1;
    global.menu_blur_alpha = 0;
    
    // Center the pause menu on the surface
    // Center is 480, 270 (Base 960x540 resolution)
    // Surface Center Target = 480, 270
    // Matrix Scale = 0.5
    // Render Scale = 1
    // Formula: (Offset + Center) * RenderScale * MatrixScale = Target
    // (Off + 480) * 1 * 0.5 = 480 -> Off + 480 = 960 -> Off = 480
    xscale = 1;
    yscale = 1;
    xoffset = 480;
    yoffset = 270;
}