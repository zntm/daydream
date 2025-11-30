//
// Lighting fragment shader with edge dithering
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_resolution;

// Bayer matrix 4x4 for dithering
const mat4 bayerMatrix = mat4(
    0.0/16.0,  8.0/16.0,  2.0/16.0, 10.0/16.0,
    12.0/16.0, 4.0/16.0, 14.0/16.0,  6.0/16.0,
    3.0/16.0, 11.0/16.0,  1.0/16.0,  9.0/16.0,
    15.0/16.0, 7.0/16.0, 13.0/16.0,  5.0/16.0
);

void main()
{
    float r = texture2D(gm_BaseTexture, v_vTexcoord).r;
    
    // Calculate distance from edge (0.0 = black/edge, 1.0 = full white/center)
    // We want to dither when r is in the range [0.0, ~0.25] (about 4 pixels worth)
    // float ditherThreshold = 0.25;
    
    float finalValue = r;
    /*
    if (r > 0.0 && r < ditherThreshold)
    {
        // Get pixel position for bayer matrix
        vec2 pixelPos = v_vTexcoord * u_resolution;
        int x = int(mod(pixelPos.x, 4.0));
        int y = int(mod(pixelPos.y, 4.0));
        
        // Get dither threshold from bayer matrix
        // Note: GLSL ES 1.0 doesn't support dynamic array indexing for matrices easily in all drivers
        // but constant index is fine. We need to access the matrix element.
        // Since we can't easily index a mat4 with variables in older GLSL without a loop or if-else chain,
        // let's use a simpler function or if-else for compatibility.
        
        float bayerValue = 0.0;
        if (x == 0) {
            if (y == 0) bayerValue = 0.0/16.0;
            else if (y == 1) bayerValue = 12.0/16.0;
            else if (y == 2) bayerValue = 3.0/16.0;
            else bayerValue = 15.0/16.0;
        } else if (x == 1) {
            if (y == 0) bayerValue = 8.0/16.0;
            else if (y == 1) bayerValue = 4.0/16.0;
            else if (y == 2) bayerValue = 11.0/16.0;
            else bayerValue = 7.0/16.0;
        } else if (x == 2) {
            if (y == 0) bayerValue = 2.0/16.0;
            else if (y == 1) bayerValue = 14.0/16.0;
            else if (y == 2) bayerValue = 1.0/16.0;
            else bayerValue = 13.0/16.0;
        } else {
            if (y == 0) bayerValue = 10.0/16.0;
            else if (y == 1) bayerValue = 6.0/16.0;
            else if (y == 2) bayerValue = 9.0/16.0;
            else bayerValue = 5.0/16.0;
        }
        
        // Normalize r to 0-1 range within the dither zone
        float normalizedR = r / ditherThreshold;
        
        // Apply dithering: if normalizedR is less than bayer value, make it black
        finalValue = (normalizedR > bayerValue) ? r : 0.0;
    }
    */
    gl_FragColor = v_vColour * vec4(finalValue, finalValue, finalValue, 1.0);
}
