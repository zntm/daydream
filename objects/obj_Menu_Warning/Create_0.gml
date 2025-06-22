randomize();

global.delta_time = delta_time / 1_000_000;

glow_length = irandom_range(4, 8);
glow = array_create(glow_length);

var _x = room_width  / 2;
var _y = room_height / 2;

var _hue = irandom_range(30,  225);
var _sat = irandom_range(210, 245);
var _val = irandom_range(8,   14);

for (var i = 0; i < glow_length; ++i)
{
    glow[@ i] = {
        x: _x + random_range(-112, 112),
        y: _y + random_range(-112, 112),
        xvelocity: random_range(-28, 28),
        yvelocity: random_range(-28, 28),
        scale: random_range(2, 4),
        colour: make_colour_hsv(
            _hue + irandom_range(-32, 32),
            _sat + irandom_range(-14, 14),
            _val + irandom_range(-6,  6)
        )
    }
}

transition = 0;