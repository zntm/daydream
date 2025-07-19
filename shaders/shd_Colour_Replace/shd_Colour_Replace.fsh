//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int u_match[256];
uniform int u_replace[256];
uniform int u_length;

const float range = 1.0 / 255.0;

void main()
{
    vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
    
    for (int i = 0; i < u_length; ++i)
    {
        float matched = float(u_match[i]);
        
        if (
            abs(base.r - floor(mod(matched,           256.0)) / 255.0) <= range &&
            abs(base.g - floor(mod(matched / 256.0,   256.0)) / 255.0) <= range &&
            abs(base.b - floor(mod(matched / 65536.0, 256.0)) / 255.0) <= range
        )
        {
            float re = float(u_replace[i]);
            
            base.rgb = vec3(
                floor(mod(re,           256.0)) / 255.0,
                floor(mod(re / 256.0,   256.0)) / 255.0,
                floor(mod(re / 65536.0, 256.0)) / 255.0
            );
            
            break;
        }
    }
    
    gl_FragColor = base;
}
