
uniform mat4 mWorldViewProj;
uniform mat4 mInvWorld;
uniform mat4 mTransWorld;
uniform float dayNightRatio;
uniform vec3 eyePosition;

varying vec3 vPosition;
varying vec3 viewVec;
varying vec3 T,B,N;
varying vec3 worldPos;
varying vec4 fragPos; 
varying vec3 viewPos;
varying vec3 cameraPos;
varying vec2 uv;

void main(void)
{
	gl_Position = mWorldViewProj * gl_Vertex;

	vPosition = (mWorldViewProj * gl_Vertex).xyz;
	vec3 pos = vec3(gl_Vertex);

	vec3 c1 = cross( gl_Normal, vec3(0.0, 0.0, 1.0) ); 
	vec3 c2 = cross( gl_Normal, vec3(0.0, 1.0, 0.0) ); 
	if( length(c1)>length(c2) )
		T = c1;
	else
		T = c2;
	N   = gl_Normal; 
	B   = cross(N, T);

	worldPos = vec3(mTransWorld * gl_Vertex);
	fragPos = ftransform();
	viewPos = pos - gl_ModelViewMatrixInverse[3].xyz;
	cameraPos = eyePosition;

	vec4 color;
	//color = vec4(1.0, 1.0, 1.0, 1.0);

	float day = gl_Color.r;
	float night = gl_Color.g;
	float light_source = gl_Color.b;

	/*color.r = mix(night, day, dayNightRatio);
	color.g = color.r;
	color.b = color.r;*/

	float rg = mix(night, day, dayNightRatio);
	rg += light_source * 1.5; // Make light sources brighter
	float b = rg;

	// Moonlight is blue
	b += (day - night) / 13.0;
	rg -= (day - night) / 13.0;

	// Emphase blue a bit in darker places
	// See C++ implementation in mapblock_mesh.cpp finalColorBlend()
	b += max(0.0, (1.0 - abs(b - 0.13)/0.17) * 0.025);

	// Artificial light is yellow-ish
	// See C++ implementation in mapblock_mesh.cpp finalColorBlend()
	rg += max(0.0, (1.0 - abs(rg - 0.85)/0.15) * 0.065);

	color.r = rg;
	color.g = rg;
	color.b = b;

	// Make sides and bottom darker than the top
	color = color * color; // SRGB -> Linear
	if(gl_Normal.y <= 0.5)
		color *= 0.6;
		//color *= 0.7;
	color = sqrt(color); // Linear -> SRGB

	color.a = gl_Color.a;

	gl_FrontColor = gl_BackColor = color;

	gl_TexCoord[0] = gl_MultiTexCoord0;
}
