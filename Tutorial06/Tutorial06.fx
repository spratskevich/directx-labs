//--------------------------------------------------------------------------------------
// File: Tutorial06.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------
cbuffer ConstantBuffer : register( b0 )
{
	matrix World;
	matrix View;
	matrix Projection;
	float4 vLightDir[2];
	float4 vLightColor[2];
	float4 vOutputColor;
	float4 vLightPos[2];
	float4 att[2];
	float2 lightRange;
}


//--------------------------------------------------------------------------------------
struct VS_INPUT
{
    float4 Pos : POSITION;
    float3 Norm : NORMAL;
};

struct PS_INPUT
{
    float4 Pos : SV_POSITION;
	float4 WrldPos : POSITION;
    float3 Norm : TEXCOORD0;
};


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT input )
{
    PS_INPUT output = (PS_INPUT)0;
    output.Pos = mul( input.Pos, World );
    output.Pos = mul( output.Pos, View );
    output.Pos = mul( output.Pos, Projection );
	output.WrldPos = mul(input.Pos, World);
    output.Norm = mul( float4( input.Norm, 1 ), World ).xyz;
    
    return output;
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS( PS_INPUT input) : SV_Target
{
	float3 finalColor = 0;
	float3 vecToPixel1 = (vLightPos[0] - input.WrldPos).xyz;
	float3 vecToPixel2 = (vLightPos[1] - input.WrldPos).xyz;
	
	float distToPixel[2];
	distToPixel[0] = length(vecToPixel1);
	distToPixel[1] = length(vecToPixel2);

	vecToPixel1 /= distToPixel[0];
	vecToPixel2 /= distToPixel[1];

	float howMuchLight[2];
	howMuchLight[0] = dot(vecToPixel1, input.Norm);
	howMuchLight[1] = dot(vecToPixel2, input.Norm);

	for (int i = 0; i < 2; i++)
	{
		if (howMuchLight[i] > 0 && distToPixel[i] < lightRange[i])
		{
				finalColor += (vLightColor[i] * howMuchLight[i]).xyz;
				finalColor /= att[i].x + (att[i].y * distToPixel[i]) + (att[i].z * distToPixel[i] * distToPixel[i]);
		}
	}
	finalColor = saturate(finalColor);
	return float4(finalColor, 1);
}


//--------------------------------------------------------------------------------------
// PSSolid - render a solid color
//--------------------------------------------------------------------------------------
float4 PSSolid( PS_INPUT input) : SV_Target
{
    return vOutputColor;
}
