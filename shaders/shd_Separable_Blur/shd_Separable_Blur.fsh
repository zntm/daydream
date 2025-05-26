varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_direction;

uniform float u_blur_size;
uniform vec2 u_texel_size;

uniform int u_radius;
uniform float u_sigma;

float gaussian(float x, float sigma)
{
    return exp(-(0.5 * x * x) / (sigma * sigma)) / (2.50662827463 * sigma);
}

void main()
{
    vec4 colour = vec4(0.0);
    float total_weight = 0.0;
    
    for (int i = -u_radius; i <= u_radius; ++i)
    {
        vec2 offset = float(i) * u_blur_size * u_texel_size;
        float weight = gaussian(float(i), u_sigma);
        
        colour += texture2D(gm_BaseTexture, v_vTexcoord + (u_direction * offset)) * weight;
        total_weight += weight;
    }
    
    colour /= total_weight;
    
    gl_FragColor = v_vColour * colour;
}