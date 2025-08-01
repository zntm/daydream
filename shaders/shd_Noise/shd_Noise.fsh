// From: https://thebookofshaders.com/13/

// Author @patriciogv - 2015
// http://patriciogonzalezvivo.com

precision mediump float;

// amplitude, octave
uniform vec2 u_noise;
uniform vec2 u_offset;
uniform int u_roughness;

const vec2 RANDOM_DOT = vec2(6.9818, 7.137);

/*
float random(in vec2 st)
{
    return fract(cos(dot(st.xy, RANDOM_DOT)) * 4.54193);
}

const vec3 RANDOM_VEC3 = vec3(0.1031, 0.11369, 0.13787);

float random(in vec2 p)
{
    vec3 v = fract(vec3(p.x, p.y, p.x) * RANDOM_VEC3);
    
    v += dot(v, v.yzx + 33.33);
    
    return fract((v.x + v.y) * v.z);
}
*/

const vec2 V_10 = vec2(1.0, 0.0);
const vec2 V_01 = vec2(0.0, 1.0);
const vec2 V_11 = vec2(1.0, 1.0);

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise(in vec2 st, in float seed)
{
    vec2 i = floor(st) + seed;
    vec2 f = fract(st);
    
    /*
    float a = random(i);
    float b = random(i + V_10);
    float c = random(i + V_01);
    float d = random(i + V_11);
    */
    
    float a = fract(cos(dot(st.xy,        RANDOM_DOT)) * 4.54193);
    float b = fract(cos(dot(st.xy + V_10, RANDOM_DOT)) * 3.98117);
    float c = fract(cos(dot(st.xy + V_01, RANDOM_DOT)) * 1.31079);
    float d = fract(cos(dot(st.xy + V_11, RANDOM_DOT)) * 7.22007);
    
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
    vec2 st = (gl_FragCoord.xy + u_offset) * (SCALE_FACTOR / u_noise.x);
    
    float colour = fractal(st, u_noise.y);
    
    gl_FragColor = vec4(colour, 0.0, 0.0, 1.0);
}