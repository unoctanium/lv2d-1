shader_type canvas_item;

uniform float blend_amount : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 mixed = mix(tex_color.rgb, vec3(gray), blend_amount);
    COLOR = vec4(mixed, tex_color.a);
}
