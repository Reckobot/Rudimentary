#define ALPHACRAFT 0 //[0]
#define DISCLAIMER 0 //[0]

#define RENDER_DISTANCE 1 //[0 1 2 3 4 5]
#define RENDER_DISTANCE_MULT 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5.0]
//#define FAST_LEAVES
//#define INVISIBLE_GRASS
#define CLOUD_OFFSET 0 //[-200 -175 -150 -125 -100 -75 -50 -25 0 25 50 75 100 125 150 175 200]
//#define WATERMARK
#define WATERMARK_SCALE 6 //[1 2 3 4 5 6 7 8 9 10]

#define BRIGHTNESS 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SATURATION 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define CONTRAST 1.2 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define WATER_TRANSPARENCY 0.75 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define WATER_BRIGHTNESS 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define WATER_SATURATION 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define WATER_CONTRAST 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define FOLIAGE_BRIGHTNESS 0.6 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define FOLIAGE_SATURATION 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define FOLIAGE_CONTRAST 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define LIGHTING_SATURATION 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define RESOLUTION_SCALE 3 //[1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10 11 12]
#define DISTORTION 0.5 //[0 0.1 0.2 0.3 0.4 0.5 0.75 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0]
//#define ENTITY_DISTORTION
#define DITHERING
//#define CRT
#define SCANLINE_GAP 4 //[2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32]
#define SCANLINE_SPEED 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0]

#define WAVY_WATER

#define COLOR_DEPTH 32 //[1 2 4 8 16 24 32 64 128 256]

//#define AFFINE_TEXTURES

//#define CRT_DISTORTION
//#define CRT_SCANLINES
//#define CRT_ASPECT
#define MARKIPLIER 0.25 //[0.125 0.25 0.5 0.625 0.75 0.875 1.0]

#ifndef HORROR
    #ifdef COLORED_LIGHTING
        const vec3 sunColor = vec3(1.25,1.125,1)*0.9;
        const vec3 ambientColor = vec3(1,1.125,1.25)*0.5;
    #else
        const vec3 sunColor = vec3(1.0);
        const vec3 ambientColor = vec3(0.625);
    #endif
#else
    const vec3 sunColor = vec3(0.75);
    const vec3 ambientColor = vec3(0.25);
#endif

//#define GODRAYS
#define GODRAYS_INTENSITY 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.25 2.5 2.75 3.0 3.5 4.0 4.5 5.0 10.0]