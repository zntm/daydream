//
// Storm post-processing fragment shader
// Darkens and desaturates based on storm intensity
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_storm_intensity;

void main()
{
    vec4 color = texture2D(gm_BaseTexture, v_vTexcoord);
    
    /* desaturate via luminance blend */
    vec3 luma = vec3(0.299, 0.587, 0.114);
    float grey = dot(color.rgb, luma);
    
    color.rgb = mix(color.rgb, vec3(grey), u_storm_intensity * 0.5);
    
    /* darken */
    color.rgb *= mix(1.0, 0.4, u_storm_intensity);
    
    gl_FragColor = vec4(color.rgb, 1.0);
}
