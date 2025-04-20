#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex6;

in vec2 texcoord;

/* RENDERTARGETS: 0,11 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 volumetricBuffer;

void main() {
	color = texture(colortex0, texcoord);

    float depth = texture(depthtex0, texcoord).r;
	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);

    float depth1 = texture(depthtex1, texcoord).r;
	vec3 NDCPos1 = vec3(texcoord.xy, depth1) * 2.0 - 1.0;
	vec3 viewPos1 = projectAndDivide(gbufferProjectionInverse, NDCPos1);

	vec3 pos = screenToView(vec3(texcoord.xy, depth));

	vec3 fogcolor = calcSkyColor(normalize(pos));
	float fogdensity = 1.0;
	bool doFog = false;

	if ((depth < 1)){
		color.rgb = BSC(color.rgb, 1.0, 1.1, 1.0);
	}

	float renderdist;

	#if RENDER_DISTANCE == 1
		renderdist = 0.1;
	#elif RENDER_DISTANCE == 2
		renderdist = 0.175;
	#elif RENDER_DISTANCE == 3
		renderdist = 0.4;
	#elif RENDER_DISTANCE == 4
		renderdist = 0.6;
	#endif

	if (texture(colortex3, texcoord) == vec4(1)){
		renderdist *= 0.25;
	}

	fogdensity *= 1+rainStrength*0.25;
	renderdist *= 1+rainStrength;

	#ifndef DISTANT_HORIZONS
	if ((depth < 1)){
		doFog = true;
	}
	#else
		doFog = false;
	#endif

	if (isEyeInWater == 1){
		fogcolor = vec3(0.05,0.05,0.35)*0.6;
		fogdensity *= 0.25;
		doFog = true;
	}

	#ifdef HORROR
		fogdensity *= 0.5;
		renderdist *= 8-(getLuminance(skyColor)*8);
	#endif

	renderdist /= RENDER_DISTANCE_MULT;

	float dist = (length(viewPos) / (64/fogdensity))*4*renderdist;
	float dist1 = (length(viewPos1) / (64/fogdensity))*4*renderdist;

	#if RENDER_DISTANCE == 0
		dist = length(viewPos) / far;
	#endif

	vec3 startPos = screenToView(vec3(texcoord.xy, depth));
	vec3 viewDir = normalize(startPos);
	float volumetricIntensity = 0;
	int count = 0;

	#ifdef GODRAYS

	for (int i = 0; i < 16; i++){
		vec3 rayPos = startPos + (viewDir*i*8);
		rayPos *= (IGN(texcoord, frameCounter, vec2(viewWidth, viewHeight)*8));
		vec3 ftplPos = (gbufferModelViewInverse * vec4(rayPos, 1.0)).xyz;
		vec3 shadowviewPos = (shadowModelView * vec4(ftplPos, 1.0)).xyz;
		vec4 shadowclipPos = shadowProjection * vec4(shadowviewPos, 1.0);
		shadowclipPos.xyz = distortShadowClipPos(shadowclipPos.xyz);
		vec3 shadowndcPos = shadowclipPos.xyz/shadowclipPos.w;
		vec3 shadowscreenPos = shadowndcPos * 0.5 + 0.5;

		if (length(rayPos) < length(screenToView(vec3(texcoord, depth)))){
			float shadow = step(shadowscreenPos.z, texture(shadowtex1, shadowscreenPos.xy).r);
			volumetricIntensity += shadow;
		}
	}

	vec3 volumetricColor = BSC(sunColor, 1.0, 3.0, 1.0);

	volumetricColor = mix(volumetricColor, ambientColor, 1-getLuminance(skyColor));

	volumetricIntensity *= 2;
	if (depth >= 1){
		volumetricIntensity = 1.0;
	}
	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;
	volumetricIntensity = clamp(volumetricIntensity, 0.0, 0.25*GODRAYS_INTENSITY);
	volumetricIntensity *= clamp(getLuminance(skyColor)*4, 0.25, 1.0);
	volumetricIntensity *= 1-rainStrength;
	volumetricBuffer = vec4(volumetricColor, volumetricIntensity);

	#endif

	#if RENDER_DISTANCE != 5
		if (doFog){
			float fogFactor = exp(-4*fogdensity * (1.0 - dist));
			color.rgb = mix(color.rgb, fogcolor, clamp(fogFactor, 0.0, 1.0));

			if (dist != dist1){
				fogFactor = exp(-4*fogdensity * (1.0 - dist1));
				color.rgb = mix(color.rgb, fogcolor, clamp(fogFactor, 0.0, 1.0));	
			}
		}
	#endif
}