varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_saturation;
uniform vec3  u_tint_color;
uniform float u_tint_strength;

void main()
{
    vec4 color = texture2D(gm_BaseTexture, v_vTexcoord);
    
    /* desaturate */
    float grey = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb  = mix(vec3(grey), color.rgb, u_saturation);
    
    /* tint */
    color.rgb = mix(color.rgb, color.rgb * u_tint_color, u_tint_strength);
    
    gl_FragColor = vec4(color.rgb, 1.0);
}
