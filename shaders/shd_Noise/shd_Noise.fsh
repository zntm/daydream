// From: https://thebookofshaders.com/13/

// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com

precision mediump float;

// x offset, y offset, amplitude, octave
uniform vec4 u_noise;
uniform int u_roughness;

const vec2 RANDOM_DOT = vec2(6.9818, 7.137);

const vec2 V_10 = vec2(1.0, 0.0);
const vec2 V_01 = vec2(0.0, 1.0);
const vec2 V_11 = vec2(1.0, 1.0);

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise(in vec2 st, in float seed)
{
    vec2 i = floor(st) + seed;
    
    float a = fract(cos(dot(i,        RANDOM_DOT)) * 4.54193);
    float b = fract(cos(dot(i + V_10, RANDOM_DOT)) * 4.54193);
    float c = fract(cos(dot(i + V_01, RANDOM_DOT)) * 4.54193);
    float d = fract(cos(dot(i + V_11, RANDOM_DOT)) * 4.54193);
    
    vec2 f = fract(st);
    vec2 u = f * f * (3.0 - (2.0 * f));
    
    float nx0 = mix(a, b, u.x);
    float nx1 = mix(c, d, u.x);
    
    return mix(nx0, nx1, u.y);
}

const vec3 FRACTCAL_BATCH_MULTIPLIER = vec3(2.0, 2.0, 0.5);

float fractal(in vec2 st, in float seed)
{
    float value = 0.0;
    
    vec3 batch = vec3(st.x, st.y, 0.5);
    
    for (int i = 0; i < u_roughness; ++i)
    {
        value += batch.z * noise(batch.xy, seed);
        
        batch *= FRACTCAL_BATCH_MULTIPLIER;
    }
    
    return value;
}

const float SCALE_FACTOR = 3.0 / 256.0;

void main()
{
    vec2 st = (gl_FragCoord.xy + u_noise.xy) * (SCALE_FACTOR / u_noise.z);
    
    float colour = fractal(st, u_noise.w);
    
    gl_FragColor = vec4(colour, 0.0, 0.0, 1.0);
}