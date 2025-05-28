#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex8;
uniform sampler2D colortex10;
uniform sampler2D colortex12;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D shadowtex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	//set color
	color = texture(colortex0, texcoord);

	//discard if particle
	if(texture(colortex12, texcoord).rgb == vec3(1.0)) {
		discard;
	}
	
	//initialize variables
	float ambient = AMBIENT;
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

	//vanilla lighting variable thingie
	vec4 light = texture(colortex4, texcoord);

	//initialize normal and viewpos
	vec3 normal = normalize((texture(colortex3, texcoord).rgb - 0.5) * 2.0);
	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(projectionInverse, NDCPos);

	//pixelate or nah
	bool pixelate = true;
	if(texture(colortex8, texcoord).rgb != vec3(0.0)) {
		pixelate = false;
	}

	//do shadow stuff
	bool notBlock = false;
	notBlock = bool(int(texture(colortex8, texcoord).r));
	vec3 shadowScreenPos = viewToShadowScreen(viewPos, pixelate, depth, depth1, normal, false, notBlock, texcoord);
	float shadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);

	//daytime vs nighttime stuff
	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;
	bool isDayTime = false;
	if(shadowAngle == sunAngle) {
		isDayTime = true;
	}
	float time;
	if(isDayTime) {
		time = 1-(abs(shadowAngle - 0.25)*4);
	} else {
		time = 1-(abs(shadowAngle - 0.75)*4);
	}

	//DIFFERS BETWEEN COMPOSITE AND DEFERRED
	//---------------------------------------
	bool doShade = (depth != depth1);
	if(texture(colortex3, texcoord).rgb == vec3(0.0)) {
		doShade = false;
	}
	if(texture(colortex10, texcoord).rgb == vec3(1.0)) {
		doShade = true;
	}
	//---------------------------------------

	//here comes agony
	#ifdef SHADING
		if(doShade) {
			//do shading
			float shading = clamp(dot(normal, worldLightVector)*4.0, 0.0, 1.0);
			
			//do shadow
			#ifdef SHADOWS
			if(depth == texture(depthtex0, texcoord).r && texture(colortex2, texcoord).r != 1.0) {
				if(texture(depthtex1, texcoord).r == texture(depthtex2, texcoord).r) {
					shading *= shadow;
				}
			}
			#endif

			//apply sun angle modifier for brightness of everything
			shading = clamp(shading+clamp((clamp(time-0.5, 0.0, 1.0)*8), 0.0, 0.5), 0.0, 1.0);

			//colors
			vec3 sunLight;
			#ifdef WARM_COLORS
				sunLight = vec3(1.0,0.95,0.85)*1.125;
			#else
				sunLight = vec3(1.125);
			#endif
			vec3 moonLight = vec3(0.5,0.75,1.0)*3.0;
			vec3 ambientLight = vec3(0.5,0.75,1.0) * ambient * 1.75;

			//mix between sun and moon lighting
			vec3 lightMix = mix(moonLight, sunLight, clamp(time*8, 0.0, 1.0));

			//if it's a cloud, no shading
			if (texture(colortex2, texcoord).rgb == vec3(1.0)) {
				shading = 1.0;
			}

			//do lighting that comes from the sun, not blocklights
			vec3 sunLighting = mix(ambientLight, lightMix, clamp(shading, 0.25, 1.0));
			sunLighting *= clamp(light.g, 0.0, 1.0);
			sunLighting *= 1-(rainStrength/1.25);

			//darkens the lighting for nighttime
			if(!isDayTime) {
				sunLighting *= clamp(clamp(time*8, 0.0, 1.0), 0.25, 1.0);
			}

			//ah it's done, apply blocklights and boom
			vec3 blockLighting = vec3(1.25, 1.125, 0.75)*light.r*1.25;
			color.rgb *= clamp(mix(sunLighting, blockLighting, light.r), vec3(MINIMUM_LIGHT), vec3(1.0));
		}
	#else
		if(doShade && (texture(colortex2, texcoord).rgb != vec3(1.0))) {
			vec3 blockLighting = vec3(1.25, 1.125, 0.75);
			color.rgb *= mix(vec3(light.g), blockLighting, light.r);
		} else if(texture(colortex2, texcoord).rgb == vec3(1.0)) {
			color.rgb *= 1.2;
		}
	#endif
}