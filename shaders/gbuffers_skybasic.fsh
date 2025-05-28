#version 330 compatibility
#include "/lib/common.glsl"

uniform int renderStage;
uniform vec3 fogColor;

in vec4 glcolor;

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	#ifdef WARM_COLORS
		return mix(mix(pow(skyColor, vec3(1.125))*0.5, fogColor*vec3(1.2,0.9,0.65)*1.25, fogify(max(upDot, 0.0), 0.35)-0.15), vec3(getLuminance(skyColor))*0.25, rainStrength);
	#else
		return mix(mix(pow(skyColor, vec3(2.0))*0.5, pow(fogColor*vec3(1.0)*1.25, vec3(0.25))*getLuminance(skyColor.rgb)*1.5, fogify(max(upDot, 0.0), 0.5)-0.25), vec3(getLuminance(skyColor))*0.25, rainStrength);
	#endif
}

vec3 vanillaCalcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.025)+0.25);
}

vec3 screenToView(vec3 screenPos) {
	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * ndcPos;
	return tmp.xyz / tmp.w;
}

/* RENDERTARGETS: 0,1 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 skyBuffer;

void main() {
	#ifdef SHADING
		if (renderStage == MC_RENDER_STAGE_STARS) {
			color = glcolor;
		} else {
			vec3 pos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
			color = vec4(calcSkyColor(normalize(pos)), 1.0);
		}

		vec3 pos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
		vec4 buffercolor = vec4(calcSkyColor(normalize(pos)), 1.0);
		skyBuffer = buffercolor;
	#else
		if (renderStage == MC_RENDER_STAGE_STARS) {
			color = glcolor;
		} else {
			vec3 pos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
			color = vec4(vanillaCalcSkyColor(normalize(pos)), 1.0);
		}

		vec3 pos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
		vec4 buffercolor = vec4(vanillaCalcSkyColor(normalize(pos)), 1.0);
		skyBuffer = buffercolor;
	#endif
}
