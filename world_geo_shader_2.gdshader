shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform float rotation;
uniform float CURVE = 0.40000000596046;
uniform sampler2D MainTex;



void vertex() {
// Input:2
	vec3 n_out2p0 = VERTEX;


// FloatParameter:18
	float n_out18p0 = rotation;


	vec3 n_out17p0;
	mat4 n_out17p1;
// RotationByAxis:17
	vec3 n_in17p2 = vec3(0.00000, 1.00000, 0.00000);
	{
		float __angle = n_out18p0;
		vec3 __axis = normalize(n_in17p2);
		mat3 __rot_matrix = mat3(
			vec3( cos(__angle)+__axis.x*__axis.x*(1.0 - cos(__angle)), __axis.x*__axis.y*(1.0-cos(__angle))-__axis.z*sin(__angle), __axis.x*__axis.z*(1.0-cos(__angle))+__axis.y*sin(__angle) ),
			vec3( __axis.y*__axis.x*(1.0-cos(__angle))+__axis.z*sin(__angle), cos(__angle)+__axis.y*__axis.y*(1.0-cos(__angle)), __axis.y*__axis.z*(1.0-cos(__angle))-__axis.x*sin(__angle) ),
			vec3( __axis.z*__axis.x*(1.0-cos(__angle))-__axis.y*sin(__angle), __axis.z*__axis.y*(1.0-cos(__angle))+__axis.x*sin(__angle), cos(__angle)+__axis.z*__axis.z*(1.0-cos(__angle)) )
		);
		n_out17p0 = n_out2p0 * __rot_matrix;
	}


// Reroute:16
	vec3 n_out16p0 = n_out17p0;


// Input:3
	vec3 n_out3p0 = NODE_POSITION_WORLD;


// VectorOp:4
	vec3 n_out4p0 = n_out17p0 + n_out3p0;


// Input:6
	vec3 n_out6p0 = CAMERA_POSITION_WORLD;


// VectorOp:7
	vec3 n_out7p0 = n_out4p0 - n_out6p0;


// VectorLen:12
	float n_out12p0 = length(n_out7p0);


// FloatParameter:14
	float n_out14p0 = CURVE;


// FloatOp:10
	float n_out10p0 = n_out12p0 * n_out14p0;


// FloatOp:13
	float n_in13p1 = 0.00000;
	float n_out13p0 = n_out10p0 + n_in13p1;


// VectorCompose:9
	float n_in9p0 = 0.00000;
	float n_in9p2 = 0.00000;
	vec3 n_out9p0 = vec3(n_in9p0, n_out13p0, n_in9p2);


// VectorOp:8
	vec3 n_out8p0 = n_out16p0 - n_out9p0;


// Output:0
	VERTEX = n_out8p0;


}

void fragment() {
	vec4 n_out3p0;
// Texture2D:3
	n_out3p0 = texture(MainTex, UV);


// VectorOp:9
	vec3 n_in9p1 = vec3(32.00000, 32.00000, 32.00000);
	vec3 n_out9p0 = vec3(n_out3p0.xyz) * n_in9p1;


// VectorFunc:10
	vec3 n_out10p0 = round(n_out9p0);


// VectorOp:11
	vec3 n_in11p1 = vec3(32.00000, 32.00000, 32.00000);
	vec3 n_out11p0 = n_out10p0 / n_in11p1;


// Input:4
	vec4 n_out4p0 = COLOR;


// VectorOp:7
	vec3 n_in7p1 = vec3(32.00000, 32.00000, 32.00000);
	vec3 n_out7p0 = vec3(n_out4p0.xyz) * n_in7p1;


// VectorFunc:6
	vec3 n_out6p0 = round(n_out7p0);


// VectorOp:8
	vec3 n_in8p1 = vec3(32.00000, 32.00000, 32.00000);
	vec3 n_out8p0 = n_out6p0 / n_in8p1;


// VectorOp:5
	vec3 n_out5p0 = n_out11p0 * n_out8p0;


// Output:0
	ALBEDO = n_out5p0;


}
