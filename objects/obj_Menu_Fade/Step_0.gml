image_alpha += transition_speed * global.delta_time;

if (transition_speed > 0)
{
    if (image_alpha >= 1)
    {
        room_goto(transition_room);
    }
}
else if (image_alpha <= 0)
{
    instance_destroy();
}