shader_type canvas_item;

uniform float blur_size = 2.0;

void fragment() {
    vec2 size = blur_size / vec2(textureSize(TEXTURE, 0));
    vec4 color = vec4(0.0);

    color += texture(TEXTURE, UV - size);
    color += texture(TEXTURE, UV + size);
    color += texture(TEXTURE, UV + vec2(size.x, -size.y));
    color += texture(TEXTURE, UV + vec2(-size.x, size.y));
    color += texture(TEXTURE, UV);
    color /= 5.0;

    COLOR = color;
}
