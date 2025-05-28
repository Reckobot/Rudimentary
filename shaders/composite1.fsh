#version 330 compatibility
#extension GL_ARB_shader_storage_buffer_object : enable
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D shadowtex0;

layout(std430, binding = 0) buffer frameData {
    float godRayMult;
};

in vec2 texcoord;

/* RENDERTARGETS: 0,5,6 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 godrayBuffer;
layout(location = 2) out vec4 fogBuffer;

void main() {
	//set color
	color = texture(colortex0, texcoord);

	//initialize variables
	float depth = texture(depthtex0, texcoord).r;
	float depth1 = texture(depthtex1, texcoord).r;
	mat4 projectionInverse = gbufferProjectionInverse;

	//initialize depth for distant horizons
	if(depth >= 1.0) {
		#ifdef DISTANT_HORIZONS
			depth = texture(dhDepthTex0, texcoord).r;
			depth1 = texture(dhDepthTex1, texcoord).r;
			projectionInverse = dhProjectionInverse;
		#endif
	}
	
	//oh sweet jesus
	vec3 light = texture(colortex4, texcoord).rgb;
	vec3 normal = texture(colortex3, texcoord).rgb;
	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(projectionInverse, NDCPos);
	vec3 camNDCPos = vec3(texcoord.xy, 0.0) * 2.0 - 1.0;
	vec3 camviewPos = projectAndDivide(projectionInverse, camNDCPos);
	vec3 centercamNDCPos = vec3(vec2(0.5, 0.5), 0.0) * 2.0 - 1.0;
	vec3 centercamviewPos = projectAndDivide(projectionInverse, centercamNDCPos);
	vec3 centercamworldPos = (gbufferModelViewInverse * vec4(centercamviewPos, 1.0)).xyz;
	centercamworldPos.y += 0.5;
	centercamviewPos = (gbufferModelView * vec4(centercamworldPos, 1.0)).xyz;
	vec3 camShadowScreen = viewToShadowScreen(centercamviewPos, false, depth, depth1, normal, true, false, texcoord);
	vec3 camLook = normalize(camviewPos);
	float lookModifier = dot(playerLookVector, mat3(gbufferModelViewInverse) * normalize(sunPosition))-0.75;
	lookModifier = clamp(lookModifier*8, 1.0, 10.0);

	//godrays!!!
	#ifdef GODRAYS
	float godray = 0.0;
	int stepCount = 16;
			for(int i = 1; i < 1+stepCount; i++) {
				vec3 ray = camNDCPos + (camLook*i*IGN(texcoord, frameCounter, vec2(viewWidth, viewHeight)));
				bool pixelate = false;
				vec3 rayShadowScreen = viewToShadowScreen(ray, pixelate, depth, depth1, normal, true, false, texcoord);

				if(ray.z > viewPos.z) {
					if(isEyeInWater == 0) {
						godray += step(rayShadowScreen.z, texture(shadowtex0, rayShadowScreen.xy).r)/(stepCount);
					} else {
						godray += (step(rayShadowScreen.z, texture(shadowtex0, rayShadowScreen.xy).r)/(stepCount))-(step(rayShadowScreen.z, texture(shadowtex0, rayShadowScreen.xy).r)/(stepCount)/2);
					}
				}
			}

			float modifier = clamp(step(camShadowScreen.z, texture(shadowtex0, camShadowScreen.xy).r), 0.0, 1.0);
			modifier = 1-modifier;

			if(isEyeInWater == 0) {
				godRayMult += ((modifier-0.5)*2.0)*((frameTime*0.00005)*GODRAY_TRANSITION);
				godRayMult = clamp(godRayMult, 0.125*GODRAY_MINIMUM, 1.0);

				godray *= 1-rainStrength;
				godrayBuffer = vec4(clamp((godray*godRayMult*lookModifier), 0.0, 0.375*GODRAY_INTENSITY));
			} else {
				godRayMult += ((modifier-0.5)*2.0)*((frameTime*0.00005)*GODRAY_TRANSITION);
				godRayMult = clamp(godRayMult, 0.125*GODRAY_MINIMUM, 1.0);

				godray *= 1-rainStrength;
				godrayBuffer = vec4(clamp((godray*godRayMult*12)+0.125, 0.0, 0.75*GODRAY_INTENSITY));
			}
	#endif

	//fog!!!
	float dist;
	float fogFactor;
	#ifndef DISTANT_HORIZONS
		dist = length(viewPos) / far;

		if(texture(colortex2, texcoord).rgb == vec3(1.0)) {
			dist /= 3;
		}

		dist *= 1+rainStrength;

		float density = 3.0;

		if(isEyeInWater == 1) {
			dist *= 6;
			density /= 4;
		}

		fogFactor = exp(-density * (1.125 - dist));
	#else
		if(isEyeInWater != 1) {
			dist = length(viewPos) / dhRenderDistance;
		} else {
			dist = length(viewPos) / far;
		}
		fogFactor = pow(dist, 0.75);
	#endif

	//underwater fog
	if(depth < 1.0) {
		if(isEyeInWater != 1) {
			fogBuffer = vec4(texture(colortex1, texcoord).rgb, clamp(fogFactor, 0.0, 1.0));
		} else {
			fogBuffer = vec4(pow(vec3(0.5, 0.75, 1.0), vec3(1.35))*0.825*(getLuminance(skyColor)+0.125), clamp(fogFactor, 0.0, 1.0));
		}
	}
	
	//change sky when underwater
	if(texture(depthtex0, texcoord).r >= 1.0 && isEyeInWater == 1) {
		color.rgb = pow(skyColor, vec3(3.0))*0.25;
	}
}