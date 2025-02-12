#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex6;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);

    float depth = texture(depthtex0, texcoord).r;

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
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
		fogdensity = 0.15;
		renderdist = 8;
		doFog = true;
	}

	#ifdef HORROR
		fogdensity *= 0.5;
		renderdist *= 8-(getLuminance(skyColor)*8);
	#endif

	renderdist /= RENDER_DISTANCE_MULT;

	float dist = (length(viewPos) / (64/fogdensity))*4*renderdist;

	#if RENDER_DISTANCE == 0
		dist = length(viewPos) / far;
	#endif

	#if RENDER_DISTANCE != 5
		if (doFog){
			float fogFactor = exp(-4*fogdensity * (1.0 - dist));
			color.rgb = mix(color.rgb, fogcolor, clamp(fogFactor, 0.0, 1.0));
		}
	#endif

	#ifdef HORROR
		color.rgb = BSC(color.rgb, BRIGHTNESS, SATURATION, CONTRAST);
	#else
		color.rgb = BSC(color.rgb, BRIGHTNESS, SATURATION, CONTRAST);
	#endif

	#ifdef WATERMARK
		ivec2 coord = ivec2(texcoord*vec2(viewWidth, viewHeight))/ivec2(WATERMARK_SCALE);
		coord.y = int(viewHeight/(WATERMARK_SCALE+0.005)) - coord.y;
		vec4 watermark = texelFetch(colortex6, coord, 0);
		color.rgb = mix(color.rgb, watermark.rgb, watermark.a);
	#endif

	#ifdef DITHERING
		float threshold = 1.0;
		ivec2 pixelpos = ivec2(texcoord * vec2(viewWidth, viewHeight));
		if (mod(pixelpos.y, 2.0) == 0){
			if (mod(pixelpos.x, 2.0) == 0){
				threshold = 0.125;
			}else{
				threshold = 0.5;
			}
		}else{
			if (mod(pixelpos.x, 2.0) == 0){
				threshold = 1.0;
			}else{
				threshold = 0.25;
			}
		}

		int divisions = 256;

		float luminance = getLuminance(color.rgb);
		if (luminance < threshold){
			for (int i = 0; i < divisions; i++){
				if ((luminance >= (i*(threshold/divisions)))&&(luminance <= ((i+1)*(threshold/divisions)))){
					color.rgb *= clamp(i*(threshold/divisions)+(0.25/DITHERING_INTENSITY), 0.0, 1.0);
					break;
				}
			}
		}
	#endif
}