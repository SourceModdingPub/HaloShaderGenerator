﻿#ifndef _TWO_LOBE_PHONG_HLSL
#define _TWO_LOBE_PHONG_HLSL

#include "../registers/shader.hlsli"
#include "../helpers/math.hlsli"
#include "../helpers/color_processing.hlsli"
#include "../helpers/sh.hlsli"
#include "material_shared_parameters.hlsli"
#include "../helpers/definition_helper.hlsli"

void calc_material_analytic_specular_two_lobe_phong_ps(
in float3 reflect_dir,
in float3 light_dir,
in float3 light_intensity,
in float3 specular_tint,
in float specular_power,
out float3 analytic_specular)
{
	analytic_specular = specular_power * specular_tint;
	analytic_specular *= light_intensity;
	analytic_specular = dot(light_dir, reflect_dir) > 0 ? analytic_specular : 0;
}

void calc_material_area_specular_order_3_two_lobe_phong_ps(
in float3 reflect_dir,
in float4 sh_0,
in float4 sh_312[3],
in float4 sh_457[3],
in float4 sh_8866[3],
in float3 specular_tint,
out float3 area_specular)
{
	area_specular = sh_0.r * 0.423142493; // TODO: I think it should be sh_0.rgb, not sh_0.r, might explain redness on some reflections on guardian, test later
	
	float3 band_1_reflect_color = float3(-dot(reflect_dir, sh_312[0].xyz), -dot(reflect_dir, sh_312[1].xyz), -dot(reflect_dir, sh_312[2].xyz));
	area_specular += 0.380523592 * band_1_reflect_color.rgb;
	
	// no basis rotation into local frame? hmmm
	float3 test = reflect_dir.yzx * reflect_dir.xyz;
	float3 band_2_457_reflect_color = float3(-dot(test, sh_457[0].xyz), -dot(test, sh_457[1].xyz), -dot(test, sh_457[2].xyz));
	area_specular += 0.401889086 * band_2_457_reflect_color.rgb;
	
	float4 test2 = float4(reflect_dir.xyz * reflect_dir.xyz, 1 / 3.0);
	float3 band_2_8866_reflect_color = float3(-dot(test2, sh_8866[0]), -dot(test2, sh_8866[1]), -dot(test2, sh_8866[2]));
	area_specular += 0.200944602 * band_2_8866_reflect_color.rgb;
	
	area_specular *= specular_tint;
}

void calc_material_area_specular_order_2_two_lobe_phong_ps(
in float3 reflect_dir,
in float4 sh_0,
in float4 sh_312[3],
in float3 specular_tint,
out float3 area_specular)
{
	float4 sh_8866[3];
	float4 sh_457[3];
	sh_457[0] = 0;
	sh_457[1] = 0;
	sh_457[2] = 0;
	sh_8866[0] = 0;
	sh_8866[1] = 0;
	sh_8866[2] = 0;
	
	calc_material_area_specular_order_3_two_lobe_phong_ps(reflect_dir, sh_0, sh_312, sh_457, sh_8866, specular_tint, area_specular);
}

void calc_material_area_specular_two_lobe_phong_ps(
in float3 reflect_dir,
in float4 sh_0,
in float4 sh_312[3],
in float4 sh_457[3],
in float4 sh_8866[3],
in float3 specular_tint,
out float3 area_specular)
{
	if (order3_area_specular && shaderstage != k_shaderstage_static_per_pixel && shaderstage != k_shaderstage_static_per_vertex)
	{
		calc_material_area_specular_order_3_two_lobe_phong_ps(reflect_dir, sh_0, sh_312, sh_457, sh_8866, specular_tint, area_specular);
	}
	else
	{
		calc_material_area_specular_order_2_two_lobe_phong_ps(reflect_dir, sh_0, sh_312, specular_tint, area_specular);
	}
}


#endif