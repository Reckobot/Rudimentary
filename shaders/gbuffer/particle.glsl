#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;
in vec3 normal;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
noperspective in vec2 texcoord;
in vec2 normal_texcoord;
in vec4 glcolor;

flat in int isTintedAlpha;
in float tintSaturation;
flat in int isEntityShadow;
flat in int isLeaves;
flat in int isGrass;

in vec2 textureBounds1;
in vec2 textureBounds2;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 light;
layout(location = 2) out vec4 encodedNormal;

void main() {
	vec2 coord;
	#ifdef AFFINE_TEXTURES
		coord = texcoord;
	#else
		coord = normal_texcoord;
	#endif

	coord = clamp(coord, textureBounds1, textureBounds2);

	#if PRESET == 0
		if ((abs(((glcolor.r + glcolor.b)/2) - glcolor.g)*4 > 0.5)){
			vec3 tintcolor = vec3(0.4, 0.8, 0.2);
			vec4 tint = vec4(tintcolor, glcolor.a);
			color = texture(gtexture, texcoord) * tint;
			color.rgb = BSC(color.rgb, 1.0, 1.0, 0.8);
			color.rgb = BSC(color.rgb, FOLIAGE_BRIGHTNESS*2, FOLIAGE_SATURATION, FOLIAGE_CONTRAST);
		}else{
			color = texture(gtexture, texcoord) * glcolor;
		}
	#elif PRESET == 1
		if (((glcolor.r + glcolor.g + glcolor.b)/3 < 0.9)){
			color = texture(gtexture, coord) * vec4(BSC(glcolor.rgb, 1.0, 1.0, 1.0), 1);
			color.rgb = BSC(color.rgb, FOLIAGE_BRIGHTNESS*2.0, FOLIAGE_SATURATION*0.9, FOLIAGE_CONTRAST*0.8);
		}else{
			color = texture(gtexture, coord) * glcolor;
		}
	#elif PRESET == 2
		color = texture(gtexture, coord) * glcolor;
		vec3 tint = (vec3(1.0, 0.9, 1.0))*0.95;
		color.rgb = BSC(color.rgb * (tint*1.25), 2.0, 1.0, 0.65);
	#endif
	vec2 lmc = lmcoord;
	light = texture(lightmap, lmc);

	float ambient;

	if (logicalHeightLimit == 384){
		ambient = 0.045;
	}else{
		ambient = 0.75;
	}

	light.rgb = clamp(light.rgb, ambient, 1.0);
	#ifdef FAST_LEAVES
		if (bool(isLeaves)){
			if (color.a < alphaTestRef) {
				discard;
			}
		}else{
			if (color.a < alphaTestRef) {
				color.rgb *= 0.6;
			}
		}
	#else
		if (color.a < alphaTestRef) {
			discard;
		}
	#endif

	if (bool(isEntityShadow)){
		discard;
	}

	encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
	encodedNormal.a = 1;

	#ifdef INVISIBLE_GRASS
		if (bool(isGrass)){
			discard;
		}
	#endif
}