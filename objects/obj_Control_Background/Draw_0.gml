var _colour = global.biome_data[$ in_biome.id];

draw_sprite_ext(
    spr_Square,
    0,
    camera_get_view_x(view_camera[0]),
    camera_get_view_y(view_camera[0]),
    camera_get_view_width(view_camera[0]),
    camera_get_view_height(view_camera[0]),
    0,
    _colour.get_sky_colour_base("day"),
    1
);