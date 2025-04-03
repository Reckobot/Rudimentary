const float ambientOcclusionLevel = 0;

uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform float far;
uniform int isEyeInWater;
uniform float playerMood;
uniform vec3 playerLookVector;
uniform ivec2 eyeBrightnessSmooth;
uniform float constantMood;
uniform float rainStrength;
uniform int frameCounter;
uniform float frameTimeCounter;

uniform vec3 cameraPosition;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform int logicalHeightLimit;

uniform float viewWidth;
uniform float viewHeight;

#define PRESET 1 //[0 1 2]

const vec3 alphaFogColor = vec3(0.75, 0.85, 1.0);

vec3 BSC(vec3 color, float brt, float sat, float con)
{
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
#define COLORED_LIGHTING

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	vec3 color;
	#ifdef COLORED_LIGHTING
		color = mix((fogColor*1.25) * vec3(1.5,1.25,1) *0.75, vec3(0.5), rainStrength);
	#else
		color = mix((fogColor*1.25), vec3(0.5), rainStrength);
	#endif

	color = BSC(color, getLuminance(skyColor)*1.5, 1.0, 1.0);

	#ifndef HORROR
		#if PRESET == 2
			return mix(BSC(vec3(1, 0.9, 1.0), clamp(getLuminance(skyColor), 0.0, 1.0), 1.0, 1.0), color, fogify(max((upDot/6)+0.05, 0.0), 0.01));
		#else
			return mix(BSC(vec3(0.55, 0.74, 1)*0.75, clamp(getLuminance(skyColor), 0.0, 1.0), 2.0, 1.0), color, fogify(max((upDot/6)+0.05, 0.0), 0.01));
		#endif
	#else
		return vec3(1)*getLuminance(skyColor);
	#endif
}

vec3 screenToView(vec3 screenPos) {
	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * ndcPos;
	return tmp.xyz / tmp.w;
}

const float PI = 3.14159265359;

float rand(vec2 c){
	return fract(sin(dot(c.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float noise(vec2 p, float freq, float frequency){
	float unit = frequency/freq;
	vec2 ij = floor(p/unit);
	vec2 xy = mod(p,unit)/unit;
	//xy = 3.*xy*xy-2.*xy*xy*xy;
	xy = .5*(1.-cos(PI*xy));
	float a = rand((ij+vec2(0.,0.)));
	float b = rand((ij+vec2(1.,0.)));
	float c = rand((ij+vec2(0.,1.)));
	float d = rand((ij+vec2(1.,1.)));
	float x1 = mix(a, b, xy.x);
	float x2 = mix(c, d, xy.x);
	return mix(x1, x2, xy.y);
}

float pNoise(vec2 p, int res, float frequency){
	float persistance = .5;
	float n = 0.;
	float normK = 0.;
	float f = 4.;
	float amp = 1.;
	int iCount = 0;
	for (int i = 0; i<50; i++){
		n+=amp*noise(p, f, frequency);
		f*=2.;
		normK+=amp;
		amp*=persistance;
		if (iCount == res) break;
		iCount++;
	}
	float nf = n/normK;
	return nf*nf*nf*nf;
}

float IGN(vec2 coord, int frame, vec2 res)
{
    float x = float(coord.x * res.x) + 5.588238 * float(frame);
    float y = float(coord.y * res.y) + 5.588238 * float(frame);
    return mod(52.9829189 * mod(0.06711056*float(x) + 0.00583715*float(y), 1.0), 1.0);
}

vec3 distortShadowClipPos(vec3 shadowClipPos){
	float distortionFactor = length(shadowClipPos.xy);
	distortionFactor += 0.1;

	shadowClipPos.xy /= distortionFactor;
	shadowClipPos.z *= 0.5;
	return shadowClipPos;
}