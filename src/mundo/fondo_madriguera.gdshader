shader_type canvas_item;

uniform vec4 tierra : source_color;
uniform vec4 labio : source_color;
uniform vec4 arcilla : source_color;
uniform vec4 arcilla_sombra : source_color;
uniform vec4 cielo : source_color;
uniform vec4 derrumbe : source_color;
uniform vec4 pasto : source_color;
uniform vec2 mapa_celdas = vec2(72.0, 100.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec4 campo = texture(TEXTURE, UV);
	float hueco = campo.r;
	float aire = campo.g;
	float tapado = campo.b;
	float afuera = campo.a;

	vec2 p = UV * mapa_celdas;
	float grano = hash(p * 16.0);
	float vena = sin(p.x * 0.85 + p.y * 0.5) * cos(p.x * 0.4 - p.y * 0.75);

	vec4 masa = mix(tierra, labio, 0.22 + vena * 0.08 + grano * 0.12);
	vec4 piso = mix(arcilla_sombra, arcilla, smoothstep(0.38, 0.9, hueco));
	piso.rgb += (grano - 0.5) * 0.03;

	float labio_amt = smoothstep(0.16, 0.34, hueco) * (1.0 - smoothstep(0.42, 0.66, hueco));
	vec4 col = mix(masa, piso, smoothstep(0.2, 0.48, hueco));
	col = mix(col, labio, labio_amt * 0.55);
	col = mix(col, derrumbe, smoothstep(0.25, 0.7, tapado) * 0.45);

	float mata = smoothstep(0.55, 0.92, hash(p * 7.5 + 2.0));
	col = mix(col, pasto, afuera * (0.55 + mata * 0.35));
	col = mix(col, cielo, smoothstep(0.34, 0.78, aire));

	COLOR = vec4(col.rgb, 1.0);
}
