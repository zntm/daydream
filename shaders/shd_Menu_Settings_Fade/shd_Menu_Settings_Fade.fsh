//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_FadeStart;
uniform float u_FadeEnd;

void main()
{
    vec4 base_col = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
    
    // Vertical fade properties
    float fade_size = 0.15; // Size of the fade gradient
    float alpha = 1.0;
    
    // Fade Top (Fade In)
    // From u_FadeStart - fade_size (0 alpha) to u_FadeStart (1 alpha)
    if (v_vTexcoord.y < u_FadeStart)
    {
        alpha = smoothstep(u_FadeStart - fade_size, u_FadeStart, v_vTexcoord.y);
    }
    // Fade Bottom (Fade Out)
    // From u_FadeEnd (1 alpha) to u_FadeEnd + fade_size (0 alpha)
    else if (v_vTexcoord.y > u_FadeEnd)
    {
        // alpha = 1.0 - smoothstep(min, max, val)
        alpha = 1.0 - smoothstep(u_FadeEnd, u_FadeEnd + fade_size, v_vTexcoord.y);
    }
    
    base_col.a *= alpha;
    
    gl_FragColor = base_col;
}
