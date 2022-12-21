shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

const float PI = 3.1415926;

uniform float viewmodel_fov = 50.0f;

uniform vec4 albedo : hint_color = vec4(1.0f);
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular = 0.5f;
uniform float metallic = 1.0f;
uniform float roughness : hint_range(0,1) = 1.0f;
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_metallic : hint_white;
uniform vec4 metallic_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
//uniform sampler2D texture_emission : hint_black_albedo;
//uniform vec4 emission : hint_color;
//uniform float emission_energy;
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale : hint_range(-16,16) = 0.5f;
uniform vec3 uv1_scale = vec3(1.0f);
uniform vec3 uv1_offset = vec3(0.0f);
uniform vec3 uv2_scale = vec3(1.0f);
uniform vec3 uv2_offset = vec3(0.0f);

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
	
	/* begin shader magic*/
	float onetanfov = 1.0f / tan(0.5f * (viewmodel_fov * PI / 180.0f)); // calculate components for projection matrix
	float aspect = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;                   // calculate components for projection matrix
	// modify projection matrix
	PROJECTION_MATRIX[0][0] = onetanfov / aspect;  // insert into matrix to modify FOV; X scaling
    PROJECTION_MATRIX[1][1] = onetanfov;           // insert into matrix to modify FOV; Y scaling
    // ---------------------------------------------------------------------------------------------------------------------------
	// draws the viewmodel over everything (disable if you want dof near on viewmodel)
	POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX.xyz, 1.0); // recalculate position, multiplying by matrices; multiply right to left, even the vec4 (because column major vectors, not row major)
    // Clip Space POSIITON vec4 (output) <- View to Clip Space <- Model to View Space <- Model Space VERTEX vec4 (input)
	POSITION.z = mix(POSITION.z, 0, 0.999); // modify z value to draw on top of everything; values >.9999 causes z-fighting(?) artifacts, .999 is a safe value
                                            // effectively smushes everything down on the depth-axis 0.001 thick up against the camera without messing with the perspective thanks to the previous line of code
	/* end shader magic */
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	albedo_tex *= COLOR;
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	NORMALMAP = texture(texture_normal,base_uv).rgb;
	NORMALMAP_DEPTH = normal_scale;
	//vec3 emission_tex = texture(texture_emission,base_uv).rgb;
	//EMISSION = (emission.rgb+emission_tex)*emission_energy;
}