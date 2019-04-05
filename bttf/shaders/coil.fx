float4 coilColor = float4(0.1,0.6,1,1);

float4 coilShader(float2 tex : TEXCOORD0) : COLOR0
{
	return coilColor;
}

technique BTTFCoil
{
	pass P0
	{
		PixelShader = compile ps_2_0 coilShader();
	}
}