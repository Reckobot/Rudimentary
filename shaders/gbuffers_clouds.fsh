#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;
in vec3 normal;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

flat in int isTintedAlpha;

/* RENDERTARGETS: 0,1,2,3 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 light;
layout(location = 2) out vec4 encodedNormal;
layout(location = 3) out vec4 cloudBuffer;

void main() {
	#ifdef DISTANT_HORIZONS
		discard;
	#endif

	if ((bool(isTintedAlpha))&&((((glcolor.r + glcolor.b)/2) - glcolor.g) <= -0.1)){
		vec3 tintcolor = vec3(0.27, 0.8, 0.2);
		vec4 tint = vec4(tintcolor, glcolor.a);
		color = texture(gtexture, texcoord) * tint;
		color.rgb = BSC(color.rgb, 1.5, 0.7, 1.1);
	}else{
		color = texture(gtexture, texcoord) * glcolor;
	}
	vec4 light = texture(lightmap, lmcoord);
	light.rgb = BSC(light.rgb, 0.75, 1.0, 2.0);
	color *= light;
	if (color.a < alphaTestRef) {
		discard;
	}

	encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
	cloudBuffer = vec4(1);
}