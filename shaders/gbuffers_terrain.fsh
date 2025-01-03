#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D normals;
uniform sampler2D specular;

in vec2 lmcoord;
noperspective in vec2 texcoord;
in vec2 normaltex;
in vec4 glcolor;
in vec3 normal;
in mat3 tbnmatrix;

flat in int nonPerspective;

/* RENDERTARGETS: 0,1,2,5 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

vec3 getnormalmap(vec2 texcoord){
	vec3 normalmap = texture(normals, texcoord).rgb;
	normalmap = normalmap * 2 - 1;
	normalmap.z = sqrt(1 - dot(normalmap.xy, normalmap.xy));
	return tbnmatrix * normalmap;
}

void main() {
	vec2 coord;
	if (bool(nonPerspective)){
		coord = texcoord;
	}else{
		coord = normaltex;
	}
	color = texture(gtexture, coord) * glcolor;
	color *= texture(lightmap, lmcoord);
	if (color.a < 0.1) {
		discard;
	}
	lightmapData = vec4(lmcoord, 0.0, 1.0);
	encodedNormal = vec4(getnormalmap(coord) * 1 + 0.5, 1.0);
}