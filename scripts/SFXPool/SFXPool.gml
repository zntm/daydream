/// @desc Pool system for audio emitters
function SFXPool() : Pool() constructor
{
    static create = function()
    {
        return audio_emitter_create();
    }
    
    static destroy = function(_emitter)
    {
        if (audio_emitter_exists(_emitter))
        {
            audio_emitter_free(_emitter);
        }
    }
    
    static on_release = function(_emitter)
    {
        if (audio_emitter_exists(_emitter))
        {
            // Reset to main bus (remove effects)
            audio_emitter_bus(_emitter, audio_bus_main);
            
            // Allow recycling of gain/pitch/position if needed, 
            // but these are usually overwritten on play in sfx_diegetic_play
            // Except position is set in sfx_diegetic_play: audio_emitter_position(_emitter, _x, _y, 0);
        }
    }

    static acquire = function()
    {
        return get_free_item();
    }
}

global.sfx_pool = new SFXPool();
