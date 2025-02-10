#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

uniform sampler2D dhDepthTex0;
uniform mat4 dhProjectionInverse;
uniform float dhFarPlane;
in vec3 viewPos;

uniform sampler2D depthtex0;
uniform sampler2D lightmap;
uniform sampler2D gtexture;
in vec3 normal;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

flat in int isEntityShadow;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 light;
layout(location = 2) out vec4 encodedNormal;

void main() {
	float depth = texture(depthtex0, vec2(gl_FragCoord.xy)/vec2(viewWidth,viewHeight)).r;
	if (depth < 1){
		discard;
	}
	if (glcolor.b > 0.25){
		vec3 tintcolor = vec3(0.2,0.2,1)*0.95;
		vec4 tint = vec4(tintcolor, glcolor.a);
		color = texture(gtexture, texcoord) * tint;
	}else{
		color = texture(gtexture, texcoord) * glcolor;
	}
	color.rgb = BSC(color.rgb, 0.75, 0.25, 1.0);
	vec2 lmc = lmcoord;
	light = texture(lightmap, lmc);

	float ambient;

	if (logicalHeightLimit == 384){
		ambient = 0.045;
	}else{
		ambient = 0.25;
	}

	light.rgb = clamp(light.rgb, ambient, 1.0);

	if (bool(isEntityShadow)){
		discard;
	}

	encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
	encodedNormal.a = 1;

	color.rgb *= clamp(pow(light.rgb, vec3(2)), 0.0, 1.0);

	float fogdensity = 0.8;
	float renderdist = 0.1;
	bool doFog = true;
	vec3 fogcolor = calcSkyColor(normalize(viewPos));

	#if RENDER_DISTANCE == 1
		renderdist = 0.1;
	#elif RENDER_DISTANCE == 2
		renderdist = 0.2;
	#elif RENDER_DISTANCE == 3
		renderdist = 0.3;
	#elif RENDER_DISTANCE == 4
		renderdist = 0.4;
	#endif

	renderdist /= RENDER_DISTANCE_MULT;
	float dist = (length(viewPos) / (64/fogdensity))/4*renderdist;

	#if RENDER_DISTANCE != 5
		#if RENDER_DISTANCE == 0 || RENDER_DISTANCE == 1 || RENDER_DISTANCE == 2
			if (doFog){
				float fogFactor = exp(-4*fogdensity * (1.0 - dist));
				color.rgb = mix(color.rgb, fogcolor, clamp(fogFactor, 0.0, 1.0));
			}
		#else
			fogcolor = alphaFogColor;
			fogcolor = BSC(fogcolor, getLuminance(skyColor)*1.5, 1.0, 1.0);
			fogdensity = 0.65;
			float fogFactor = exp(-4*fogdensity * (1.0 - dist));
			color.rgb = mix(color.rgb, fogcolor, clamp(fogFactor, 0.0, 1.0));
		#endif
	#endif
}