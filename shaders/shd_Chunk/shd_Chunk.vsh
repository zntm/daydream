#define CHUNK_SIZE 16
#define CHUNK_DEPTH 8

attribute vec3 in_Position;
// attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

attribute vec2 in_TextureData;

varying vec2 v_vTexcoord;
varying vec2 v_vTexcoord2;
varying vec4 v_vColour;
varying float v_vMixAmount;

uniform float u_time;
uniform float u_texel_width;
uniform float u_skew[CHUNK_SIZE * CHUNK_SIZE];
uniform float u_wave[CHUNK_SIZE * CHUNK_SIZE];
uniform float u_fade;

const vec4 COLOUR_ALPHA = vec4(1.0, 1.0, 1.0, 1.0);

void main()
{
    v_vColour = COLOUR_ALPHA;
    v_vColour.a *= u_fade;
    
    v_vTexcoord = in_TextureCoord;
    v_vTexcoord2 = in_TextureCoord;
    v_vMixAmount = 0.0;
    
    // in_TextureData.x = packed animation data:
    //   number << 24 | mix_flag << 15 | anim_fps_x8 << 8 | animation_type
    // foliage / wave reuse bits 16-23 for chunk-local lookup indices.
    // in_TextureData.y = frame_index | (sprite_width << 8) | (frame_count << 16)
    
    float animation_type = mod(in_TextureData.x, 256.0);
    float packed_flags = mod(floor(in_TextureData.x / 256.0), 256.0);
    float animation_fps = mod(packed_flags, 128.0) / 8.0;
    float mix_frames = step(128.0, packed_flags);
    
    // Unpack index and width from in_TextureData.y
    float packed_index_width = in_TextureData.y;
    float frame_index = mod(packed_index_width, 256.0);
    float sprite_width = mod(floor(packed_index_width / 256.0), 256.0);
    float number = floor(packed_index_width / 65536.0);
    
    // Calculate UV offset in shader: width * texel_width
    float uv_offset = sprite_width * u_texel_width;
    
    // Default (animation_type 0, 1, 2)
    if (animation_type <= 2.0)
    {
        v_vTexcoord.x += frame_index * uv_offset;
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    }
    // Increment (animation_type 3)
    else if (animation_type < 4.0)
    {
        float frame_count = max(number, 1.0);
        float frame_time = u_time * max(animation_fps, 0.0001);
        float current_frame = mod(floor(frame_time), frame_count);

        v_vTexcoord.x += (frame_index + current_frame) * uv_offset;
        v_vTexcoord2 = v_vTexcoord;
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    }
    // Foliage (animation_type 4)
    else if (animation_type < 5.0)
    {
        int skew_index = int(mod(floor(in_TextureData.x / 65536.0), 256.0));
        
        v_vTexcoord.x += frame_index * uv_offset;
        v_vTexcoord2 = v_vTexcoord;
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x + u_skew[skew_index], in_Position.y, 0.0, 1.0);
    }
    // Wave (animation_type 5) - liquid surface bobbing straight up/down
    else if (animation_type < 6.0)
    {
        int wave_index = int(mod(floor(in_TextureData.x / 65536.0), 256.0));
        float force_bob = u_wave[wave_index];

        v_vTexcoord.x += frame_index * uv_offset;
        v_vTexcoord2 = v_vTexcoord;

        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y + force_bob, 0.0, 1.0);
    }
    // Crossfade (animation_type 6)
    else
    {
        float frame_count = max(number, 1.0);
        float frame_time = u_time * max(animation_fps, 0.0001);
        float current_frame = mod(floor(frame_time), frame_count);

        if ((mix_frames > 0.0) && (frame_count > 1.0))
        {
            float next_frame = mod(current_frame + 1.0, frame_count);

            v_vTexcoord.x += (frame_index + current_frame) * uv_offset;
            v_vTexcoord2.x += (frame_index + next_frame) * uv_offset;
            v_vMixAmount = fract(frame_time);
        }
        else
        {
            v_vTexcoord.x += (frame_index + current_frame) * uv_offset;
            v_vTexcoord2 = v_vTexcoord;
        }

        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    }
}
