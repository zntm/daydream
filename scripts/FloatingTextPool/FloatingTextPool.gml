function FloatingTextPool() : Pool() constructor
{
    static create = function()
    {
        return {
            x: 0,
            y: 0,
            image_xscale: 1,
            image_yscale: 1,
            image_blend: c_white,
            image_alpha: 1,
            image_angle: 0,
            text: "",
            xvelocity: 0,
            yvelocity: 0,
            rotation: 0,
            timer_life: 0
        }
    }
}
