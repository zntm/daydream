varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_storm_intensity;

void main()
{
    vec4 color = texture2D(gm_BaseTexture, v_vTexcoord);
    
    /* desaturate */
    float grey = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb  = mix(color.rgb, vec3(grey), u_storm_intensity * 0.6);
    
    /* tint slightly blue-grey for storm feel */
    vec3 storm_tint = vec3(0.75, 0.82, 0.9);
    color.rgb = mix(color.rgb, color.rgb * storm_tint, u_storm_intensity * 0.4);
    
    gl_FragColor = vec4(color.rgb, 1.0);
}
