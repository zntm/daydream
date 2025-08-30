randomize();

glow_length = irandom_range(16, 40);
glow = array_create(glow_length);

var _x = room_width  / 2;
var _y = room_height / 2;

hue = colour_get_hue(global.credit_data[0].colour);
sat = irandom_range(210, 245);
val = irandom_range(8,   14);

for (var i = 0; i < glow_length; ++i)
{
    glow[@ i] = {
        value: random(360),
        increment: random_range(0.1, 1),
        scale: random_range(2, 4),
        colour_offset: [
            irandom_range(-4,  4),
            irandom_range(-14, 14),
            irandom_range(-6,  6)
        ]
    }
}

list_offset = 0;
scroll_speed = 0;

is_escaping = false;