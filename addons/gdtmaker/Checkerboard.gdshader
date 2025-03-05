// https://godotshaders.com/shader/simple-checkerboard/
shader_type canvas_item;

uniform float width;
uniform float height;
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0); 
uniform vec4 color2 : source_color = vec4(0.7, 0.7, 0.7, 1.0);

void fragment() {
    vec2 pos = floor(UV.xy * vec2(width, height));
    float pattern_mask = mod(pos.x + mod(pos.y, 2.0), 2.0);
    COLOR = mix(color1, color2, pattern_mask);
}