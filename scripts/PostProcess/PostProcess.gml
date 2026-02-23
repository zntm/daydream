/// @desc Multi-pass post-processing pipeline for stackable shader effects.
function PostProcess() constructor
{
    passes = [];
    surface_a = -1;
    surface_b = -1;
    
    /// @function add_pass(_shader, _uniforms_fn, _enabled)
    /// @desc Register a shader pass with a uniform-setting callback.
    /// @param {Asset.GMShader} _shader The shader resource.
    /// @param {Function} _uniforms_fn Function called before drawing to set uniforms.
    /// @param {Bool} [_enabled] Whether the pass starts enabled (default: true).
    static add_pass = function(_shader, _uniforms_fn, _enabled = true)
    {
        array_push(passes, {
            shader:      _shader,
            uniforms_fn: _uniforms_fn,
            enabled:     _enabled
        });
        
        return self;
    }
    
    /// @function remove_pass(_shader)
    /// @desc Remove a pass by shader resource.
    /// @param {Asset.GMShader} _shader The shader to remove.
    static remove_pass = function(_shader)
    {
        for (var i = array_length(passes) - 1; i >= 0; --i)
        {
            if (passes[i].shader == _shader)
            {
                array_delete(passes, i, 1);
                
                break;
            }
        }
        
        return self;
    }
    
    /// @function set_enabled(_shader, _enabled)
    /// @desc Enable or disable a specific pass.
    /// @param {Asset.GMShader} _shader The shader to toggle.
    /// @param {Bool} _enabled Whether the pass is enabled.
    static set_enabled = function(_shader, _enabled)
    {
        for (var i = array_length(passes) - 1; i >= 0; --i)
        {
            if (passes[i].shader == _shader)
            {
                passes[@ i].enabled = _enabled;
                
                break;
            }
        }
        
        return self;
    }
    
    /// @function apply(_width, _height)
    /// @desc Apply all enabled passes to the application_surface via ping-pong rendering.
    /// @param {Real} _width Surface width.
    /// @param {Real} _height Surface height.
    static apply = function(_width, _height)
    {
        var _old_target = surface_get_target();
        
        /* count active passes first to avoid unnecessary surface work */
        var _active_count = 0;
        
        for (var i = array_length(passes) - 1; i >= 0; --i)
        {
            if (passes[i].enabled)
            {
                ++_active_count;
            }
        }
        
        if (_active_count <= 0) exit;
        
        /* ensure surfaces exist at correct size */
        if (!surface_exists(surface_a)) || (surface_get_width(surface_a) != _width) || (surface_get_height(surface_a) != _height)
        {
            if (surface_exists(surface_a))
            {
                surface_free(surface_a);
            }
            
            surface_a = surface_create(_width, _height);
        }
        
        if (!surface_exists(surface_b)) || (surface_get_width(surface_b) != _width) || (surface_get_height(surface_b) != _height)
        {
            if (surface_exists(surface_b))
            {
                surface_free(surface_b);
            }
            
            surface_b = surface_create(_width, _height);
        }
        
        /* copy application_surface into surface_a */
        surface_copy(surface_a, 0, 0, application_surface);
        
        /* ping-pong through each enabled pass */
        var _src = surface_a;
        var _dst = surface_b;
        
        for (var i = 0; i < array_length(passes); ++i)
        {
            var _pass = passes[i];
            
            if (!_pass.enabled) continue;
            
            surface_set_target(_dst);
            draw_clear_alpha(c_black, 0);
            
            shader_set(_pass.shader);
            
            _pass.uniforms_fn();
            
            gpu_set_blendmode_ext(bm_one, bm_zero);
            
            draw_surface(_src, 0, 0);
            
            gpu_set_blendmode(bm_normal);
            
            shader_reset();
            surface_reset_target();
            
            /* swap surfaces */
            var _tmp = _src;
            
            _src = _dst;
            _dst = _tmp;
        }
        
        /* draw final result back into application_surface */
        surface_set_target(application_surface);
        draw_clear_alpha(c_black, 0);
        
        gpu_set_blendmode_ext(bm_one, bm_zero);
        
        draw_surface(_src, 0, 0);
        
        gpu_set_blendmode(bm_normal);
        
        surface_reset_target();
        
        /* restore original target if it wasn't application_surface */
        if (_old_target != -1) && (_old_target != application_surface)
        {
            surface_set_target(_old_target);
        }
    }
    
    /// @function cleanup()
    /// @desc Free surfaces when no longer needed.
    static cleanup = function()
    {
        if (surface_exists(surface_a))
        {
            surface_free(surface_a);
        }

        if (surface_exists(surface_b))
        {
            surface_free(surface_b);
        }
        
        surface_a = -1;
        surface_b = -1;
    }
}

global.post_process = new PostProcess();
