// From: https://thebookofshaders.com/13/

// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com

precision lowp float;

// amplitude, octave
uniform vec2 u_noise;
uniform vec2 u_offset;
uniform int u_roughness;

/*
const vec2 random_offset = vec2(12.9898, 78.233);

float random(in vec2 st, in float seed)
{
    return fract(sin(dot(st.xy, random_offset)) * (43758.5453123 + seed));
}
*/

float random(vec2 st, in float seed)
{
    return fract((fract(fract(st.x * 1699.121724) / fract(st.y * 123.3575)) * 39.33124) - seed);
}

const vec2 v_10 = vec2(1.0, 0.0);
const vec2 v_01 = vec2(0.0, 1.0);
const vec2 v_11 = vec2(1.0, 1.0);

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise(in vec2 st, in float seed)
{
    vec2 i = floor(st);
    vec2 f = fract(st);
    
    // Four corners in 2D of a tile
    float a = random(i, seed);
    float b = random(i + v_10, seed);
    float c = random(i + v_01, seed);
    float d = random(i + v_11, seed);
    
    vec2 u = f * f * (3.0 - (2.0 * f));
    
    return mix(a, b, u.x) + ((c - a) * u.y * (1.0 - u.x)) + ((d - b) * u.x * u.y);
}

float fractal(in vec2 st, in float seed)
{
    float value = 0.0;
    
    float amplitude = 0.5;
    float frequency = 0.0;
    
    for (int i = 0; i < u_roughness; ++i)
    {
        value += amplitude * noise(st, seed);
        st *= 2.0;
        amplitude *= 0.5;
    }
    
    return value;
}

#define SCALE_FACTOR (3.0 / 256.0)

void main()
{
    vec2 st = ((gl_FragCoord.xy + u_offset) * SCALE_FACTOR) / u_noise.x;
    
    float colour = fractal(st, u_noise.y);
    
    gl_FragColor = vec4(colour, 0.0, 0.0, 1.0);
}