shader_type canvas_item;

uniform sampler2D mask_texture : filter_nearest;
uniform vec4 cover_color : source_color = vec4(0.55, 0.57, 0.62, 1.0);
uniform float metallic_strength : hint_range(0.0, 1.0) = 0.3;
uniform float fade_alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float mask_val = texture(mask_texture, UV).r;

	// Metalik çizgi efekti — kaplama yüzeyine parlaklık ekler
	float stripe = sin((UV.x + UV.y) * 60.0) * 0.5 + 0.5;
	float metallic = mix(1.0, 1.0 + metallic_strength * stripe, mask_val);

	// Hafif gradyan parlaklık
	float gradient = mix(0.95, 1.05, UV.y);

	vec3 col = cover_color.rgb * metallic * gradient;

	// Kenar yumuşatma — mask geçiş bölgesini smooth yap
	float alpha = smoothstep(0.0, 0.15, mask_val) * fade_alpha;

	COLOR = vec4(col, alpha);
}
