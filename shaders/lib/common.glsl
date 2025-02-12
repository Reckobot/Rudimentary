const float ambientOcclusionLevel = 0;

uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform float far;
uniform int isEyeInWater;
uniform float playerMood;
uniform float constantMood;
uniform float rainStrength;

uniform vec3 cameraPosition;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform int logicalHeightLimit;

uniform float viewWidth;
uniform float viewHeight;

const vec3 alphaFogColor = vec3(0.75, 0.85, 1.0);

vec3 BSC(vec3 color, float brt, float sat, float con)
{
	// Increase or decrease theese values to adjust r, g and b color channels seperately
	const float AvgLumR = 0.5;
	const float AvgLumG = 0.5;
	const float AvgLumB = 0.5;
	
	const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);
	
	vec3 AvgLumin  = vec3(AvgLumR, AvgLumG, AvgLumB);
	vec3 brtColor  = color * brt;
	vec3 intensity = vec3(dot(brtColor, LumCoeff));
	vec3 satColor  = mix(intensity, brtColor, sat);
	vec3 conColor  = mix(AvgLumin, satColor, con);
	
	return conColor;
}

float increment(float original, float numerator, float denominator){
    return round(original * denominator / numerator) * numerator / denominator;
}

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

float getLuminance(vec3 c){
	return dot(vec3(0.2126, 0.7152, 0.0722), c);
}

float fogify(float x, float w) {
	return w / (x * x + w);
}

//#define HORROR
//#define COLORED_LIGHTING

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	vec3 color;
	#ifdef COLORED_LIGHTING
		color = mix(fogColor * vec3(1.5,1.25,1) *0.75, vec3(0.5), rainStrength);
	#else
		color = mix(fogColor, vec3(0.5), rainStrength);
	#endif
	color = BSC(color, getLuminance(skyColor)*1.5, 1.0, 1.0);
	#ifndef HORROR
		return mix(BSC(vec3(0.55, 0.74, 1), clamp(getLuminance(skyColor), 0.0, 1.0), 2.0, 1.0), color, fogify(max((upDot/6)+0.05, 0.0), 0.01));
	#else
		return vec3(1)*getLuminance(skyColor);
	#endif
}

vec3 screenToView(vec3 screenPos) {
	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * ndcPos;
	return tmp.xyz / tmp.w;
}


const int RGBA8F = 0;
const int colortex0Format = RGBA8F;